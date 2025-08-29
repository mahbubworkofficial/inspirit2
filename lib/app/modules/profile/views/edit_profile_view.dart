import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../../auth/controllers/authcameracontroller.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  EditProfileView({super.key});
  final AuthBottomSheetController as = Get.put(AuthBottomSheetController());

  @override
  Widget build(BuildContext context) {
    debugPrint(controller.profilePhoto.value);

    // at top of build:
    final dpr = MediaQuery.of(context).devicePixelRatio;

    // Prefer a helper to safely round only when finite
    int? safeRound(double v) => (v.isFinite && v > 0) ? v.round() : null;

    // Calculate side with fallback if ScreenUtil returns NaN/∞ or ≤0
    double side = 120.r;
    if (!side.isFinite || side <= 0) side = 120.0;

    // Later in the avatar:
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        ),
        title: Text(
          'Edit Profile ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          Text(
                            'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                            style: TextStyle(
                              color: AppColor.textGreyColor2,
                              fontSize: 16.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: side,
                        height: side,
                        child: Stack(
                          children: [
                            Obx(() {
                              controller.pickedImage.value = as.pickedImage.value;
                              final url = controller.profilePhoto.value;

                              Widget imageChild;
                              if (controller.pickedImage.value != null) {
                                imageChild = Image.file(
                                  controller.pickedImage.value!,
                                  width: side,
                                  height: side,
                                  fit: BoxFit.cover,
                                );
                              } else if (url.isNotEmpty) {
                                final cw = safeRound(side * dpr);
                                final ch = safeRound(side * dpr);

                                imageChild = CachedNetworkImage(
                                  imageUrl: url,
                                  width: side,
                                  height: side,
                                  fit: BoxFit.cover,
                                  // Only pass memCache* if finite
                                  memCacheWidth: cw,
                                  memCacheHeight: ch,
                                  placeholder:
                                      (context, _) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  errorWidget:
                                      (context, _, _) => Image.asset(
                                        ImageAssets.avatar,
                                        width: side,
                                        height: side,
                                        fit: BoxFit.cover,
                                      ),
                                );
                              } else {
                                imageChild = Image.asset(
                                  ImageAssets.avatar,
                                  width: side,
                                  height: side,
                                  fit: BoxFit.cover,
                                );
                              }

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(side / 2),
                                child: imageChild,
                              );
                            }),

                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: SizedBox(
                                width: 30.r.isFinite && 30.r > 0 ? 30.r : 30,
                                height: 30.r.isFinite && 30.r > 0 ? 30.r : 30,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColor.buttonColor,
                                    borderRadius: BorderRadius.circular(
                                      100.r.isFinite ? 100.r : 100,
                                    ),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: as.getBottomSheet,
                                    icon: Icon(
                                      Icons.camera_alt,
                                      size:
                                          18.r.isFinite && 18.r > 0 ? 18.r : 18,
                                      color: AppColor.whiteTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                              color: AppColor.textGreyColor2,
                              fontSize: 16.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              height: 1.50,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          InputTextWidget(
                            onChanged: (e) {e=controller.name.value;},
                            borderColor: AppColor.backgroundColor,
                            textEditingController: controller.nameController,
                            hintText:
                                controller.name.isEmpty
                                    ? 'Enter your name'
                                    : controller.name.value,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Username',
                            style: TextStyle(
                              color: AppColor.textGreyColor2,
                              fontSize: 16.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              height: 1.50,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          InputTextWidget(
                            onChanged: (e) {e=controller.userName.value;},
                            borderColor: AppColor.backgroundColor,
                            textEditingController:
                                controller.userNameController,
                            hintText:
                                controller.userName.isEmpty
                                    ? 'Enter your username'
                                    : controller.userName.value,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'About',
                            style: TextStyle(
                              color: AppColor.textGreyColor2,
                              fontSize: 16.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              height: 1.50,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          InputTextWidget(
                            onChanged: (e) {e=controller.about.value;},
                            borderColor: AppColor.backgroundColor,
                            textEditingController: controller.aboutController,
                            hintText:
                                controller.about.isEmpty
                                    ? 'Update about your self'
                                    : controller.about.value,
                            height: 120.h,
                            maxLines: 10,
                            contentPadding: true,
                            vertical: 10.h,
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi vitae libero libero. Quisque viverra semper eros.',
                        style: TextStyle(
                          color: AppColor.textGreyColor3,
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomButton(
                title: 'UPDATE',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                onPress: () async {
                  controller.updateProfile1();
                },
                buttonColor: AppColor.buttonColor,
                height: 48,
                width: double.infinity,
                radius: 30.r,
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }
}
