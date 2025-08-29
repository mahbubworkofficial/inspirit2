class Friend {
  final int id;
  final int userId;
  final String username;
  final String name;
  final String profilePhoto;
  final String status;
  final String type;

  Friend({
    required this.id,
    required this.userId,
    required this.username,
    required this.name,
    required this.profilePhoto,
    required this.status,
    required this.type,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      profilePhoto: json['profile_photo'] ?? '',
      status: json['status'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
