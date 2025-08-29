import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../controllers/home_controller.dart';

class HomeNotification extends StatelessWidget {
  HomeNotification({super.key});

  final HomeController controller = Get.find();

  final List<Map<String, dynamic>> allItems = [
    {
      "type": "notification",
      "image": ImageAssets.type1,
      "title": 'Lorem ipsum dolor sit amet',
      "time": 'Today | 09:24 AM',
      "content":
          'Aenean commodo, lectus id imperdiet auctor, massa ipsum porttitor dui, finibus ultricies sem odio eu quam.',
    },
    {"type": "request"},
    {
      "type": "notification",
      "image": ImageAssets.type2,
      "title": 'Lorem ipsum dolor',
      "time": 'Today | 09:24 AM',
      "content":
          'Mauris vel maximus ante. Cras facilisis justo a venenatis consectetur. Phasellus velit turpis.',
    },
    {
      "type": "notification",
      "image": ImageAssets.type3,
      "title": 'Lorem ipsum',
      "time": 'Today | 09:24 AM',
      "content":
          'Vivamus volutpat eros sed maximus venenatis. Sed pharetra mauris gravida metus consequat.',
    },
    {
      "type": "notification",
      "image": ImageAssets.type4,
      "title": 'Security Updates!',
      "time": 'Today | 09:24 AM',
      "content":
          'Aenean commodo, lectus id imperdiet auctor, massa ipsum porttitor dui, finibus ultricies sem odio eu quam.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Notification',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Obx(
              () => Row(
                children: [
                  CustomButton(
                    onPress: () async => controller.toggleView(true),
                    width: 70,
                    radius: 14,
                    height: 40,
                    title: "All",
                    fontWeight: FontWeight.w400,
                    textColor:
                        !controller.showAll.value
                            ? AppColor.greyTone
                            : AppColor.whiteTextColor,
                    buttonColor:
                        !controller.showAll.value
                            ? AppColor.backgroundColor
                            : AppColor.buttonColor,
                  ),
                  SizedBox(width: 10.w),
                  CustomButton(
                    onPress: () async => controller.toggleView(false),
                    width: 120,
                    radius: 14,
                    height: 40,
                    fontWeight: FontWeight.w400,
                    title: "Requests",
                    textColor:
                        controller.showAll.value
                            ? AppColor.greyTone
                            : AppColor.whiteTextColor,
                    buttonColor:
                        controller.showAll.value
                            ? AppColor.backgroundColor
                            : AppColor.buttonColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Obx(() {
                if (controller.showAll.value) {
                  return ListView.builder(
                    itemCount: allItems.length,
                    itemBuilder: (context, index) {
                      final item = allItems[index];
                      if (item['type'] == 'notification') {
                        return _notificationBlock(
                          item['image'],
                          item['title'],
                          item['time'],
                          item['content'],
                        );
                      } else if (item['type'] == 'request') {
                        return _requestBlock();
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  );
                } else {
                  return ListView.builder(
                    itemCount: 6, // Show the request block 6 times
                    itemBuilder: (context, index) {
                      return _requestBlock();
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationBlock(
    String image,
    String title,
    String time,
    String content,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 30.r,
              backgroundColor:AppColor.greyColor,
              child: ClipOval(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: AppColor.textBlackColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(time, style: TextStyle(color: AppColor.greyTone)),
          ),
          Text(
            content,
            style: TextStyle(
              color: AppColor.greyTone,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestBlock() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor:AppColor.greyColor,
            child: ClipOval(
              child: Image.asset(
                ImageAssets.person2,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          SizedBox(width: 12.r),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Taylor',
                style: TextStyle(
                  color: AppColor.darkGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 4.r),
              Text(
                'Taylor_gouse',
                style: TextStyle(color: AppColor.greyTone, fontSize: 15),
              ),
            ],
          ),
          Spacer(),
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
