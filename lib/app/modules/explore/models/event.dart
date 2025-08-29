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

class Event {
  final int id;
  final int user;
  final String eventType;
  final String title;
  final String date;
  final String time;
  final String location;
  final String details;
  final List<EventImage> images;
  final String createdAt;
  final String updatedAt;

  Event({
    required this.id,
    required this.user,
    required this.eventType,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.details,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      user: json['user'] as int,
      eventType: json['event_type'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      location: json['location'] as String,
      details: json['details'] as String,
      images: (json['images'] as List<dynamic>)
          .map((item) => EventImage.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'event_type': eventType,
    'title': title,
    'date': date,
    'time': time,
    'location': location,
    'details': details,
    'images': images.map((image) => image.toJson()).toList(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}