import 'package:flutter/material.dart';

import '../../../../res/colors/app_color.dart';

class CustomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const CustomActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.borderColor,
    this.textColor = AppColor.whiteColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(360, 57),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        elevation: 4,
        padding: EdgeInsets.zero,
        shadowColor: AppColor.greyTone,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontFamily: 'Schuyler',
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
