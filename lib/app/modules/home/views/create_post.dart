import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/home_controller.dart';
import 'select_memorial.dart';

class CreatePost extends GetView<HomeController> {
  CreatePost({super.key});

  // Declare and initialize the controllers properly.
  final ProfileController profileController = Get.put(ProfileController());
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      controller.pickedImage.value = File(pickedFile.path);
    }
  }

  Future<void> _pickVideoOrImageFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      controller.pickedImage.value = File(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure that profile is loaded only after the first frame is rendered.
      if (profileController.userProfile.value == null &&
          !profileController.isLoading.value) {
        profileController.fetchUserProfile();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        ),
        title: Text(
          'Create Post',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (profileController.isLoading.value &&
              profileController.userProfile.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = profileController.userProfile.value;
          if (profile == null) {
            // Show a lightweight retry/error UI
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profileController.errorMessage.value.isEmpty
                          ? 'No profile loaded yet.'
                          : profileController.errorMessage.value,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: profileController.fetchUserProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 25.r,
                      backgroundColor: AppColor.greyColor,
                      child: ClipOval(
                        child:
                            (profile.profilePhoto != null &&
                                    profile.profilePhoto!.isNotEmpty)
                                ? Image.network(
                                  profile.profilePhoto!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                                : Image.asset(
                                  ImageAssets.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                      ),
                    ),
                    title: Text(
                      profile.name,
                      style: TextStyle(
                        color: AppColor.textBlackColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  InputTextWidget(
                    onChanged: (String value) {
                      controller.content.value = value;
                    },
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    backgroundColor: Colors.transparent,
                    borderColor: Colors.transparent,
                    hintText: 'What’s on your mind?',
                    hintfontSize: 20.sp,
                    textColor: AppColor.greyTone,
                    width: 1.sw,
                    fontSize: 17.sp,
                    maxLines: 4,
                    height: 130,
                  ),
                  Obx(() {
                    final file = controller.pickedImage.value;
                    return controller.isMemorialSelected.value && file == null
                        ? Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 10.h,
                                horizontal: 20.w,
                              ),
                              child: Container(
                                height: 110.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: AppColor.softBeige),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10.w),
                                      child: Container(
                                        height: 80.h,
                                        width: 80.w,
                                        decoration: BoxDecoration(
                                          color: AppColor.blackColor,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          child:
                                              (profile.profilePhoto != null &&
                                                      profile
                                                          .profilePhoto!
                                                          .isNotEmpty)
                                                  ? Image.network(
                                                    profile.profilePhoto!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  )
                                                  : Image.asset(
                                                    ImageAssets.image,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile.name,
                                          style: TextStyle(
                                            color: AppColor.greyTone,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'December 12th, 1992',
                                          style: TextStyle(
                                            color: AppColor.greyTone,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          'June 1st, 2024',
                                          style: TextStyle(
                                            color: AppColor.greyTone,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: .020.sh,
                              right: .070.sw,
                              child: GestureDetector(
                                onTap: () {
                                  controller.isMemorialSelected.value = false;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.black5Color,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(4.w),
                                  child: Icon(
                                    Icons.close,
                                    color: AppColor.whiteColor,
                                    size: 15.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        : file != null
                        ? Stack(
                          children: [
                            SizedBox(
                              height: 300.h,
                              child: Image.file(file, fit: BoxFit.fitHeight),
                            ),
                            Positioned(
                              top: 10.h,
                              right: 10.w,
                              child: GestureDetector(
                                onTap: () {
                                  controller.pickedImage.value = null;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.black5Color,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(6.w),
                                  child: Icon(
                                    Icons.close,
                                    color: AppColor.whiteColor,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        : SizedBox.shrink();
                  }),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 10.h,
                  ),
                  color: AppColor.backgroundColor,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          Get.to(
                            SelectMemorial(),
                            transition: Transition.rightToLeft,
                          );
                          controller.pickedImage.value = null;
                        },
                        leading: Image.asset(
                          ImageAssets.memorial,
                          width: 40.w,
                          height: 40.h,
                        ),
                        title: Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            'Add Memorial',
                            style: TextStyle(
                              color: AppColor.textGreyColor,
                              fontSize: 18.sp,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        onTap: () {
                          _pickVideoOrImageFromGallery();
                          controller.isMemorialSelected.value = false;
                        },
                        leading: Image.asset(
                          ImageAssets.photoVideos,
                          width: 35.w,
                          height: 35.h,
                        ),
                        title: Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text(
                            'Photo/Video',
                            style: TextStyle(
                              color: AppColor.textGreyColor,
                              fontSize: 18.sp,
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
                          width: 35.w,
                          height: 35.h,
                        ),
                        title: Text(
                          'Camera',
                          style: TextStyle(
                            color: AppColor.textGreyColor,
                            fontSize: 18.sp,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Obx(
                        () => CustomButton(
                          onPress:
                              controller.isLoading.value
                                  ? null
                                  : () async {
                                    await controller.createPost();
                                  },
                          loading: controller.isLoading.value,
                          title: 'Post',
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
