import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/dialogue.dart';
import '../../../../widgets/input_text_widget.dart';
import '../../auth/controllers/auth_controller.dart';

class PassChange extends GetView<AuthController> {
  const PassChange({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leadingWidth: 30,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                      style: TextStyle(
                        color: AppColor.textGreyColor2,
                        fontSize: 18,
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
                  hintText: 'Enter your password',
                  leadingIcon: ImageAssets.pass,
                  leading: true,
                  obscureText: true,
                  textColor: AppColor.textGreyColor2,
                  height: 48,
                  width: 390,
                ),
                SizedBox(height: 20.h),
                InputTextWidget(
                  onChanged: (e) {},
                  borderColor: AppColor.backgroundColor,
                  hintText: 'Create your password',
                  leadingIcon: ImageAssets.pass,
                  leading: true,
                  obscureText: true,
                  textColor: AppColor.textGreyColor2,
                  height: 48,
                  width: 390,
                ),
                SizedBox(height: 15.h),
                InputTextWidget(
                  onChanged: (e) {},
                  borderColor: AppColor.backgroundColor,
                  hintText: 'Confirm your password',
                  leadingIcon: ImageAssets.pass,
                  leading: true,
                  obscureText: true,
                  textColor: AppColor.textGreyColor2,
                  height: 48,
                  width: 390,
                ),
                SizedBox(height: 65.h),
                CustomButton(
                  onPress: () async {
                    Get.back();
                    showDialog(
                      context: context,
                      builder:
                          (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            child: CenteredDialogWidget(
                              title: 'Password Changed',
                              subtitle:
                                  'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim',
                              imageAsset:
                                  ImageAssets.postReport, // Use your own SVG
                              backgroundColor:
                                  AppColor.backgroundColor, // Custom background
                              iconBackgroundColor: Colors.transparent,
                              iconColor:
                                  AppColor
                                      .buttonColor, // Custom icon background
                              borderRadius: 30.0,
                              horizontalPadding: 2.w, // Custom corner radius
                            ),
                          ),
                    );
                  },
                  title: 'Update Password',
                  height: 48,
                  width: 390,
                  radius: 100,
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
