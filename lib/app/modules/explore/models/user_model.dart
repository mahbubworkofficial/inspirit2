class UserModel {
  final int id;
  final String? username;
  final String? name;
  final String email;
  final String? profilePhoto;
  final String? about;
  final String? subscriptionStatus;
  final bool isVerified;
  final String? facebookId;
  final String? instagramId;
  final String? twitterId;
  final String? threadId;
  final DateTime dateJoined;
  final int friendsCount;
  final bool isFriend;

  UserModel({
    required this.id,
    this.username,
    this.name,
    required this.email,
    this.profilePhoto,
    this.about,
    this.subscriptionStatus,
    required this.isVerified,
    this.facebookId,
    this.instagramId,
    this.twitterId,
    this.threadId,
    required this.dateJoined,
    required this.friendsCount,
    required this.isFriend,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      email: json['email'],
      profilePhoto: json['profile_photo'],
      about: json['about'],
      subscriptionStatus: json['subscription_status'],
      isVerified: json['is_verified'] ?? false,
      facebookId: json['facebook_id'],
      instagramId: json['instagram_id'],
      twitterId: json['twitter_id'],
      threadId: json['thread_id'],
      dateJoined: DateTime.parse(json['date_joined']),
      friendsCount: json['friends_count'] ?? 0,
      isFriend: json['is_friend'] ?? false,
    );
  }
}
