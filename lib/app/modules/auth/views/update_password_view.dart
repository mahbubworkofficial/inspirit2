import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/auth_controller.dart';

class UpdatePasswordView extends GetView<AuthController> {
  const UpdatePasswordView({super.key});

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
              SizedBox(height: 30.h),
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Image.asset(ImageAssets.backArrow),
                  ),
                  Center(child: Image.asset(ImageAssets.authLogo)),
                ],
              ),
              SizedBox(height: 20.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Password',
                    style: TextStyle(
                      color: AppColor.buttonColor,
                      fontSize: 24.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
              InputTextWidget(
                onChanged: (e) {},
                borderColor: AppColor.backgroundColor,
                hintText: 'Create your password',
                leadingIcon: ImageAssets.pass,
                leading: true,
                textEditingController: controller.setPasswordController,
                obscureText: true,
                textColor: AppColor.textGreyColor2,
                height: 48.h,
                width: 390.w,
              ),
              SizedBox(height: 15.h),
              InputTextWidget(
                onChanged: (e) {},
                borderColor: AppColor.backgroundColor,
                hintText: 'Confirm your password',
                leadingIcon: ImageAssets.pass,
                textEditingController: controller.confirmPasswordController,
                leading: true,
                obscureText: true,
                textColor: AppColor.textGreyColor2,
                height: 48.h,
                width: 390.w,
              ),
              SizedBox(height: 65.h),
              Obx(
                () => CustomButton(
                  onPress:
                      controller.isLoading.value
                          ? null
                          : () async {
                            await controller.setPassword();
                          },
                  loading: controller.isLoading.value,
                  title: 'Update Password',
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
