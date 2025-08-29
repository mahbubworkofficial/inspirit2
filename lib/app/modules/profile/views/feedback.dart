import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/dialogue.dart';
import '../../../../widgets/input_text_widget.dart';

class FeedBack extends StatelessWidget {
  const FeedBack({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Feedback',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leadingWidth: 30,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.h),
            Text(
              'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
              style: TextStyle(
                color: AppColor.textGreyColor,
                fontSize: 20,
                fontFamily: 'Schuyler',
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 20.h),
            InputTextWidget(
              onChanged: (value) {},

              borderColor: AppColor.backgroundColor,
              hintText: 'Give your valuable feedback',
              hintTextColor: AppColor.textGreyColor2,
              textColor: AppColor.textGreyColor2,
              maxLines: 10,
              height: 150,
            ),
            SizedBox(height: 0.1.sh),
            CustomButton(
              title: 'Send Feedback',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              onPress: () async {
                showDialog(
                  context: context,
                  builder:
                      (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: CenteredDialogWidget(
                          title: 'Feedback Sent',
                          subtitle:
                              'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim',
                          imageAsset:
                              ImageAssets.postReport, // Use your own SVG
                          backgroundColor:
                              AppColor.backgroundColor, // Custom background
                          iconBackgroundColor: Colors.transparent,
                          iconColor:
                              AppColor.buttonColor, // Custom icon background
                          borderRadius: 30.0,
                          horizontalPadding: 2.w, // Custom corner radius
                        ),
                      ),
                );
              },
              buttonColor: AppColor.buttonColor,
              height: 50,
              radius: 30.r,
            ),
          ],
        ),
      ),
    );
  }
}
