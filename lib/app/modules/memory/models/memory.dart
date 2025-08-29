
import 'person.dart';

class EventImage {
  final int id;
  final String image;

  EventImage({required this.id, required this.image});

  factory EventImage.fromJson(Map<String, dynamic> json) {
    return EventImage(
      id: json['id'] as int,
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image': image,
  };
}

class Memory {
  final int id;
  final int user;
  final Person person;
  final String title;
  final String dateOfMemory;
  final String description;
  final List<EventImage> images;
  final String? qrCode;
  final String createdAt;
  final String updatedAt;

  Memory({
    required this.id,
    required this.user,
    required this.person,
    required this.title,
    required this.dateOfMemory,
    required this.description,
    required this.images,
    this.qrCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'] as int,
      user: json['user'] as int,
      person: Person.fromJson(json['person'] as Map<String, dynamic>),
      title: json['title'] as String,
      dateOfMemory: json['date_of_memory'] as String,
      description: json['description'] as String,
      images: (json['images'] as List<dynamic>)
          .map((item) => EventImage.fromJson(item as Map<String, dynamic>))
          .toList(),
      qrCode: json['qr_code'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'person': person.toJson(),
    'title': title,
    'date_of_memory': dateOfMemory,
    'description': description,
    'images': images.map((image) => image.toJson()).toList(),
    'qr_code': qrCode,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}