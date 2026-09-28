import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/community_entity.dart';

class CommunitiesProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  CommunitiesProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  List<CommunityEntity> _communities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CommunityEntity> get communities => _communities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCommunities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.get(ApiConstants.communities);
      if (res != null && res['data'] is List) {
        _communities = (res['data'] as List)
            .map((e) => CommunityEntity.fromJson(e as Map<String, dynamic>))
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

  Future<CommunityEntity?> getCommunityDetails(String id) async {
    try {
      final res = await _apiClient.get(ApiConstants.communityDetail(id));
      if (res != null) {
        return CommunityEntity.fromJson(res as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error getting community detail: $e');
    }
    return null;
  }

  Future<bool> toggleJoin(String communityId) async {
    final idx = _communities.indexWhere((c) => c.id === communityId);
    if (idx == -1) return false;

    final current = _communities[idx];
    final willJoin = !current.isMember;

    // Optimistic update
    _communities[idx] = current.copyWith(
      isMember: willJoin,
      memberCount: willJoin ? current.memberCount + 1 : current.memberCount - 1,
    );
    notifyListeners();

    try {
      if (willJoin) {
        await _apiClient.post(ApiConstants.joinCommunity(communityId));
      } else {
        await _apiClient.post(ApiConstants.leaveCommunity(communityId));
      }
      return true;
    } catch (e) {
      // Revert on error
      _communities[idx] = current;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createCommunity({
    required String name,
    required String description,
    String? coverImage,
  }) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.communities,
        body: {
          'name': name.trim(),
          'description': description.trim(),
          if (coverImage != null) 'coverImage': coverImage,
        },
      );
      if (res != null) {
        final newComm = CommunityEntity.fromJson(res as Map<String, dynamic>);
        _communities.insert(0, newComm);
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
