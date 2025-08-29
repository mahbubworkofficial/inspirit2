

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../controller/explore_controller.dart';
import 'add_event_view.dart';

class CreateEventView extends GetView<ExploreController> {
  final List<String> options = [
    'DUMMY 1',
    'DUMMY 2',
    'DUMMY 3',
    'DUMMY 4',
    'DUMMY 5',
  ];

  CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        ),
        title: Text(
          'Create Event',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                      style: TextStyle(
                        color: AppColor.textGreyColor,
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ...List.generate(
                      options.length,
                      (index) => Obx(() {
                        final isSelected =
                            controller.selectedIndex.value == index;
                        return GestureDetector(
                          onTap: () {
                            controller.selectOption(index, options[index]);
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 15.h),
                            height: 48.h,
                            width: double.infinity,
                            decoration: ShapeDecoration(
                              color:
                                  isSelected
                                      ? AppColor.buttonColor
                                      : AppColor.textAreaColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                side: BorderSide(color: AppColor.textAreaColor),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                options[index],
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? AppColor.whiteTextColor
                                          : AppColor.textGreyColor,
                                  fontSize: 16.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              final isEnabled = controller.selectedIndex.value != -1;
              return Column(
                children: [
                  CustomButton(
                    title: 'Next',
                    onPress:
                        isEnabled
                            ? () async {
                              Get.to(
                                AddEventView(),
                                transition: Transition.rightToLeftWithFade,
                                arguments: {
                                  'origin': 'HomeView',
                                  'selectedOption':
                                      controller.selectedEventType.value,
                                },
                              );
                            }
                            : null,
                    buttonColor:
                        isEnabled
                            ? AppColor.buttonColor
                            : AppColor.textGreyColor.withOpacity(0.5),
                    height: 50,
                  ),
                  SizedBox(height: 30.h),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
