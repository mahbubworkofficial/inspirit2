import 'package:get/get.dart';

class FamilyMember {
  final String id;
  final String name;
  Rx<String?> image;

  FamilyMember({required this.id, required this.name, String? initialImage})
      : image = Rx<String?>(initialImage);
}