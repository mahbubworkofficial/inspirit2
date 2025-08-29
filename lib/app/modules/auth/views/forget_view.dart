import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/auth_controller.dart';

class ForgetView extends GetView<AuthController> {
  const ForgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.05.sw),
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
                      'Forgot Password',
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
                  textEditingController: controller.forgetEmailController,
                  textColor: AppColor.textGreyColor2,
                  leading: true,
                  height: 48,
                  width: 390,
                ),
                SizedBox(height: 60.h),
                Obx(
                  () => CustomButton(
                    onPress:
                        controller.isLoading.value
                            ? null
                            : () async {
                              await controller.forget();
                            },
                    loading: controller.isLoading.value,
                    title: 'Next',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
