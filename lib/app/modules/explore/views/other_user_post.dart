import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../home/views/comment.dart';
import '../../profile/controllers/profile_controller.dart';

class OtherUserPost extends GetView<ProfileController> {
  const OtherUserPost({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.otherUserPosts.isEmpty && controller.isLoading.value ) {
        controller.fetchOtherUserPost();
      }
    });
    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            children: List.generate(
              5,
                  (index) => Shimmer.fromColors(
                baseColor: AppColor.greyColor,
                highlightColor: AppColor.grey100Color,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  height: 200.h,
                  color: AppColor.whiteColor,
                ),
              ),
            ),
          ),
        );
      }

      if (controller.otherUserPosts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No otherUserPosts available',
                style: TextStyle(
                  color: AppColor.greyTone,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: controller.fetchOtherUserPost,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            for (var index = 0; index < controller.otherUserPosts.length; index++)
              GestureDetector(
                onTap: (){Get.to(
                      () => Comment(index),
                  transition: Transition.rightToLeft,
                );},
                child: Container(
                  width: double.infinity,
                  color: AppColor.backgroundColor,
                  margin: EdgeInsets.only(bottom: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          radius: 25.r,
                          backgroundColor: AppColor.greyColor,
                          child: ClipOval(
                            child: controller.otherUserPosts[index]['user_profile_picture'] != null
                                ? Image.network(
                              controller.otherUserPosts[index]['user_profile_picture'],
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
                          controller.otherUserPosts[index]['user_name'] ?? 'Dummy Name',
                          style: TextStyle(
                            color: AppColor.textBlackColor,
                            fontSize: 16.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Row(spacing: 10.w,
                          children: [
                            Text(
                              controller.otherUserPosts[index]['user_username'] ?? 'Unknown username',
                              style: TextStyle(
                                color: AppColor.greyTone,
                                fontSize: 12.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              controller.otherUserPosts[index]['created_at'] ?? 'Unknown time',
                              style: TextStyle(
                                color: AppColor.greyTone,
                                fontSize: 12.sp,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.more_vert, size: 24.sp),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 5.h,
                        ),
                        child: Text(
                          controller.otherUserPosts[index]['content'] ?? 'No content',
                          style: TextStyle(
                            color: AppColor.greyTone,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      // Check if media exists and display image
                      if (controller.otherUserPosts[index]['media'] != null &&
                          controller.otherUserPosts[index]['media'].isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Image.network(
                            controller.otherUserPosts[index]['media'][0]['file'],
                            fit: BoxFit.fitHeight,
                            width: double.infinity,
                            height: 200.h,
                          ),
                        ),
                      // Like and comment section
                      Row(
                        children: [
                          SizedBox(width: 20.w),
                          GestureDetector(
                            onTap: () {
                              controller.toggleOthersLike(controller.otherUserPosts[index]['id'], index);
                              debugPrint('Like tapped');
                            },
                            child: SvgPicture.asset(
                              ImageAssets.love,
                              width: 30.r,
                              height: 30.r,
                              colorFilter: ColorFilter.mode(
                                (controller.otherUserPosts[index]['is_liked'] ?? false)
                                    ? AppColor.redColor
                                    : AppColor.greyTone,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          // Like count wrapped with Obx to update reactively
                          Obx(() {
                            return Text(
                              '${controller.otherUserPosts[index]['react_count'] ?? 0}',
                              style: TextStyle(
                                color: AppColor.greyTone,
                                fontSize: 14.sp,
                              ),
                            );
                          }),
                          SizedBox(width: 20.w),
                          GestureDetector(
                            onTap: () => Get.to(
                                  () => Comment(index),
                              transition: Transition.rightToLeft,
                            ),
                            child: SvgPicture.asset(
                              ImageAssets.achieve,
                              width: 30.r,
                              height: 30.r,
                              colorFilter: ColorFilter.mode(
                                AppColor.greyTone,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            '${controller.otherUserPosts[index]['comment_count'] ?? 0}',
                            style: TextStyle(
                              color: AppColor.greyTone,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            if (controller.isMoreLoading.value)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      );
    });
  }
}

