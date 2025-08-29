import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';

class DeleteConfirmation extends StatelessWidget {
  const DeleteConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.buttonColor,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColor.buttonColor,
        child: Column(
          children: [
            SizedBox(height: 0.17.sh),
            SizedBox(
              width: 350.w,
              height: 350.h,
              child: Image.asset(ImageAssets.img),
            ),
          ],
        ),
      ),
    );
  }
}
