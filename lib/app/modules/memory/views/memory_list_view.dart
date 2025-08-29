import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../home/widget/bottom_sheet.dart';
import '../controllers/memory_controller.dart';

class MemoryListView extends GetView<MemoryController> {
   const MemoryListView({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.09.sh),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            GestureDetector(
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) {
                    return ReportBottomSheet(
                      showTwoOptions: true,
                      firstOption: ReportOption(
                        icon: Icons.edit,
                        label: 'Edit',
                        onTap: () {
                          Navigator.pop(context);
                          // Add your action here
                          debugPrint('Report tapped');
                        },
                      ),
                      secondOption: ReportOption(
                        icon: Icons.delete,
                        label: 'Delete',
                        onTap: () {
                          Navigator.pop(context);
                          // Add your action here
                          debugPrint('Block tapped');
                        },
                      ),
                    );
                  },
                );
              },
              child: ListView.builder(
                itemCount: 50,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20.r,
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
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Maryam',
                                    style: TextStyle(
                                      color: AppColor.darkGrey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    '3s',
                                    style: TextStyle(
                                      color: AppColor.greyTone,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                                style: TextStyle(
                                  color: AppColor.greyTone,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 25.h),
                          child: Column(
                            children: [
                              Image.asset(
                                ImageAssets.heart,
                                width: 20,
                                height: 20.h,
                              ),
                              Text(
                                '2',
                                style: TextStyle(
                                  color: AppColor.greyTone,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
