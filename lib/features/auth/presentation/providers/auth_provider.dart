import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/websocket_client.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  AuthProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await LocalStorageService.getToken();
      final cachedUser = await LocalStorageService.getUser();

      if (token != null && cachedUser != null) {
        _currentUser = UserEntity.fromJson(cachedUser);
        _status = AuthStatus.authenticated;
        notifyListeners();

        // Connect WebSocket in background
        WebSocketClient().connect();

        // Refresh latest profile from backend
        try {
          final res = await _apiClient.get(ApiConstants.me);
          if (res != null && res['user'] != null) {
            _currentUser = UserEntity.fromJson(res['user']);
            await LocalStorageService.saveUser(_currentUser!.toJson());
            notifyListeners();
          }
        } catch (_) {}
      } else {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.post(
        ApiConstants.login,
        body: {'email': email.trim(), 'password': password},
      );

      final token = res['token'] as String;
      final userData = res['user'] as Map<String, dynamic>;
      _currentUser = UserEntity.fromJson(userData);

      await LocalStorageService.saveToken(token);
      await LocalStorageService.saveUser(_currentUser!.toJson());

      _status = AuthStatus.authenticated;
      notifyListeners();

      // Connect WebSocket
      WebSocketClient().connect();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String department,
    required String year,
    required String university,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.post(
        ApiConstants.register,
        body: {
          'email': email.trim(),
          'password': password,
          'fullName': fullName.trim(),
          'department': department.trim(),
          'year': year.trim(),
          'university': university.trim(),
        },
      );

      final token = res['token'] as String;
      final userData = res['user'] as Map<String, dynamic>;
      _currentUser = UserEntity.fromJson(userData);

      await LocalStorageService.saveToken(token);
      await LocalStorageService.saveUser(_currentUser!.toJson());

      _status = AuthStatus.authenticated;
      notifyListeners();

      // Connect WebSocket
      WebSocketClient().connect();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? bio,
    List<String>? skills,
    List<String>? interests,
    String? profileImage,
  }) async {
    if (_currentUser == null) return false;

    try {
      final res = await _apiClient.put(
        ApiConstants.profile,
        body: {
          if (bio != null) 'bio': bio,
          if (skills != null) 'skills': skills,
          if (interests != null) 'interests': interests,
          if (profileImage != null) 'profileImage': profileImage,
        },
      );

      if (res != null) {
        _currentUser = _currentUser!.copyWith(
          bio: bio,
          skills: skills,
          interests: interests,
          profileImage: profileImage,
        );
        await LocalStorageService.saveUser(_currentUser!.toJson());
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    WebSocketClient().disconnect();
    await LocalStorageService.clearToken();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
