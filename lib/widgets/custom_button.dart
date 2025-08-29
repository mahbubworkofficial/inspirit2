import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.buttonColor = AppColor.buttonColor,
    this.textColor = AppColor.whiteTextColor,
    this.subtextColor = AppColor.whiteTextColor,
    this.borderColor = AppColor.buttonColor,
    this.borderShadowColor = AppColor.black12Color,
    required this.onPress,
    this.height = 48,
    this.imageHeight = 25,
    this.imageWeight = 25,
    this.width = double.infinity,
    this.loading = false,
    this.center = true,
    this.icon = false,
    this.image = ImageAssets.fb,
    required this.title,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.fontFamily = 'Poppins',
    this.radius = 100,
    this.subtitle = '',
    this.subfontSize = 14,
    this.subfontWeight = FontWeight.w400,
    this.subfontFamily = 'Poppins',
  });

  final bool loading, center, icon;
  final String title, subtitle, fontFamily, subfontFamily, image;
  final double height,
      fontSize,
      radius,
      subfontSize,
      width,
      imageHeight,
      imageWeight;
  final Future<void> Function()? onPress;
  final Color textColor,
      subtextColor,
      buttonColor,
      borderColor,
      borderShadowColor;
  final FontWeight fontWeight, subfontWeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          // onPress
          (onPress != null && !loading) ? () => onPress!() : null,
      child: Container(
        height: height.h,
        width: width.w,
        decoration: ShapeDecoration(
          color: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.r),
            side: BorderSide(color: borderColor),
          ),
          // shadows: [
          //   BoxShadow(
          //     color: borderShadowColor,
          //     blurRadius: 4,
          //     offset: Offset(0, 0),
          //     spreadRadius: 0,
          //   ),
          // ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child:
              loading
                  ? Center(child: CircularProgressIndicator(color: textColor))
                  : center
                  ? Center(
                    child:
                        subtitle.isEmpty
                            ? Text(
                              title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: fontSize.sp,
                                fontWeight: fontWeight,
                                fontFamily: fontFamily,
                              ),
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: fontSize.sp,
                                    fontWeight: fontWeight,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    color: subtextColor,
                                    fontSize: subfontSize.sp,
                                    fontWeight: subfontWeight,
                                    fontFamily: subfontFamily,
                                  ),
                                ),
                              ],
                            ),
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (icon)
                        Padding(
                          padding: EdgeInsets.only(left: 8.w),
                          child: Image.asset(
                            image,
                            width: imageWeight,
                            height: imageHeight,
                          ),
                        ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: fontSize.sp,
                                fontWeight: fontWeight,
                                fontFamily: fontFamily,
                              ),
                            ),
                            if (subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: subfontSize.sp,
                                  fontWeight: subfontWeight,
                                  fontFamily: subfontFamily,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
