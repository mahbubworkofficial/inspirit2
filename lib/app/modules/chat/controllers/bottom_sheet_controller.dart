import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../res/colors/app_color.dart';


class BottomSheetController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  Rxn<File> pickedImage = Rxn<File>();

  void getBottomSheet() {
    Get.bottomSheet(
      Container(
        margin: EdgeInsets.all(20),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColor.softBeige,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt, size: 50, color: AppColor.buttonColor),
                ),
                Text('Camera',
                    style: TextStyle(
                        fontSize: 20, color: AppColor.whiteColor, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _pickVideoOrImageFromGallery(),
                  icon: Icon(Icons.photo_library_rounded, size: 50, color: AppColor.buttonColor),
                ),
                Text('Gallery',
                    style: TextStyle(
                        fontSize: 20, color: AppColor.whiteColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      pickedImage.value = File(pickedFile.path);
    }
  }

  Future<void> _pickVideoOrImageFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      pickedImage.value = File(file.path) ;
    }
  }
}