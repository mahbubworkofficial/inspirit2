import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../explore/views/event_list_view.dart';
import '../../explore/views/post_view.dart';
import '../../memory/views/memorial_view.dart';
import '../controllers/profile_controller.dart';
import 'settings.dart';

class AccountDragView extends GetView<ProfileController> {
  const AccountDragView({super.key, required this.arguments});
  final List<String?> arguments;
  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.userProfile.value == null && !controller.isLoading.value) {
        controller.fetchUserProfile();
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.userProfile.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = controller.userProfile.value;
            if (profile == null) {
              // Show a lightweight retry/error UI
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.errorMessage.value.isEmpty
                            ? 'No profile loaded yet.'
                            : controller.errorMessage.value,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: controller.fetchUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: AppColor.backgroundColor,
                  automaticallyImplyLeading: false,
                  expandedHeight: 70, // Adjust height for profile section
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30.r,
                            backgroundColor: AppColor.greyColor,
                            child: ClipOval(
                              child:  (profile.profilePhoto != null &&
                                  profile.profilePhoto!.isNotEmpty)
                                  ? Image.network(
                                profile.profilePhoto!,
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
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  profile.name,
                                  style: TextStyle(
                                    color: AppColor.darkGrey,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18.sp,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Row(
                                  children: [
                                    Text(
                                      profile.username,
                                      style: TextStyle(
                                        color: AppColor.subTitleGrey,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Montaga',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: InkWell(
                              onTap: () => Get.to(
                                Settings(),
                                transition: Transition.rightToLeft,
                              ),
                              child: Image.asset(ImageAssets.settings),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 20.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: Obx(
                                () => GestureDetector(
                                  onTap: () {
                                    controller.setAccountSelectedTab('Memorial');
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        'Memorial',
                                        style: TextStyle(
                                          color:
                                              controller
                                                          .accountSelectedTab
                                                          .value ==
                                                      'Memorial'
                                                  ? AppColor.buttonColor
                                                  : AppColor.textGreyColor3,
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          height: 2,
                                          letterSpacing: 0.50,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      SizedBox(
                                        height: 2,
                                        width: 130,
                                        child: Divider(
                                          height: 5,
                                          thickness: 2,
                                          color:
                                              controller
                                                          .accountSelectedTab
                                                          .value ==
                                                      'Memorial'
                                                  ? AppColor.buttonColor
                                                  : AppColor.textAreaColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Obx(
                                () => GestureDetector(
                                  onTap: () {
                                    controller.setAccountSelectedTab('Post');
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        'Post',
                                        style: TextStyle(
                                          color:
                                              controller
                                                          .accountSelectedTab
                                                          .value ==
                                                      'Post'
                                                  ? AppColor.buttonColor
                                                  : AppColor.textGreyColor3,
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          height: 2,
                                          letterSpacing: 0.50,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      SizedBox(
                                        height: 2,
                                        width: 130,
                                        child: Divider(
                                          height: 5,
                                          thickness: 2,
                                          color:
                                              controller
                                                          .accountSelectedTab
                                                          .value ==
                                                      'Post'
                                                  ? AppColor.buttonColor
                                                  : AppColor.textAreaColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Obx(
                                () => GestureDetector(
                                  onTap: () {
                                    controller.setAccountSelectedTab('Event');
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        'Event',
                                        style: TextStyle(
                                          color:
                                              controller
                                                          .accountSelectedTab
                                                          .value ==
                                                      'Event'
                                                  ? AppColor.buttonColor
                                                  : AppColor.textGreyColor3,
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          height: 2,
                                          letterSpacing: 0.50,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      SizedBox(
                                        height: 2,
                                        width: 130,
                                        child: Divider(
                                          height: 5,
                                          thickness: 2,
                                          color:
                                              controller
                                                          .accountSelectedTab
                                                          .value ==
                                                      'Event'
                                                  ? AppColor.buttonColor
                                                  : AppColor.textAreaColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: AppColor.backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Obx(
                        () => IndexedStack(
                          index: [
                            'Memorial',
                            'Post',
                            'Event',
                          ].indexOf(controller.accountSelectedTab.value),
                          children: [
                            MemorialView(),
                            PostView(),
                            EventListView(arguments: arguments[0]),
                          ],
                        ),
                      ),
                    );
                  }, childCount: 1),
                ),
              ],
            );}
          ),
        ),
      ),
    );
  }
}
