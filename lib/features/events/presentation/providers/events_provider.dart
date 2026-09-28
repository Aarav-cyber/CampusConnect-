import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/event_entity.dart';

class EventsProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  EventsProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  List<EventEntity> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _selectedFilter = 'all'; // all, registered, my

  List<EventEntity> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get selectedFilter => _selectedFilter;

  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (_selectedCategory != 'All') queryParams['category'] = _selectedCategory;
      if (_selectedFilter != 'all') queryParams['filter'] = _selectedFilter;

      final res = await _apiClient.get(ApiConstants.events, queryParams: queryParams);
      if (res != null && res['data'] is List) {
        _events = (res['data'] as List)
            .map((e) => EventEntity.fromJson(e as Map<String, dynamic>))
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

  void updateCategory(String category) {
    _selectedCategory = category;
    fetchEvents();
  }

  void updateFilter(String filter) {
    _selectedFilter = filter;
    fetchEvents();
  }

  Future<EventEntity?> getEventDetails(String id) async {
    try {
      final res = await _apiClient.get(ApiConstants.eventDetail(id));
      if (res != null) {
        return EventEntity.fromJson(res as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error getting event details: $e');
    }
    return null;
  }

  Future<bool> toggleRegister(String eventId) async {
    final idx = _events.indexWhere((e) => e.id == eventId);
    if (idx == -1) return false;

    final current = _events[idx];
    final willRegister = !current.isRegistered;

    // Optimistic update
    _events[idx] = current.copyWith(
      isRegistered: willRegister,
      registeredCount: willRegister ? current.registeredCount + 1 : current.registeredCount - 1,
    );
    notifyListeners();

    try {
      if (willRegister) {
        await _apiClient.post(ApiConstants.registerEvent(eventId));
      } else {
        await _apiClient.delete(ApiConstants.registerEvent(eventId));
      }
      return true;
    } catch (e) {
      // Revert on error
      _events[idx] = current;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required String location,
    required String startTime,
    required String endTime,
    required int capacity,
    required String category,
    String? coverImage,
  }) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.events,
        body: {
          'title': title.trim(),
          'description': description.trim(),
          'location': location.trim(),
          'startTime': startTime,
          'endTime': endTime,
          'capacity': capacity,
          'category': category,
          if (coverImage != null) 'coverImage': coverImage,
        },
      );
      if (res != null) {
        final newEvt = EventEntity.fromJson(res as Map<String, dynamic>);
        _events.insert(0, newEvt);
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
}
