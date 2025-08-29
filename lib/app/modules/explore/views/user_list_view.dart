import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/account_view.dart';

class UserListView extends GetView<ProfileController> {
  final String? arguments;
  const UserListView({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.usersList.isEmpty && !controller.isLoading.value) {
        controller.fetchUsers();
      }
    });

    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmerList();
      }

      if (controller.usersList.isEmpty) {
        return const Center(child: Text('No users found'));
      }

      return Padding(
        padding: EdgeInsets.only(bottom: 0.09.sh),
        child: SingleChildScrollView(
          child: ListView.builder(
            itemCount: controller.usersList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final user = controller.usersList[index];
              final String userId = user.id.toString();

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
                child: GestureDetector(
                  onTap: () async {
                    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

                    // 1) Put details we already have into othersUserProfile
                    controller.othersUserProfile.value = {
                      'id': userId,
                      'name': user.name ?? user.username ?? user.email,
                      'username': user.username ?? '',
                      'email': user.email,
                      'profilePhoto': user.profilePhoto,
                      'friendsCount': user.friendsCount,
                      'about': user.about,
                      'isFriend': user.isFriend,
                    };

                    // 2) Fetch ONLY posts for that user (clear previous)
                    controller.otherUserPosts.clear();

                    // 3) Navigate
                    Get.to(
                          () => AccountView(arguments: [userId, 'othersProfile']),
                      transition: Transition.rightToLeft,
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 25.r,
                        backgroundColor: Colors.grey.shade100,
                        child: ClipOval(
                          child: user.profilePhoto != null && user.profilePhoto!.trim().isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: user.profilePhoto!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey.shade100),
                            errorWidget: (context, url, error) => Image.asset(
                              ImageAssets.avatar1,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                              : Image.asset(
                            ImageAssets.avatar1,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? 'Unknown',
                              style: TextStyle(
                                color: AppColor.darkGrey,
                                fontWeight: FontWeight.w600,
                                fontSize: 18.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              user.username ?? user.email,
                              style: TextStyle(
                                color: AppColor.greyTone,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildShimmerList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: ListView.builder(
        itemCount: 6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade100,
              highlightColor: Colors.grey.shade50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16.h,
                          color: Colors.grey.shade100,
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 120.w,
                          height: 14.h,
                          color: Colors.grey.shade100,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
