

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../controllers/bottom_sheet_controller.dart';
import '../controllers/chat_controller.dart';
import '../widget/option_menu.dart';
import 'create_group1.dart';
import 'group_info_page.dart';

class GroupChat extends StatelessWidget {
  final String name;
  final ImagePicker _picker = ImagePicker();
  final ChatController controller = Get.put(ChatController());
  final BottomSheetController bs = Get.put(BottomSheetController());
  GroupChat({super.key, required this.name});

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      controller.pickedImage.value = File(pickedFile.path);
    }
  }

  Future<void> _pickVideoOrImageFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      controller.pickedImage.value = File(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, color: AppColor.blackColor),
        ),
        leadingWidth: 40.w,
        titleSpacing: 0,
        title: Row(
          children: [
            Obx(() {
              final file = bs.pickedImage.value;
              return ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child:
                    file != null
                        ? Image.file(
                          file,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          width: 40,
                          height: 40,
                          color: AppColor.mutedBlueGrey,
                          child: Image.asset(
                            ImageAssets.group,
                            fit: BoxFit.cover,
                          ),
                        ),
              );
            }),
            SizedBox(width: 10.w),
            Text(
              name,
              style: TextStyle(
                color: AppColor.darkGrey,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => CustomAppBarMenu(
              options:
                  controller.isuserblocked.value
                      ? ['Clear Chat', 'Unblock User']
                      : ['View Info', 'Edit ', 'Mute', 'Clear Chat'],
              onSelected: (value) {
                if (value == 'View Info') {
                  Get.to(
                    GroupInfoPage(name: name),
                    transition: Transition.rightToLeft,
                  );
                } else if (value == 'Edit') {
                  controller.isuserblocked.value = true;
                  Get.to(CreateGroup1(), transition: Transition.rightToLeft);
                } else if (value == 'Unblock User') {
                  controller.isuserblocked.value = false;
                }
                // Add more logic as needed
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0.h),
        child: Obx(
          () => Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align the content to the top
            children: [
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: AppColor.softBeige)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          color: AppColor.beigeBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColor.softBeige)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(20.w),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              right: 8.0.w,
                              bottom: 10.h,
                            ),
                            child: CircleAvatar(
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
                          ),
                          Container(
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 12, right: 80),
                            decoration: BoxDecoration(
                              color: AppColor.softBeige,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Good morning',
                                    style: TextStyle(fontSize: 16),
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    '11:23 AM',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColor.textBlackColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 12, left: 80),
                        decoration: BoxDecoration(
                          color: AppColor.vividBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                'Hey how are you?',
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Padding(
                              padding: EdgeInsets.only(bottom: 3),
                              child: Text(
                                '11:23 AM',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textBlackColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildInputBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:AppColor.white3Color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Obx(
            () =>
                controller.message.value.isEmpty
                    ? GestureDetector(
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColor.default1Color,
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColor.whiteColor,
                          size: 18,
                        ),
                      ),
                      onTap: () {
                        _pickImage(ImageSource.camera);
                      },
                    )
                    : const SizedBox.shrink(),
          ),
          SizedBox(width: controller.message.value.isEmpty ? 10 : 0),
          Expanded(
            child: TextField(
              controller: controller.textController,
              onChanged: (value) => controller.message.value = value.trim(),
              decoration: const InputDecoration(
                hintText: 'Message...',
                hintStyle: TextStyle(color: AppColor.greyColor1),
                border: InputBorder.none,
              ),
            ),
          ),
          Obx(
            () =>
                controller.message.value.isEmpty
                    ? Row(
                      children: [
                        Image.asset(
                          ImageAssets.microphone,
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            _pickVideoOrImageFromGallery();
                          },
                          child: Image.asset(
                            ImageAssets.gallery,
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    )
                    : GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(
                        ImageAssets.send,
                        height: 24,
                        width: 24,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
