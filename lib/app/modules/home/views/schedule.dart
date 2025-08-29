import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../explore/views/event_view.dart';
import '../controllers/home_controller.dart';
import '../widget/profile_card_widget.dart';
import 'navbar.dart';
import 'schedule_detail.dart';

class Schedule extends StatelessWidget {
  final String? arguments;
  final HomeController controller = Get.find();
  Schedule({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.to(Navigation(), transition: Transition.leftToRight);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Schedule Post',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                style: TextStyle(color: AppColor.greyTone, fontSize: 18),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () {
                  Get.to(ScheduleDetail(), transition: Transition.rightToLeft);
                },
                child: ProfileCardWidget(
                  imagePath: ImageAssets.person2,
                  title: 'Person Name',
                  showSubtitle1: true,
                  subtitle2: 'June 1st, 2024 12PM',
                  subtitle2IconPath: ImageAssets.calender2,
                ),
              ),
              SizedBox(height: 2.h),
              ListView.builder(
                itemCount: 50,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: InkWell(
                      onTap: () {
                        Get.to(
                          EventView(),
                          transition: Transition.noTransition,
                          arguments: {'origin': 'ExporleView'},
                        );
                      },
                      child: ProfileCardWidget(
                        imagePath: ImageAssets.flower,
                        title: 'Sophia Anderson',
                        showSubtitle1: true,
                        subtitle1: 'Category Name',
                        subtitle2: 'June 1st, 2024 12PM',
                        subtitle2IconPath: ImageAssets.calender2,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
