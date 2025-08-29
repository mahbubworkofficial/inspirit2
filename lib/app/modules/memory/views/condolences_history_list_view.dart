import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../explore/views/event_view.dart';

class CondolencesHistoryListView extends GetView {
  const CondolencesHistoryListView({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.09.sh),
      child: SingleChildScrollView(
        child: ListView.builder(
          itemCount: 10,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Get.to(EventView(), transition: Transition.noTransition);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 20),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: 25.r,
                        backgroundColor: AppColor.greyColor,
                        child: ClipOval(
                          child: Image.asset(
                            ImageAssets.person,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      title: Text(
                        'Dummy Name',
                        style: TextStyle(
                          color: AppColor.textBlackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            'abc_xyz',
                            style: TextStyle(color: AppColor.greyTone),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            '3s',
                            style: TextStyle(color: AppColor.greyTone),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipisci elit. Mauris ante nisi, bibendum vel commodo eu, auctor in purus. Mauris sed scelerisque libero, sit amet congue sem.',
                        style: TextStyle(
                          color: AppColor.greyTone,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
