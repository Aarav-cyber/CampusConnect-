import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/websocket_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/student_entity.dart';

class StudentsProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  StreamSubscription? _presenceSub;

  StudentsProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient() {
    _listenToPresence();
  }

  List<StudentEntity> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedYear = 'All';

  List<StudentEntity> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedDepartment => _selectedDepartment;
  String get selectedYear => _selectedYear;

  void _listenToPresence() {
    _presenceSub = WebSocketClient().presenceStream.listen((event) {
      final userId = event['userId']?.toString();
      final isOnline = event['isOnline'] == true;
      if (userId == null) return;

      bool changed = false;
      _students = _students.map((s) {
        if (s.userId == userId) {
          changed = true;
          return s.copyWith(isOnline: isOnline);
        }
        return s;
      }).toList();

      if (changed) notifyListeners();
    });
  }

  Future<void> fetchStudents({bool refresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (_searchQuery.isNotEmpty) queryParams['search'] = _searchQuery;
      if (_selectedDepartment != 'All') queryParams['department'] = _selectedDepartment;
      if (_selectedYear != 'All') queryParams['year'] = _selectedYear;

      final res = await _apiClient.get(ApiConstants.users, queryParams: queryParams);
      if (res != null && res['data'] is List) {
        _students = (res['data'] as List)
            .map((e) => StudentEntity.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String query) {
    _searchQuery = query;
    fetchStudents();
  }

  void updateDepartmentFilter(String dept) {
    _selectedDepartment = dept;
    fetchStudents();
  }

  void updateYearFilter(String year) {
    _selectedYear = year;
    fetchStudents();
  }

  Future<bool> toggleConnect(String studentUserId) async {
    final studentIdx = _students.indexWhere((s) => s.userId == studentUserId);
    if (studentIdx == -1) return false;

    final current = _students[studentIdx];
    final newConnected = !current.isConnected;

    // Optimistic update
    _students[studentIdx] = current.copyWith(isConnected: newConnected);
    notifyListeners();

    try {
      if (newConnected) {
        await _apiClient.post(ApiConstants.connect(studentUserId));
      } else {
        await _apiClient.delete(ApiConstants.connect(studentUserId));
      }
      return true;
    } catch (e) {
      // Revert on error
      _students[studentIdx] = current;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _presenceSub?.cancel();
    super.dispose();
  }
}
