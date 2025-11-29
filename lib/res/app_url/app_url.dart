class AppUrl {
  static const String _baseUrl =
      'https://noncircuitous-lauryn-pseudosocialistic.ngrok-free.dev/api';
  static const String _webSocketUrl =
      'wss://noncircuitous-lauryn-pseudosocialistic.ngrok-free.dev/users';
  static const String loginUrl = '$_baseUrl/users/login/';
  static const String refreshUrl = '$_baseUrl/users/token/refresh/';
  static const String setPassword = '$_baseUrl/users/password/reset/';
  static const String signUpWithOtherUrl = '$_baseUrl/users/social/login/';
  static const String signup = '$_baseUrl/users/register/';
  static const String forget = '$_baseUrl/users/password/reset/request/';
  static const String verifyOtp = '$_baseUrl/users/verify-otp/';
  static const String verifyOtp1 = '$_baseUrl/users/password/reset/confirm/';
  static const String resendOtp = '$_baseUrl/users/resend-otp/';
  static const String resendOtp1 = '$_baseUrl/users/password/reset/request/';
  static const String updateProfileUrl = '$_baseUrl/users/update/';
  static const String getAllPackageInformationUrl = '$_baseUrl/plans/';
  static const String buySubscriptionUrl = '$_baseUrl/create-subscription/';
  static const String cancelSubscriptionUrl = '$_baseUrl/subscriptions';
  static const String getProfileUrl = '$_baseUrl/users/profile/';
  static const String createPostUrl = '$_baseUrl/posts/';
  static const String getPostUrl = '$_baseUrl/posts/';
  static const String getOthersPostUrl = '$_baseUrl/posts/feed/';
  static const String likeUrl = '$_baseUrl/posts/';
  static const String friendsListUrl = '$_baseUrl/users/friends/';
  static const String usersListUrl = '$_baseUrl/users/all-profiles/';
  static const String fetchUserPostsUrl = '$_baseUrl/posts/profile';
  static const String friendRequestUrl = '$_baseUrl/users/friend-requests/';
  static const String commentUrl = '$_baseUrl/comments_on_post';
  static const String commentReactUrl = '$_baseUrl/comments';
  static const String chatRoomsUrl = '$_baseUrl/chat-rooms/';
  static const String memoryUrl = '$_baseUrl/memories/';
  static const String eventUrl = '$_baseUrl/events/';
  static const String personUrl = '$_baseUrl/persons/';
  static const String chatUrl = '$_baseUrl/chat-rooms/';
  static const String messagesUrl = '$_webSocketUrl/chat';
  static const String treeUrl = '$_baseUrl/family-tree/';
  static const String condolenceUrl = '$_baseUrl/condolences/';







  static const String fetchProfilesUrl = '$_baseUrl/user/profiles/';
  static const String profilesFilterUrl = '$_baseUrl/profiles/filter/';
  static const String getProfileByIdUrl = '$_baseUrl/user/profile';
  static const String deleteGalleryImageUrl = '$_baseUrl/user/delete-photos';
  // Chat endpoints
  static const String createChatRoomUrl = '$_baseUrl/chat/create/';
  static const String sendMessageUrl = '$_baseUrl/chat/room';
  static const String getMessagesUrl = '$_baseUrl/chat/room';
  static const String deleteMessageUrl = '$_baseUrl/chat/room';
  static const String registerFcmTokenUrl = '$_baseUrl/fcm/register/';
  static const String respondToInvitationUrl = '$_baseUrl/chat/invitations';
  static const String sendChatInvitationUrl =
      '$_baseUrl/chat/invitations/send/';
  static const String getChatsUrl = '$_baseUrl/chat/rooms/';

  static const String getInvitationsUrl =
      '$_baseUrl/chat/invitations/received/';
}
