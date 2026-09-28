class ApiConstants {
  // Use 10.0.2.2 for Android emulator, or localhost for Web/Desktop/iOS emulator
  static const String baseUrl = 'http://localhost:5000/api';
  static const String wsUrl = 'ws://localhost:5000/ws';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Users & Students
  static const String users = '/users';
  static const String profile = '/users/profile';
  static String userDetail(String id) => '/users/$id';
  static String connect(String id) => '/users/$id/connect';

  // Communities
  static const String communities = '/communities';
  static String communityDetail(String id) => '/communities/$id';
  static String joinCommunity(String id) => '/communities/$id/join';
  static String leaveCommunity(String id) => '/communities/$id/leave';

  // Events
  static const String events = '/events';
  static String eventDetail(String id) => '/events/$id';
  static String registerEvent(String id) => '/events/$id/register';

  // Chat
  static const String conversations = '/chat/conversations';
  static String messages(String conversationId) => '/chat/conversations/$conversationId/messages';
  static const String directConversation = '/chat/conversations/direct';
  static String markRead(String conversationId) => '/chat/conversations/$conversationId/read';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
}
