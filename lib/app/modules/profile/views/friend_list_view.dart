import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/profile_controller.dart';
import 'account_view.dart';
import 'search_friend_list_view.dart';

class FriendListView extends GetView<ProfileController> {
  const FriendListView({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.friendsList.isEmpty &&
          controller.friendsListCount.value == 1) {
        controller.fetchFriends();
      }
    });
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        ),
        title: Text(
          'Friend List',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchFriends();
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
              child: InputTextWidget(
                onTap: () {
                  Get.to(
                    SearchFriendListView(),
                    transition: Transition.rightToLeft,
                  );
                },
                onChanged: (e) {},
                borderColor: AppColor.backgroundColor,
                hintText: 'Search',
                readOnly: true,
                hintTextColor: AppColor.textGreyColor2,
                leadingIcon: ImageAssets.search,
                textColor: AppColor.textGreyColor2,
                leading: true,
                height: 48.h,
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.friendsList.isEmpty) {
                  return Column(
                    children: [
                      Center(child: Text('No friends found')),
                      ElevatedButton(
                        onPressed: controller.fetchFriends,
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  itemCount: controller.friendsList.length,
                  itemBuilder: (context, index) {
                    final friend = controller.friendsList[index];

                    // Determine button text and functionality based on status

                    final buttonText =
                        friend.status == 'friends'
                            ? 'Friend'
                            : friend.status == 'sent'
                            ? 'Request Sent'
                            : 'Pending Request';
                    final textColor =
                        friend.status == 'friends'
                            ? AppColor.defaultColor
                            : friend.status == 'sent'
                            ? AppColor.textGreyColor
                            : AppColor.redAlphaColor;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.h),
                      child: GestureDetector(
                        onTap: () {
                          if (friend.status == 'friends') {
                            final String userId = friend.userId.toString();
                            // Only open chat if friend is accepted
                            Get.to(
                              () => AccountView(
                                arguments: [userId, 'othersProfile'],
                              ),
                              transition: Transition.rightToLeft,
                            );
                            // Get.to(
                            //   PersonalChat(name: friend.name),
                            //   transition: Transition.rightToLeft,
                            // );
                          }
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 28.r,
                            backgroundColor: AppColor.greyColor,
                            child: ClipOval(
                              child:
                                  friend.profilePhoto.isNotEmpty
                                      ? Image.network(
                                        friend.profilePhoto,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                      : Image.asset(
                                        ImageAssets.person2,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                            ),
                          ),
                          title: Text(
                            friend.name,
                            style: TextStyle(
                              color: AppColor.darkGrey,
                              fontWeight: FontWeight.w600,
                              fontSize: 17.sp,
                            ),
                          ),
                          subtitle: Text(
                            friend.username,
                            style: TextStyle(
                              color: AppColor.greyTone,
                              fontSize: 15.sp,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              friend.status == 'friends'
                                  ? 'Friend'
                                  : friend.status == 'sent'
                                  ? controller.deleteFriendRequest(
                                    friend.id.toString(),
                                  )
                                  : Get.dialog(
                                    AlertDialog(
                                      title: Text(
                                        'Friend Request from ${friend.name}',
                                      ),
                                      content: const Text(
                                        'Would you like to accept or reject this friend request?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Get.back(); // Close the dialog
                                            controller.acceptFriendRequest(
                                              friend.id.toString(),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.green,
                                          ),
                                          child: const Text('Accept'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.back(); // Close the dialog
                                            controller.rejectFriendRequest(
                                              friend.id.toString(),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColor.redColor,
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ],
                                    ),
                                  );
                            },
                            child: Container(
                              width: 140.w,
                              height: 36.h,
                              decoration: ShapeDecoration(
                                color: AppColor.backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.r),
                                  side: BorderSide(color: textColor),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  buttonText,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
