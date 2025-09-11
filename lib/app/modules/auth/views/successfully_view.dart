import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/colors/app_color.dart';
import '../../../../widgets/show_custom_snack_bar.dart';
import '../../home/views/navbar.dart';

class SuccessfullyView extends GetView {
  const SuccessfullyView({super.key});
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      try {
        Get.offAll(() => Navigation(), transition: Transition.noTransition);
      } catch (e) {
        showCustomSnackBar(
          title: 'Navigation Error',
          message: 'Failed to navigate to Home screen: $e',
          isSuccess: false,
        );
      }
    });
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Successfully Subscribed',
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
