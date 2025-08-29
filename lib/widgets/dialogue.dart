import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../res/colors/app_color.dart';

class CenteredDialogWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageAsset;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final double borderRadius;
  final VoidCallback? onClose;
  final double horizontalPadding;
  final double verticalPadding;

  const CenteredDialogWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    this.horizontalPadding = 1,
    this.verticalPadding = 16.0,
    this.backgroundColor = AppColor.background1Color,
    this.iconBackgroundColor = AppColor.default2Color,
    this.iconColor = AppColor.whiteColor,
    this.borderRadius = 32.0,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColor.black10,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SVG Icon with circular background
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: SvgPicture.asset(imageAsset)),
            ),
            SizedBox(height: 24.h),

            // Title text
            Text(
              title,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.buttonColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),

            // Subtitle text
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColor.grey700Color,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
