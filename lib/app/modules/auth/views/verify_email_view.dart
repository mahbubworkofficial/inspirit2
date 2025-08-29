import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../auth/controllers/auth_controller.dart';

class VerifyEmailView extends GetView<AuthController> {
  VerifyEmailView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                          'Confirm your Email',
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
                    SizedBox(
                      height: 48.h,
                      width: 390.w,
                      child: PinCodeTextField(
                        appContext: context,
                        hintCharacter: "_",
                        length: 6,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        textStyle: TextStyle(
                          color: AppColor.textBlackColor,
                          fontSize: 16.sp,
                        ),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10.r),
                          fieldHeight: 48.h,
                          fieldWidth: 48.h,
                          activeFillColor: AppColor.textAreaColor,
                          inactiveFillColor: AppColor.textAreaColor,
                          selectedFillColor: AppColor.textAreaColor,
                          activeColor: AppColor.textAreaColor,
                          inactiveColor: AppColor.textAreaColor,
                          selectedColor: AppColor.buttonColor,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        onChanged: (value) {
                          controller.updateOtp(value);
                        },
                        onCompleted: (value) {
                          controller.updateOtp(value);
                          // controller.verifyOtp(value);
                        },
                        validator: (value) {
                          if (value == null || value.length != 6) {
                            return '';
                          }
                          if (!GetUtils.isNumericOnly(value)) {
                            return '';
                            // 'OTP must be numeric';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 52.h),
                    GestureDetector(
                      onTap: () {
                        controller.resendOtp();
                      },
                      child: Text(
                        'Send again',
                        style: TextStyle(
                          color: AppColor.textSendColor,
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Obx(() => CustomButton(
                      onPress: controller.isLoading.value
                          ? null // Disable button when loading
                          : () async {
                        await controller.verifyOtp();
                      },
                      loading: controller.isLoading.value,
                      title: 'SIGN UP',
                    )),
                    SizedBox(height: 20.h), // Extra padding to prevent cutoff
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}