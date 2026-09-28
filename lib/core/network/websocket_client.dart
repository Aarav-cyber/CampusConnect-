import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage_service.dart';

class WebSocketClient {
  static final WebSocketClient _instance = WebSocketClient._internal();
  factory WebSocketClient() => _instance;
  WebSocketClient._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  int _reconnectAttempts = 0;
  final int _maxReconnectDelaySeconds = 30;

  // Stream controllers for app events
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get presenceStream => _presenceController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  Future<void> connect() async {
    final token = await LocalStorageService.getToken();
    if (token == null) return;

    if (_isConnected) return;

    try {
      final wsUrl = Uri.parse('${ApiConstants.wsUrl}?token=$token');
      _channel = WebSocketChannel.connect(wsUrl);

      _subscription = _channel?.stream.listen(
        (data) {
          _handleIncoming(data);
        },
        onDone: () {
          _handleDisconnect();
        },
        onError: (err) {
          debugPrint('WebSocket error: $err');
          _handleDisconnect();
        },
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionStatusController.add(true);
      _startHeartbeat();
      _flushOfflineQueue();
    } catch (e) {
      debugPrint('WebSocket connection exception: $e');
      _handleDisconnect();
    }
  }

  void _handleIncoming(dynamic data) {
    try {
      final decoded = jsonDecode(data as String) as Map<String, dynamic>;
      final type = decoded['type'] as String?;

      switch (type) {
        case 'authenticated':
          debugPrint('WebSocket authenticated successfully');
          break;
        case 'message.created':
          _messageController.add(decoded);
          break;
        case 'user.typing':
          _typingController.add(decoded);
          break;
        case 'user.presence':
          _presenceController.add(decoded);
          break;
        case 'pong':
          // Heartbeat ack
          break;
        default:
          debugPrint('Unknown WS event: $type');
      }
    } catch (e) {
      debugPrint('Error parsing incoming WS data: $e');
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _connectionStatusController.add(false);
    _heartbeatTimer?.cancel();
    _subscription?.cancel();

    // Exponential backoff reconnect: 1s, 2s, 4s, 8s, 16s, up to 30s
    final delay = min(pow(2, _reconnectAttempts).toInt(), _maxReconnectDelaySeconds);
    _reconnectAttempts++;
    debugPrint('WS disconnected. Reconnecting in $delay seconds (attempt $_reconnectAttempts)...');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      if (_isConnected) {
        send({'type': 'ping'});
      }
    });
  }

  void send(Map<String, dynamic> data) {
    if (_isConnected && _channel != null) {
      _channel?.sink.add(jsonEncode(data));
    } else {
      // If sending a message while offline, queue it!
      if (data['type'] == 'message.send') {
        LocalStorageService.queueOfflineMessage(data);
      }
    }
  }

  Future<void> _flushOfflineQueue() async {
    final queue = await LocalStorageService.getOfflineQueue();
    if (queue.isNotEmpty) {
      debugPrint('Flushing ${queue.length} offline messages...');
      for (final msg in queue) {
        send(msg);
      }
      await LocalStorageService.clearOfflineQueue();
    }
  }

  void joinRoom(String conversationId) {
    send({
      'type': 'room.join',
      'conversationId': conversationId,
    });
  }

  void sendChatMessage({
    required String conversationId,
    required String content,
    String messageType = 'TEXT',
  }) {
    send({
      'type': 'message.send',
      'conversationId': conversationId,
      'content': content,
      'messageType': messageType,
    });
  }

  void sendTyping({required String conversationId, required bool isTyping}) {
    send({
      'type': isTyping ? 'typing.start' : 'typing.stop',
      'conversationId': conversationId,
    });
  }

  void markMessageRead({required String conversationId, String? messageId}) {
    send({
      'type': 'message.read',
      'conversationId': conversationId,
      if (messageId != null) 'messageId': messageId,
    });
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _connectionStatusController.add(false);
  }
}
