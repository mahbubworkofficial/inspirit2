import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/auth_controller.dart';
import 'forget_view.dart';

class SignInView extends GetView<AuthController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10.h),
              Center(child: Image.asset(ImageAssets.authLogo)),
              SizedBox(height: 20.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign In',
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
                hintText: 'Enter your email',
                leadingIcon: ImageAssets.email,
                textEditingController: controller.emailController,
                textColor: AppColor.textGreyColor2,
                leading: true,
                height: 48.h,
                width: double.infinity,
              ),
              SizedBox(height: 15.h),
              InputTextWidget(
                onChanged: (e) {},
                borderColor: AppColor.backgroundColor,
                hintText: 'Enter your password',
                leadingIcon: ImageAssets.pass,
                leading: true,
                textEditingController: controller.passwordController,
                obscureText: true,
                textColor: AppColor.textGreyColor2,
                height: 48.h,
                width: double.infinity,
              ),
              SizedBox(height: 30.h),
              Obx(
                () => CustomButton(
                  onPress:
                      controller.isLoading.value
                          ? null
                          : () async {
                            await controller.login();
                          },
                  loading: controller.isLoading.value,
                  title: 'SIGN UP',
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(
                          ForgetView(),
                          transition: Transition.rightToLeftWithFade,
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColor.greyTone1,
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don’t have an account?',
                    style: TextStyle(
                      color: AppColor.textGreyColor3,
                      fontSize: 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Text(
                      ' Sign Up',
                      style: TextStyle(
                        color: AppColor.buttonColor,
                        fontSize: 16.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                'or',
                style: TextStyle(
                  color: AppColor.greyTone1,
                  fontSize: 20.sp,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Continue with',
                style: TextStyle(
                  color: AppColor.greyTone1,
                  fontSize: 16.sp,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 25.h),
              Wrap(
                spacing: 20.w,
                alignment: WrapAlignment.center,
                children: [
                  SvgPicture.asset(
                    ImageAssets.google,
                    height: 42.h,
                    width: 78.w,
                  ),
                  SvgPicture.asset(
                    ImageAssets.facebook,
                    height: 42.h,
                    width: 78.w,
                  ),
                  SvgPicture.asset(
                    ImageAssets.apple,
                    height: 42.h,
                    width: 78.w,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
