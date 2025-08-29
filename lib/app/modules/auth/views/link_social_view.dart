import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../controllers/auth_controller.dart';
import 'plan_view.dart';

class LinkSocialView extends GetView<AuthController> {
  const LinkSocialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Image.asset(ImageAssets.backArrow),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Link your Social Media',
                            style: TextStyle(
                              color: AppColor.buttonColor,
                              fontSize: 24,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                            style: TextStyle(
                              color: AppColor.textGreyColor2,
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      CustomButton(
                        onPress: () async {
                          // Get.to(
                          //   VerifyEmailView(),
                          //   transition: Transition.noTransition,
                          // );
                        },
                        title: 'Connect Facebook',
                        height: 48,
                        width: 390,
                        radius: 10,
                        center: false,
                        icon: true,
                        buttonColor: AppColor.textAreaColor,
                        textColor: AppColor.greyTone1,
                      ),
                      SizedBox(height: 20.h),
                      CustomButton(
                        onPress: () async {
                          // Get.to(
                          //   VerifyEmailView(),
                          //   transition: Transition.noTransition,
                          // );
                        },
                        title: 'Connect Instagram',
                        height: 48,
                        width: 390,
                        radius: 10,
                        center: false,
                        icon: true,
                        image: ImageAssets.inst,
                        buttonColor: AppColor.textAreaColor,
                        textColor: AppColor.greyTone1,
                      ),
                      SizedBox(height: 20.h),
                      CustomButton(
                        onPress: () async {
                          // Get.to(
                          //   VerifyEmailView(),
                          //   transition: Transition.noTransition,
                          // );
                        },
                        title: 'Connect X(Twitter)',
                        height: 48,
                        width: 390,
                        radius: 10.r,
                        center: false,
                        icon: true,
                        image: ImageAssets.x,
                        buttonColor: AppColor.textAreaColor,
                        textColor: AppColor.greyTone1,
                      ),
                      SizedBox(height: 20.h),
                      CustomButton(
                        onPress: () async {
                          // Get.to(
                          //   VerifyEmailView(),
                          //   transition: Transition.noTransition,
                          // );
                        },
                        title: 'Connect Thread',
                        height: 48,
                        width: 390,
                        radius: 10.r,
                        center: false,
                        icon: true,
                        image: ImageAssets.thread,
                        buttonColor: AppColor.textAreaColor,
                        textColor: AppColor.greyTone1,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              CustomButton(
                onPress: () async {
                  Get.to(PlanView(), transition: Transition.noTransition);
                },
                title: 'Next',
                height: 48,
                width: 390,
                radius: 100.r,
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }
}
