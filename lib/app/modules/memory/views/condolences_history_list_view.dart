import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../explore/views/event_view.dart';
import '../controllers/memory_controller.dart';

class CondolencesHistoryListView extends GetView<MemoryController> {
  const CondolencesHistoryListView({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCondolences();
    });
    return Obx(() {
      if (controller.isLoading.value && controller.condolences.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView.builder(
        itemCount:
        controller.condolences.length +
            (controller.isMoreLoading.value ? 1 : 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.condolences.isEmpty) {
            return Center(child: Text('No events found'));
          }
          final condolence = controller.condolences[index];

          return InkWell(
            onTap: () {
              Get.to(EventView(), transition: Transition.noTransition);
            },
            child: Padding(
              padding:  EdgeInsets.only(left: 10.w, right: 20.w),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 25.r,
                      backgroundColor: AppColor.greyColor,
                      child: ClipOval(
                        child: Image.network(
                          condolence.profilePhoto!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                ImageAssets.person,
                              )
                        ),
                      ),
                    ),
                    title: Text(
                      condolence.name,
                      style: TextStyle(
                        color: AppColor.textBlackColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          condolence.username,
                          style: TextStyle(color: AppColor.greyTone,
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            fontFamily: 'Montserrat',),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          condolence.createdAt,
                          style: TextStyle(color: AppColor.greyTone,
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            fontFamily: 'Montserrat',),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: Text(
                      condolence.condolenceMessage,
                      style: TextStyle(
                        color: AppColor.greyTone,
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        height: 1.5.h,
                        letterSpacing: -0.17,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          );
        },
    );});
  }
}
