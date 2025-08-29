import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.textColor,
      body: Stack(
        children: [
          // Video background or fallback image
          Obx(() {
            final ready = controller.isVideoInitialized.value &&
                controller.videoController.value.isInitialized;
            if (!ready) return const Center(child: CircularProgressIndicator());
            return SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.videoController.value.size.width,
                  height: controller.videoController.value.size.height,
                  child: VideoPlayer(controller.videoController),
                ),
              ),
            );
          }),

          // Overlay for readability
          Container(color: AppColor.black10),

          // UI elements
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 190.w,
                    height: 180.h,
                    child: Image.asset(
                      ImageAssets.onboardLogo,
                      color: AppColor.blackColor,
                    ),
                  ),
                  const Spacer(),
                  SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Celebrate Lives, Keep\nMemories Alive',
                            style: TextStyle(
                              color: AppColor.blackColor,
                              fontSize: 28.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'INSPIRIT helps you honor your loved ones through beautiful, lasting digital memorials. Share stories, photos, and memories that live on—forever connected to family, friends, and future generations.',
                            style: TextStyle(
                              color: AppColor.blackColor,
                              fontSize: 18.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 30.h),
                          CustomButton(
                            title: 'NEXT',
                            onPress: () async {
                              controller.goto();
                            },
                            borderColor: AppColor.darkGrey,
                            buttonColor: AppColor.blackColor,
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
