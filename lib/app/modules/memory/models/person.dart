class Person {
  final int id;
  final String fullName;
  final String? dateOfBirth;
  final String? dateOfDeath;
  final int? birthYear;
  final int? deathYear;
  final String description;
  final String? displayPicture;
  final String privacy;

  Person({
    required this.id,
    required this.fullName,
    this.dateOfBirth,
    this.dateOfDeath,
    this.birthYear,
    this.deathYear,
    required this.description,
    this.displayPicture,
    required this.privacy,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      dateOfBirth: json['date_of_birth'] as String?,
      dateOfDeath: json['date_of_death'] as String?,
      birthYear: json['birth_year'] as int?,
      deathYear: json['death_year'] as int?,
      description: json['description'] as String,
      displayPicture: json['display_picture'] as String?,
      privacy: json['privacy'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'date_of_birth': dateOfBirth,
    'date_of_death': dateOfDeath,
    'birth_year': birthYear,
    'death_year': deathYear,
    'description': description,
    'display_picture': displayPicture,
    'privacy': privacy,
  };
}