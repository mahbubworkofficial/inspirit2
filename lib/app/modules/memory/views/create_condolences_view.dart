import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/memory_controller.dart';

class CreateCondolencesView extends GetView<MemoryController> {
  const CreateCondolencesView({super.key});

  @override
  Widget build(BuildContext context) {
    final String index = Get.arguments?['index'] as String? ?? '0';
    debugPrint('index________________________ $index');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80.h,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        ),
        title: Text(
          'Add Condolence message',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 15.h),
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
                  SizedBox(height: 20.h),
                  InputTextWidget(
                    onChanged: (value) {},
                    textEditingController: controller.condolenceTextController,
                    backgroundColor: AppColor.textAreaColor,
                    borderColor: Colors.transparent,
                    hintText: 'Add condolence message',
                    hintTextColor: AppColor.greyTone,
                    passwordIcon: ImageAssets.time,
                    height: 148,
                    maxLines: 10,
                    vertical: 10,
                    horizontal: 7,
                  ),
                  SizedBox(height: 190.h),
                  CustomButton(
                    title: 'ADD',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    onPress: () async {
                      await controller.submitCondolence();
                    },
                    buttonColor: AppColor.buttonColor,
                    height: 50,
                    radius: 30,
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
