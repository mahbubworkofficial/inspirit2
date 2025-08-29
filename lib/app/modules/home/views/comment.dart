import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../explore/controller/post_controller.dart';
import '../widget/bottom_sheet.dart';
import 'comment_list.dart';
import 'report.dart';

class Comment extends GetView<PostController> {
  final int index;
  const Comment(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final String postId = controller.othersPost[index]['id'].toString();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.closeCurrentSnackbar();
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 0.09.sh),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColor.backgroundColor,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            radius: 25.r,
                            backgroundColor: AppColor.greyColor,
                            child: ClipOval(
                              child:
                                  controller.othersPost[index]['user_profile_picture'] !=
                                          null
                                      ? Image.network(
                                        controller
                                            .othersPost[index]['user_profile_picture'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                      : Image.asset(
                                        ImageAssets.image,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                            ),
                          ),
                          title: Text(
                            controller.othersPost[index]['user_name'] ??
                                'Dummy Name',
                            style: TextStyle(
                              color: AppColor.textBlackColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                controller.othersPost[index]['user_username'] ??
                                    'Unknown username',
                                style: TextStyle(
                                  color: AppColor.greyTone,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                controller.othersPost[index]['created_at'] ??
                                    'Unknown time',
                                style: TextStyle(
                                  color: AppColor.greyTone,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder:
                                    (_) => ReportBottomSheet(
                                      firstOption: ReportOption(
                                        icon: Icons.report_problem,
                                        label: 'Report',
                                        onTap: () {
                                          Navigator.pop(context);
                                          Get.to(
                                            () => Report(),
                                            transition: Transition.rightToLeft,
                                          );
                                        },
                                      ),
                                      showTwoOptions: false,
                                    ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            controller.othersPost[index]['content'] ?? 'No content',
                            style: TextStyle(
                              color: AppColor.greyTone,
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        if (controller.othersPost[index]['media'] != null &&
                            controller.othersPost[index]['media'].isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                () => FullScreenImageView(
                                  imageUrl:
                                      controller
                                          .othersPost[index]['media'][0]['file'],
                                ),
                                transition: Transition.rightToLeft,
                              );
                            },
                            child: ClipRRect(
                              child: Image.network(
                                controller.othersPost[index]['media'][0]['file'],
                                fit: BoxFit.fitHeight,
                                width: double.infinity,
                                height: 200.h,
                              ),
                            ),
                          ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 20.w),
                            GestureDetector(
                              onTap: () {
                                controller.toggleLike(
                                  controller.othersPost[index]['id'],
                                  index,
                                );
                              },
                              child: Obx(
                                () => SvgPicture.asset(
                                  ImageAssets.love,
                                  width: 24.w,
                                  height: 24.h,
                                  colorFilter: ColorFilter.mode(
                                    (controller.othersPost[index]['is_liked'] ??
                                            false)
                                        ? AppColor.redColor
                                        : AppColor.greyTone,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5.w),
                            // Like count wrapped with Obx to update reactively
                            SizedBox(
                              width: 40.w,
                              child: Obx(() {
                                return Text(
                                  '${controller.othersPost[index]['react_count'] ?? 0}',
                                  style: TextStyle(
                                    color: AppColor.greyTone,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat',
                                  ),
                                );
                              }),
                            ),
                            SizedBox(width: 10.w),
                            GestureDetector(
                              onTap:
                                  () => Get.to(
                                    () => Comment(index),
                                    transition: Transition.rightToLeft,
                                  ),
                              child: SvgPicture.asset(
                                ImageAssets.achieve,
                                width: 24.w,
                                height: 24.h,
                                colorFilter: ColorFilter.mode(
                                  AppColor.greyTone,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            SizedBox(width: 5.w),
                            SizedBox(
                              width: 40.w,
                              child: Obx(
                                ()=> Text(
                                  '${controller.othersPost[index]['comment_count'] ?? 0}',
                                  style: TextStyle(
                                    color: AppColor.greyTone,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            SvgPicture.asset(
                              ImageAssets.share,
                              width: 24.w,
                              height: 24.h,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'Share',
                              style: TextStyle(
                                color: AppColor.greyTone,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CommentsList(postId: postId),
                ],
              ),
            ),
          ),

          // Fixed input
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: AppColor.softBeige,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Obx(
                () => TextField(
                  onChanged: controller.onTextChanged,
                  controller: controller.commentTextController,
                  keyboardType: TextInputType.text,
                  cursorColor: AppColor.textColor,
                  style: TextStyle(color: AppColor.textColor),
                  decoration: InputDecoration(
                    hintText: "Add Comment",
                    hintStyle: TextStyle(color: AppColor.textGreyColor),
                    filled: true,
                    fillColor: AppColor.lightBeige,
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(8.sp),
                      child: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: AppColor.greyColor,
                        child: ClipOval(
                          child: Image.network(
                            controller
                                .othersPost[index]['user_profile_picture'],
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    suffixIcon:
                        controller.hasText.value
                            ? (controller.isSendingComment.value
                            ? Padding(
                          padding: EdgeInsets.all(12.w),
                          child: SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                            : IconButton(
                          icon: Icon(Icons.send, size: 20.sp, color: AppColor.greyTone),
                          onPressed: () => controller.submitComment(postId),
                        ))
                            : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  const FullScreenImageView({super.key, required this.imageUrl});

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
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
