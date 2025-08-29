import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../controllers/home_controller.dart';

class SelectMemorial extends GetView<HomeController> {
  const SelectMemorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Select Memorial',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
              style: TextStyle(color: AppColor.greyTone, fontSize: 20),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      controller.isMemorialSelected.value = true;
                      Get.back();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColor.softBeige),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.w),
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: AppColor.blackColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.asset(
                                    ImageAssets.person,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sophia Anderson',
                                  style: TextStyle(
                                    color: AppColor.greyTone,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  'December 12th, 1992',
                                  style: TextStyle(
                                    color: AppColor.greyTone,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'June 1st, 2024',
                                  style: TextStyle(
                                    color: AppColor.greyTone,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: 20,
              ),
            ),
            SizedBox(height: 15),
            CustomButton(
              title: 'Next',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              onPress: () async {
                controller.isMemorialSelected.value = true;
                Get.back();
              },
              buttonColor: AppColor.buttonColor,
              height: 50,
              radius: 30.r,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
