import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/show_custom_snack_bar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/views/create_profile_view.dart';
import '../../home/views/navbar.dart';
import 'onboarding_view.dart';

class SplashView extends GetView<AuthController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      try {
        if (controller.isLoggedIn.value && controller.isSignedIn.value) {
          Get.off(() => Navigation());
        } else if (!controller.isLoggedIn.value && controller.isSignedIn.value) {
          Get.off(() => CreateProfileView());
        } else {
          Get.off(() => OnboardingView());
        }
      } catch (e) {
        showCustomSnackBar(
          title: 'Navigation Error',
          message: 'Failed to navigate to Home screen: $e',
          isSuccess: false,
        );
      }
    });
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: Center(
        child: Image.asset(ImageAssets.splash, width: 190.w, height: 180.h),
      ),
    );
  }
}
