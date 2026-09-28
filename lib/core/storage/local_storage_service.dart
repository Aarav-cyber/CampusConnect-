import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyToken = 'auth_jwt_token';
  static const String _keyUser = 'cached_user_profile';
  static const String _keyOfflineQueue = 'offline_message_queue';
  static const String _keyCachedConversations = 'cached_conversations';
  static const String _keyCachedEvents = 'cached_events';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token
  static Future<void> saveToken(String token) async {
    await init();
    await _prefs?.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    await init();
    return _prefs?.getString(_keyToken);
  }

  static Future<void> clearToken() async {
    await init();
    await _prefs?.remove(_keyToken);
    await _prefs?.remove(_keyUser);
  }

  // User Profile
  static Future<void> saveUser(Map<String, dynamic> userJson) async {
    await init();
    await _prefs?.setString(_keyUser, jsonEncode(userJson));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    await init();
    final str = _prefs?.getString(_keyUser);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Offline Messages Queue
  static Future<void> queueOfflineMessage(Map<String, dynamic> message) async {
    await init();
    final list = await getOfflineQueue();
    list.add(message);
    await _prefs?.setString(_keyOfflineQueue, jsonEncode(list));
  }

  static Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    await init();
    final str = _prefs?.getString(_keyOfflineQueue);
    if (str == null) return [];
    try {
      final decoded = jsonDecode(str) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearOfflineQueue() async {
    await init();
    await _prefs?.remove(_keyOfflineQueue);
  }

  // Cached conversations & events for offline resilience
  static Future<void> cacheConversations(List<dynamic> list) async {
    await init();
    await _prefs?.setString(_keyCachedConversations, jsonEncode(list));
  }

  static Future<List<dynamic>?> getCachedConversations() async {
    await init();
    final str = _prefs?.getString(_keyCachedConversations);
    if (str == null) return null;
    try {
      return jsonDecode(str) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }
}
