import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controller/explore_controller.dart';

class AddEventView extends GetView<ExploreController> {
  const AddEventView({super.key});

  @override
  Widget build(BuildContext context) {
    final String origin = Get.arguments?['origin'] as String? ?? 'HomeView';
    final String index = Get.arguments?['index'] as String? ?? '0';
    debugPrint('index________________________ $index');
    final event = controller.eventsList[int.parse(index)];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        ),
        title: Stack(
          children: [
            if (origin == 'HomeView')
              Text(
                'Create Event ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20.sp,
                  fontFamily: 'Montserrat',
                ),
              ),
            if (origin == 'EventView')
              Text(
                'Update Event ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20.sp,
                  fontFamily: 'Montserrat',
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                        style: TextStyle(
                          color: AppColor.greyTone,
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 15.h),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload Event Pictures',
                              style: TextStyle(
                                color: AppColor.textBlackColor,
                                fontSize: 16.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Obx(
                              () => SizedBox(
                                height: 127.h, // Fixed height for the grid
                                child: GridView.builder(
                                  scrollDirection:
                                      Axis.horizontal, // Horizontal scrolling
                                  physics:
                                      const ClampingScrollPhysics(), // Smooth horizontal scrolling
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1, // 1 row
                                        crossAxisSpacing:
                                            5, // Adjusted to raw values for consistency
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 1, // Square items
                                      ),
                                  itemCount:
                                      controller.imagePaths.length +
                                      1, // +1 for the upload button
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      // First item is the upload button
                                      return InkWell(
                                        onTap: () {
                                          controller
                                              .pickVideoOrImageFromGallery();
                                        },
                                        child: Image.asset(
                                          ImageAssets.upload,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      // Display uploaded images with remove icon
                                      final imageIndex =
                                          index -
                                          1; // Adjust for the upload button
                                      final imagePath =
                                          controller.imagePaths[imageIndex];
                                      return Container(
                                        height: 127.h,
                                        width: 118.w,
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              100.r,
                                            ),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Image.file(
                                              File(imagePath),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Image.asset(
                                                  ImageAssets
                                                      .upload, // Fallback if image fails to load
                                                  fit: BoxFit.fill,
                                                );
                                              },
                                            ),
                                            Positioned(
                                              top: 5.h,
                                              right: 5.w,
                                              child: InkWell(
                                                onTap: () {
                                                  controller.removeImage(
                                                    imageIndex,
                                                  );
                                                },
                                                child: Image.asset(
                                                  ImageAssets.removeImage,
                                                  width: 24.sp,
                                                  height: 24.sp,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InputTextWidget(
                        onChanged: (value) {},
                        backgroundColor: AppColor.textAreaColor,
                        borderColor: Colors.transparent,
                        hintText: 'Event title',
                        hintTextColor: AppColor.greyTone,
                        textEditingController:
                            // origin == 'EventView'
                            //     ? TextEditingController(text: event.title)
                            //     :
                            controller.titleController,
                      ),
                      SizedBox(height: 15.h),
                      InputTextWidget(
                        onChanged: (value) {},
                        backgroundColor: AppColor.textAreaColor,
                        borderColor: Colors.transparent,
                        hintText: 'Event date',
                        hintTextColor: AppColor.greyTone,
                        backimageadd: true,
                        backimage: ImageAssets.calender3,
                        textEditingController:controller.dateController,
                      ),
                      SizedBox(height: 15),
                      InputTextWidget(
                        onChanged: (value) {},
                        backgroundColor: AppColor.textAreaColor,
                        borderColor: Colors.transparent,
                        hintText: 'Event time',
                        hintTextColor: AppColor.greyTone,
                        backimageadd: true,
                        backimage: ImageAssets.time,
                        textEditingController: controller.timeController,
                        height: 48,
                      ),
                      SizedBox(height: 15.h),
                      InputTextWidget(
                        onChanged: (value) {},
                        backgroundColor: AppColor.textAreaColor,
                        borderColor: Colors.transparent,
                        hintText: 'Location',
                        hintTextColor: AppColor.greyTone,
                        backimageadd: true,
                        backimage: ImageAssets.location1,
                        textEditingController:controller.locationController,
                        height: 48,
                      ),
                      SizedBox(height: 15.h),
                      InputTextWidget(
                        onChanged: (value) {},
                        backgroundColor: AppColor.textAreaColor,
                        borderColor: Colors.transparent,
                        hintText: 'Event details',
                        hintTextColor: AppColor.greyTone,
                        passwordIcon: ImageAssets.time,
                        height: 148,
                        textEditingController: controller.descriptionController,
                        maxLines: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 10.h),
                    Obx(
                      () => CustomButton(
                        buttonColor: AppColor.buttonColor,
                        height: 48,
                        width: double.infinity,
                        radius: 30.r,
                        onPress:
                            controller.isLoading.value
                                ? null // Disable button when loading
                                : () async {
                          controller.eventId.value = event.id.toString();
                          controller.eventType.value = event.eventType.toString();
                                     debugPrint('id__________________________ ${controller
                                          .eventId.value}');
                                     debugPrint('type_________________________ ${controller
                                          .eventType.value}');
                              origin == 'EventView'?await controller.updateEvent():await controller.postEvent();
                                },
                        loading: controller.isLoading.value,
                        title: origin == 'EventView'?'UPDATE EVENT':'CREATE EVENT',
                      ),
                    ),
                    // Obx(
                    //   () => CustomButton(
                    //     onPress:
                    //         controller.isLoading.value
                    //             ? null // Disable button when loading
                    //             : () async {
                    //           final id = controller.eventsList[controller.selectedIndex.value].id.toString();
                    //           final type =  controller.selectedEventType.value.trim();
                    //          debugPrint('id__________________________ $id');
                    //          debugPrint('type_________________________ $type');
                    //           // await controller.updateEvent();
                    //           //     controller.isLoading.value = false;
                    //             //   showDialog(
                    //             //     context: context,
                    //             //     builder:
                    //             //         (context) => Dialog(
                    //             //           backgroundColor: Colors.transparent,
                    //             //           elevation: 0,
                    //             //           child: CenteredDialogWidget(
                    //             //             title: 'Update Created',
                    //             //             horizontalPadding: 2.0.w,
                    //             //             verticalPadding: 20.0.h,
                    //             //             subtitle:
                    //             //                 'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim',
                    //             //             imageAsset: ImageAssets.post_report,
                    //             //             backgroundColor:
                    //             //                 AppColor.backgroundColor,
                    //             //             iconBackgroundColor:
                    //             //                 Colors.transparent,
                    //             //             iconColor: AppColor.buttonColor,
                    //             //             borderRadius: 30.0.r,
                    //             //           ),
                    //             //         ),
                    //             //   );
                    //             //   Future.delayed(const Duration(seconds: 2), () {
                    //             //     try {
                    //             //       Get.off(
                    //             //         () => Navigation(),
                    //             //         transition: Transition.fadeIn,
                    //             //       );
                    //             //     } catch (e) {
                    //             //       showCustomSnackBar(
                    //             //         title: 'Navigation Error',
                    //             //         message:
                    //             //             'Failed to navigate to Event screen: $e',
                    //             //         isSuccess: true,
                    //             //       );
                    //             //     }
                    //             //   });
                    //             },
                    //     loading: controller.isLoading.value,
                    //     title: 'UPDATE EVENT',
                    //     buttonColor: AppColor.buttonColor,
                    //     height: 48,
                    //     width: double.infinity,
                    //     radius: 30.r,
                    //   ),
                    // ),
                  SizedBox(height: 30.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
