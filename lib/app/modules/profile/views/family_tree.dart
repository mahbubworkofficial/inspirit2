import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jordyn/res/assets/image_assets.dart';
import 'package:jordyn/res/colors/app_color.dart';

import '../controllers/family_tree_controller.dart';

class FamilyTreePage extends GetView<FamilyTreeController> {
  const FamilyTreePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFamilyTreeData();
    });
    return Scaffold(
      backgroundColor: AppColor.backgroundColor1,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColor.blackColor),
          onPressed: () => Get.back(),
        ),
        title: Center(child: SvgPicture.asset(ImageAssets.free)),
        actions: [
          SizedBox(width: 48),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(height: 100.h),
                  SvgPicture.asset(
                    ImageAssets.tree,
                    width: .5.sw,
                    height: 480.h,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 210.h,
              child: SizedBox(
                width: 1.sw,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: .5.sw,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFamilyMember('grandpa1', 0),
                          _buildFamilyMember('grandma1', 0),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: .5.sw,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFamilyMember('grandpa2', 0),
                          _buildFamilyMember('grandma2', 0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 310.h,
              child: SizedBox(
                width: 1.sw,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFamilyMember('mom', 1),
                    _buildFamilyMember('dad', 1),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 430.h,
              child: SizedBox(
                width: 1.sw,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFamilyMember('brother', 1),
                    _buildFamilyMember('me', 1),
                    _buildFamilyMember('sister', 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMember(String id, double level) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: level == 0 ? 80.h : 106.h,
          width: level == 0 ? 92.w : 116.w,
        ),
        Positioned(
          top: 0,
          child: Obx(() {
            final member = controller.familyMembers[id]!;
            final imagePath = member.image.value;
            return GestureDetector(
              onTap: () => controller.pickImage(id),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.nameColor,
                    width: 3.w,
                  ),
                ),
                child: Container(
                  width: level == 0 ? 70.w : 88.w,
                  height: level == 0 ? 70.h : 88.h,
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.circleColor,
                      width: 1.w,
                    ),
                    image: imagePath != null
                        ? DecorationImage(
                      image: imagePath.startsWith('http')
                          ? NetworkImage(imagePath)
                          : FileImage(File(imagePath)),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        debugPrint('Image load error: $exception');
                      },
                    )
                        : null,
                  ),
                  child: imagePath == null
                      ? Icon(
                    Icons.add,
                    color: AppColor.lightGreenColor,
                    size: 35.sp,
                  )
                      : null,
                ),
              ),
            );
          }),
        ),
        Positioned(
          bottom: 0.h,
          left: 0,
          right: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                ImageAssets.frame,
                height: level == 0 ? 19.h : 24.h,
                width: level == 0 ? 92.h : 116.h,
              ),
              Obx(() {
                final name = controller.familyMembers[id]!.name;
                return Text(
                  name,
                  style: TextStyle(
                    color: AppColor.nameColor,
                    fontSize: level == 0 ? 12.20.sp : 15.48.sp,
                    fontFamily: 'Gluten',
                    fontWeight: FontWeight.w400,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}