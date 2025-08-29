class UserProfile {
  final int id;
  final String username;
  final String name;
  final String email;
  final String? about;
  final String? profilePhoto;
  final String? subscriptionStatus;
  final bool isVerified;
  final String? facebookId;
  final String? instagramId;
  final String? twitterId;
  final String? threadId;
  final DateTime dateJoined;
  final int friendsCount;
  final bool isFriend;

  UserProfile({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.profilePhoto,
    this.subscriptionStatus,
    required this.isVerified,
    this.facebookId,
    this.instagramId,
    this.twitterId,
    this.threadId,
    this.about,
    required this.dateJoined,
    required this.friendsCount,
    required this.isFriend,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      username: json['username'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      about: json['about'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      subscriptionStatus: json['subscription_status'] as String?,
      isVerified:  bool.parse(json['is_verified'].toString()),
      facebookId: json['facebook_id'] as String?,
      instagramId: json['instagram_id'] as String?,
      twitterId: json['twitter_id'] as String?,
      threadId: json['thread_id'] as String?,
      dateJoined: DateTime.parse(json['date_joined'] as String),
      friendsCount: int.parse(json['friends_count'].toString()), // Handle String or int
      isFriend: bool.parse(json['is_friend'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'about': about,
      'profile_photo': profilePhoto,
      'subscription_status': subscriptionStatus,
      'is_verified': isVerified,
      'facebook_id': facebookId,
      'instagram_id': instagramId,
      'twitter_id': twitterId,
      'thread_id': threadId,
      'date_joined': dateJoined.toIso8601String(),
      'friends_count': friendsCount,
      'is_friend': isFriend,
    };
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, username: $username, name: $name, email: $email, '
        'about: $about, profilePhoto: $profilePhoto, isVerified: $isVerified, '
        'friendsCount: $friendsCount, isFriend: $isFriend)';
  }
}