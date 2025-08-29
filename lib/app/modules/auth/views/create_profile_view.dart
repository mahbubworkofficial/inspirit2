import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/authcameracontroller.dart';

class CreateProfileView extends GetView<AuthController> {
  final AuthBottomSheetController as=Get.put(AuthBottomSheetController());
  final ProfileController profileController = Get.put(ProfileController());
   CreateProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      SizedBox(height: 62.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create your Profile',
                            style: TextStyle(
                              color: AppColor.buttonColor,
                              fontSize: 24.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12.h),
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
                      Stack(
                        children: [
                          Obx(() {
                            profileController.pickedImage.value = as.pickedImage.value;
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(200.r),
                              child: profileController.pickedImage.value != null
                                  ? Image.file(
                                profileController.pickedImage.value!,
                                width: 120.w,
                                height: 120.w,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                width: 120.w,
                                height: 120.w,
                                color: AppColor.mutedBlueGrey,
                                child: Image.asset(ImageAssets.avatar,fit: BoxFit.cover,),
                              ),
                            );
                          }),
                          Positioned(
                            bottom: 0.h,
                            right: 0.w,
                            child: Container(
                              width: 30.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                color: AppColor.buttonColor,
                                borderRadius: BorderRadius.circular(100.r),
                              ),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.camera_alt,
                                    size: 18.sp,
                                    color: AppColor.whiteTextColor,
                                  ),
                                  onPressed: as.getBottomSheet,
                                  padding: EdgeInsets.all(4.w),
                                  constraints: BoxConstraints(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      InputTextWidget(
                        onChanged: (e) {},
                        borderColor: AppColor.backgroundColor,
                        hintText: 'Enter your name',
                        textColor: AppColor.textGreyColor2,
                        textEditingController: profileController.nameController,
                        height: 48,
                        width: 390,
                      ),
                      SizedBox(height: 20.h),
                      InputTextWidget(
                        onChanged: (e) {},
                        borderColor: AppColor.backgroundColor,
                        hintText: 'Create your user name',
                        textColor: AppColor.textGreyColor2,
                        height: 48,
                        textEditingController: profileController.userNameController,
                        width: 390,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi vitae libero libero. Quisque viverra semper eros.',
                        style: TextStyle(
                          color: AppColor.textGreyColor2,
                          fontSize: 14.5.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              Obx(
                    () => CustomButton(
                  onPress:
                  controller.isLoading.value
                      ? null // Disable button when loading
                      : () async {
                    await profileController.updateProfile();
                  },
                  loading: controller.isLoading.value,
                  title: 'Next',
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
