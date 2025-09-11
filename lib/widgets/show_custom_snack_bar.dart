import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../res/colors/app_color.dart';

void showCustomSnackBar({
  required String title,
  required String message,
  Color backgroundColor = AppColor.defaultColor,
  Color textColor = AppColor.textWhiteColor,
  // String? iconPath,
  Duration duration = const Duration(seconds: 2),
  bool isSuccess = true,
}) {
  Get.closeCurrentSnackbar();
  Get.rawSnackbar(
    messageText: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isSuccess
                  ? [
                    AppColor.defaultColor,
                    AppColor.defaultColor.withValues(alpha: 0.8),
                    // AppColor.defaultColor.withOpacity(0.8),
                  ]
                  : [AppColor.redColor,
                AppColor.redAlphaColor
                // Colors.red.withOpacity(0.8)
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black20Color,
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
         isSuccess ?
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child:
              Icon(Icons.check_circle_outline, color: textColor, size: 20.w),
            ):
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child:
              Icon(Icons.error_outline, color: textColor, size: 20.w),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16.sp,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message,
                  style: TextStyle(
                    // color: textColor.withOpacity(0.9),
                    color: textColor.withValues(alpha: 0.9),
                    fontSize: 14.sp,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    backgroundColor: Colors.transparent,
    duration: duration,
    animationDuration: const Duration(milliseconds: 300),
    snackPosition: SnackPosition.TOP,
    margin: EdgeInsets.all(16.w),
    borderRadius: 12.r,
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
  );
}
