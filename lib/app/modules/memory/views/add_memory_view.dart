import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/memory_controller.dart';

class AddMemoryView extends GetView<MemoryController> {
  const AddMemoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final String index = Get.arguments?['index'] as String? ?? '0';
    final String memory = Get.arguments?['memory'] as String? ?? 'home';
    final int memoryId = Get.arguments?['memoryId'] as int? ?? 0;
    debugPrint('index________________________ $index');
    debugPrint('memory________________________ $memory');
    debugPrint('memoryId ________________________ $memoryId');
    final person = controller.personsList[int.parse(index)];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        ),
        title: Text(
          memory == 'updateMemory' ? 'Edit Memory' : 'Add Memory',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            color: AppColor.textBlackColor,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
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
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 15.h),
                    InputTextWidget(
                      onChanged: (value) {},
                      textEditingController: controller.titleController,
                      backgroundColor: AppColor.textAreaColor,
                      borderColor: Colors.transparent,
                      hintText: 'Title for this memory',
                      hintTextColor: AppColor.greyTone,
                      backimageadd: true,
                      backimage: ImageAssets.calender3,
                    ),
                    SizedBox(height: 10.h),
                    InputTextWidget(
                      onChanged: (value) {},
                      backgroundColor: AppColor.textAreaColor,
                      textEditingController: controller.dateController,
                      borderColor: Colors.transparent,
                      hintText: 'Date of memory',
                      hintTextColor: AppColor.greyTone,
                      backimageadd: true,
                      backimage: ImageAssets.time,
                    ),
                    SizedBox(height: 10.h),
                    InputTextWidget(
                      onChanged: (value) {},
                      backgroundColor: AppColor.textAreaColor,
                      borderColor: Colors.transparent,
                      hintText: 'Description',
                      textEditingController: controller.descriptionController,
                      hintTextColor: AppColor.greyTone,
                      height: 148,
                      maxLines: 10,
                    ),
                    SizedBox(height: 15.h),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Media',
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
                              height: 127, // Fixed height for the grid
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
                                        fit: BoxFit.fill,
                                      ),
                                    );
                                  } else {
                                    // Display uploaded images with remove icon
                                    final imageIndex =
                                        index -
                                        1; // Adjust for the upload button
                                    final imagePath =
                                        controller.imagePaths[imageIndex];
                                    return Stack(
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
                                              fit: BoxFit.cover,
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
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Obx(
                  () => CustomButton(
                    onPress:
                        controller.isLoading.value
                            ? null // Disable button when loading
                            : () async {
                              controller.personId.value = person.id.toString();
                              controller.memoryId.value = memoryId.toString();
                              memory == 'updateMemory'
                                  ? controller.updateMemory()
                                  : controller.postMemory();
                            },
                    loading: controller.isLoading.value,
                    title:
                        memory == 'updateMemory'
                            ? 'Update Memory'
                            : 'ADD MEMORY',
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
