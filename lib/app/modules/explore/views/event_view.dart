import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../controller/explore_controller.dart';
import 'event_image_slideshow.dart';

class EventView extends GetView<ExploreController> {
  const EventView({super.key, this.arguments});

  final String? arguments;

  @override
  Widget build(BuildContext context) {

    final String index = Get.arguments?['index'] as String? ?? '-1';
    debugPrint('index________________________ $index');
    final event = controller.eventsList[int.parse(index)];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 300.h, // Adjust height as needed
              child: EventImageSlideshow(event: event),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: AppColor.buttonColor,
                      fontSize: 20.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    event.details,
                    style: TextStyle(
                      color: AppColor.textGreyColor2,
                      fontSize: 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Date & Time',
                    style: TextStyle(
                      color: AppColor.buttonColor,
                      fontSize: 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Container(
                    height: 52.h,
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: AppColor.textAreaColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: BorderSide(color: AppColor.backgroundColor),
                      ),
                    ),
                    padding: EdgeInsets.only(left: 20.w, right: 80.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              ImageAssets.calender,
                              height: 20.h,
                              width: 20.h,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              event.date,
                              style: TextStyle(
                                color: AppColor.darkGrey,
                                fontSize: 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(
                              ImageAssets.clock,
                              height: 20.h,
                              width: 20.h,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              event.time,
                              style: TextStyle(
                                color: AppColor.darkGrey,
                                fontSize: 14.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Location',
                    style: TextStyle(
                      color: AppColor.buttonColor,
                      fontSize: 16.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      Image.asset(
                        ImageAssets.location,
                        height: 20.h,
                        width: 20.h,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        event.location,
                        style: TextStyle(
                          color: AppColor.greyTone,
                          fontSize: 14.sp,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 390.w, // Width: 390px
                    height: 188.h, // Height: 188px
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r), // Radius: 10px
                      border: Border.all(color: AppColor.greyColor),
                    ),
                    child: Image.asset(ImageAssets.map),

                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(10.r),
                    //   child: GoogleMap(
                    //     onMapCreated: controller.onMapCreated,
                    //     initialCameraPosition: const CameraPosition(
                    //       target: ExploreController.initialLocation,
                    //       zoom: 15,
                    //     ),
                    //     markers: controller.markers,
                    //     myLocationEnabled: true,
                    //     myLocationButtonEnabled: true,
                    //   ),
                    // ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
