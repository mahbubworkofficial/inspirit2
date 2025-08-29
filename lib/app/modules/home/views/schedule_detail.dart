import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/delete_confirmation_widget.dart';
import '../../../../widgets/dialogue.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/home_controller.dart';

class ScheduleDetail extends GetView<HomeController> {
  ScheduleDetail({super.key});

  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      controller.pickedImageschedule.value = File(pickedFile.path);
    }
  }

  Future<void> _pickVideoOrImageFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      controller.pickedImageschedule.value = File(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showDeleteConfirmationPopup(
                context: context,
                title: 'Are You Sure?',
                subtitle:
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse elementum ',
                onDelete: () {
                  // Your delete logic here
                  // print("Deleted");
                },
                arguments: 'HomeView',
              );
            },
            icon: Icon(CupertinoIcons.delete, color: AppColor.textBlackColor),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Schedule Post Detail',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi vitae libero libero. Quisque viverra semper eros in ultrices. Cras vel augue tristique, gravida nulla a, blandit ex.',
                    style: TextStyle(color: AppColor.greyTone, fontSize: 18),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(height: 10),
                Obx(() {
                  final file = controller.pickedImageschedule.value;
                  return SizedBox(
                    height: 250,
                    width: double.infinity,
                    child:
                        file != null
                            ? Image.file(file, fit: BoxFit.cover)
                            : Image.asset(
                              ImageAssets.person,
                              fit: BoxFit.cover,
                            ),
                  );
                }),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 15.h,
                  ),
                  child: Column(
                    children: [
                      InputTextWidget(
                        onChanged: (value) {},
                        backgroundColor: AppColor.textAreaColor,
                        borderColor: Colors.transparent,
                        hintText: '23-04-2025',
                        hintTextColor: AppColor.greyTone,
                        backimageadd: true,
                        backimage: ImageAssets.calender3,
                      ),
                      SizedBox(height: 10.h),
                      InputTextWidget(
                        onChanged: (value) {},
                        backgroundColor: AppColor.textAreaColor,
                        borderColor: Colors.transparent,
                        hintText: '12:30',
                        hintTextColor: AppColor.greyTone,

                        backimageadd: true,
                        backimage: ImageAssets.time,
                      ),

                      SizedBox(height: 15.h),
                      ListTile(
                        onTap: () {
                          _pickVideoOrImageFromGallery();
                          controller.isMemorialSelected.value = false;
                        },
                        leading: Image.asset(
                          ImageAssets.photoVideos,
                          width: 35,
                          height: 35,
                        ),
                        title: Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text(
                            'Photo/Video',
                            style: TextStyle(
                              color: AppColor.textGreyColor,
                              fontSize: 18,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        onTap: () {
                          _pickImage(ImageSource.camera);
                          controller.isMemorialSelected.value = false;
                        },
                        leading: Image.asset(
                          ImageAssets.camera,
                          width: 35,
                          height: 35,
                        ),
                        title: Text(
                          'Camera',
                          style: TextStyle(
                            color: AppColor.textGreyColor,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      CustomButton(
                        title: 'Save',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        onPress: () async {
                          showDialog(
                            context: context,
                            builder:
                                (context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: CenteredDialogWidget(
                                    title: 'Schedule Post Saved',

                                    subtitle:
                                        'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim',
                                    imageAsset: ImageAssets.postReport,
                                    backgroundColor: AppColor.backgroundColor,
                                    iconBackgroundColor: Colors.transparent,
                                    iconColor: AppColor.buttonColor,
                                    borderRadius: 30.0.r,
                                  ),
                                ),
                          );
                        },
                        buttonColor: AppColor.buttonColor,
                        height: 50,
                        radius: 30.r,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
