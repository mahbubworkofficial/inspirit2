import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/memory_controller.dart';
import 'memory.dart';
import 'memory_details_view.dart';

class EditInfoMemoryView extends GetView<MemoryController> {
  const EditInfoMemoryView({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.to(Memory());
          },
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Edit Info ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                    style: TextStyle(
                      color: AppColor.greyTone,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 20.h),
                  Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          ImageAssets.image1,
                          height: 120,
                          width: 120,
                        ),
                      ),
                      Positioned(
                        bottom: 5.h,
                        right: 140.w,
                        child: Center(child: Image.asset(ImageAssets.camera1)),
                      ),
                    ],
                  ),
                  SizedBox(height: 25.h),

                  InputTextWidget(
                    onChanged: (value) {},
                    backgroundColor: AppColor.textAreaColor,
                    borderColor: Colors.transparent,
                    hintText: 'Person full name',
                    hintTextColor: AppColor.greyTone,
                    textColor: AppColor.greyTone,
                  ),
                  SizedBox(height: 10.h),
                  InputTextWidget(
                    onChanged: (value) {},
                    backgroundColor: AppColor.textAreaColor,
                    borderColor: Colors.transparent,
                    hintText: 'Add date of birth',
                    hintTextColor: AppColor.greyTone,
                    backimageadd: true,
                    backimage: ImageAssets.calender3,
                    textColor: AppColor.greyTone,
                  ),
                  SizedBox(height: 10.h),
                  InputTextWidget(
                    onChanged: (value) {},
                    backgroundColor: AppColor.textAreaColor,
                    borderColor: Colors.transparent,
                    hintText: 'Add date of birth',
                    hintTextColor: AppColor.greyTone,
                    backimageadd: true,
                    backimage: ImageAssets.calender3,
                    textColor: AppColor.greyTone,
                  ),
                  SizedBox(height: 10.h),
                  InputTextWidget(
                    onChanged: (value) {},
                    backgroundColor: AppColor.textAreaColor,
                    borderColor: Colors.transparent,
                    hintText: 'Date of passed on',
                    hintTextColor: AppColor.greyTone,
                    passwordIcon: ImageAssets.time,
                    height: 148,
                    maxLines: 10,
                  ),
                  SizedBox(height: 10.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Who can see',
                        style: TextStyle(
                          color: AppColor.textGreyColor2,
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Obx(
                        () => Column(
                          children: [
                            RadioListTile<String>(
                              title: Text(
                                'Only me',
                                style: TextStyle(
                                  color: AppColor.textGreyColor,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              value: 'Only me',
                              groupValue: controller.selectedRole.value,
                              onChanged: (value) {
                                controller.setSelectedRole(value!);
                              },
                              activeColor: AppColor.textBlackColor,
                            ),
                            RadioListTile<String>(
                              title: Text(
                                'Only my friends',
                                style: TextStyle(
                                  color: AppColor.textGreyColor,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              value: 'Only my friends',
                              groupValue: controller.selectedRole.value,
                              onChanged: (value) {
                                controller.setSelectedRole(value!);
                              },
                              activeColor: AppColor.textBlackColor,
                            ),
                            RadioListTile<String>(
                              title: Text(
                                'Me and my friends',
                                style: TextStyle(
                                  color: AppColor.textGreyColor,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              value: 'Me and my friends',
                              groupValue: controller.selectedRole.value,
                              onChanged: (value) {
                                controller.setSelectedRole(value!);
                              },
                              activeColor: AppColor.textBlackColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  CustomButton(
                    title: 'Save',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    onPress: () async {
                      Get.to(
                        MemoryDetailsView(),
                        transition: Transition.noTransition,
                      );
                    },
                    buttonColor: AppColor.buttonColor,
                    height: 48,
                    width: double.infinity,
                    radius: 30.r,
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
