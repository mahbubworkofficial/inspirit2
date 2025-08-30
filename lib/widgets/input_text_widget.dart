import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../res/assets/image_assets.dart';
import '../res/colors/app_color.dart';

class InputTextController extends GetxController {
  final RxBool isObscured;
  final TextEditingController textController;
  final bool _isInternalController;

  InputTextController({
    required this.textController,
    required bool obscureText,
    bool isInternalController = false,
  })  : isObscured = obscureText.obs,
        _isInternalController = isInternalController;

  void toggleObscure() {
    isObscured.value = !isObscured.value;
  }

  void updateText(String text) {
    textController.text = text;
  }

  @override
  void onClose() {
    if (_isInternalController) {
      textController.dispose();
    }
    super.onClose();
  }
}

class InputTextWidget extends StatelessWidget {
  const InputTextWidget({
    super.key,
    this.hintText = '',
    this.backicontap2,
    this.backicontap,
    required this.onChanged,
    this.onTap,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.leading = false,
    this.backIcon = false,
    this.backIcon2 = false,
    this.leadingIcon = ImageAssets.email,
    this.imageIcon = '',
    this.backimage = '',
    this.backimagetap,
    this.backimageadd = false,
    this.contentPadding = true,
    this.clock = false,
    this.scan = false,
    this.passwordIcon = ImageAssets.secure,
    this.borderRadius = 10.0,
    this.borderColor = AppColor.borderColor,
    this.hintTextColor = AppColor.textGreyColor2,
    this.textColor = AppColor.textGreyColor2,
    this.leadingHeight = 14.0,
    this.leadingWidth = 17.0,
    this.height = 48.0,
    this.width = double.infinity,
    this.hintfontFamily = 'Montserrat',
    this.hintfontSize = 16.0,
    this.hintfontWeight = FontWeight.w300,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.fontFamily = 'Montserrat',
    this.vertical = 0.0,
    this.horizontal = 15.0,
    this.leadingright = 0.0,
    this.leadingtop = 0.0,
    this.leadingleft = 10.0,
    this.backimagewidth = 24.0,
    this.backimageheight = 24.0,
    this.backgroundColor = AppColor.textAreaColor,
    this.leadingColor = AppColor.textGreyColor2,
    this.maxLines = 1,
    this.textEditingController,
  });

  final String hintText, hintfontFamily, fontFamily;
  final double borderRadius, fontSize, hintfontSize, leadingHeight, leadingWidth,
      leadingright, leadingtop, leadingleft, backimagewidth, backimageheight;
  final Color borderColor, textColor, hintTextColor, backgroundColor, leadingColor;
  final double height, width, horizontal, vertical;
  final bool obscureText, readOnly, contentPadding, leading, clock, scan, backIcon,
      backIcon2, backimageadd;
  final String passwordIcon, leadingIcon, imageIcon, backimage;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap, backicontap, backicontap2, backimagetap;
  final String? Function(String?)? validator;
  final FontWeight fontWeight, hintfontWeight;
  final int maxLines;
  final TextEditingController? textEditingController;

  @override
  Widget build(BuildContext context) {
    // Initialize controller with a unique tag to avoid conflicts
    final inputController = Get.put(
      InputTextController(
        textController: textEditingController ?? TextEditingController(),
        obscureText: obscureText,
        isInternalController: textEditingController == null,
      ),
      tag: key?.toString() ?? UniqueKey().toString(),
    );

    return Container(
      height: height.h,
      width: width == double.infinity ? double.infinity : width.w,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5.w, color: borderColor),
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading)
              Padding(
                padding: EdgeInsets.only(
                  right: leadingright.w,
                  top: leadingtop.h,
                  left: leadingleft.w,
                ),
                child: Image.asset(
                  leadingIcon,
                  width: leadingWidth.w,
                  height: leadingHeight.h,
                ),
              ),
            Expanded(
              child: Obx(
                    () => TextField(
                  controller: inputController.textController,
                  onChanged: onChanged,
                  onTap: onTap,
                  readOnly: readOnly,
                  maxLines: maxLines,
                  obscureText: inputController.isObscured.value,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: hintTextColor,
                      fontSize: hintfontSize.sp,
                      fontWeight: hintfontWeight,
                      fontFamily: hintfontFamily,
                    ),
                    border: InputBorder.none,
                    contentPadding: contentPadding
                        ? EdgeInsets.symmetric(
                      horizontal: horizontal.w,
                      vertical: vertical.h,
                    )
                        : null,
                  ),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: fontSize.sp,
                    fontWeight: fontWeight,
                    fontFamily: fontFamily,
                    color: textColor,
                  ),
                ),
              ),
            ),
            if (obscureText)
              Obx(() => Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: GestureDetector(
                    onTap: inputController.toggleObscure,
                    child: Icon(inputController.isObscured.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                      color: AppColor.textHintColor,
                    ),
                  ),
                ),
              ),
            if (backIcon)
              Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: GestureDetector(
                  onTap: backicontap,
                  child: SvgPicture.asset(imageIcon),
                ),
              ),
            if (backIcon2)
              Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: GestureDetector(
                  onTap: backicontap2,
                  child: SvgPicture.asset(imageIcon),
                ),
              ),
            if (backimageadd)
              GestureDetector(
                onTap: backimagetap,
                child: SvgPicture.asset(
                  backimage,
                  height: backimageheight.h,
                  width: backimagewidth.w,
                ),
              ),
          ],
        ),
      ),
    );
  }
}