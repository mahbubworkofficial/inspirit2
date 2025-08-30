class Condolence {
  final int id;
  final int user;
  final String name;
  final String username;
  final String? profilePhoto;
  final String condolenceMessage;
  final String createdAt;

  Condolence({
    required this.id,
    required this.user,
    required this.name,
    required this.username,
    this.profilePhoto,
    required this.condolenceMessage,
    required this.createdAt,
  });

  factory Condolence.fromJson(Map<String, dynamic> json) {
    return Condolence(
      id: json['id'] as int,
      user: json['user'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      profilePhoto: json['profile_photo'] as String?,
      condolenceMessage: json['condolence_message'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'name': name,
    'username': username,
    'profile_photo': profilePhoto,
    'condolence_message': condolenceMessage,
    'created_at': createdAt,
  };
}