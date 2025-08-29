import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../controllers/chat_controller.dart';

class Request extends StatelessWidget {
  final ChatController controller = Get.find();
  Request({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Request',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ListView.builder(
          padding: EdgeInsets.all(0),

          shrinkWrap: true,
          itemCount: controller.names.length,
          itemBuilder: (context, index) {
            return Column(
              children: [_buildURequestTile(controller.names[index])],
            );
          },
        ),
      ),
    );
  }

  Widget _buildURequestTile(String name) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),

      child: Row(
        children: [
          // Leading icon (CircleAvatar)
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColor.greyColor,
            child: ClipOval(
              child: Image.asset(
                ImageAssets.person2,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          SizedBox(width: 12.r), // Spacing between avatar and text
          // Title and subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: AppColor.darkGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 4.r),
              Text(
                '_$name',
                style: TextStyle(color: AppColor.greyTone, fontSize: 15),
              ),
            ],
          ),
          Spacer(), // This pushes the trailing to the far right
          // Trailing images (reject and accept)
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(ImageAssets.reject, width: 50),
                SizedBox(width: 8.r),
                Image.asset(ImageAssets.accept, width: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
