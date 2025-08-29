import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../explore/views/others_post_view.dart';
import '../../memory/views/add_memory_view.dart';
import '../../explore/views/create_event_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/home_controller.dart';
import '../widget/scanner.dart';
import 'create_post.dart';
import 'notification.dart';
import 'schedule.dart';

class HomeView extends GetView<HomeController> {
  final ProfileController profileController = Get.find<ProfileController>();
  HomeView({super.key, this.arguments});

  final String? arguments;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profileController.userProfile.value == null &&
          !profileController.isLoading.value) {
        profileController.fetchUserProfile();
      }
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              Obx(() {
                final profile = profileController.userProfile.value;
                return SliverAppBar(
                  automaticallyImplyLeading: false,
                  floating: true,
                  snap: true,
                  backgroundColor: AppColor.backgroundColor,
                  leadingWidth: 280,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hi, ${profile?.name}',
                          style: TextStyle(
                            color: AppColor.textTitleColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Text(
                          'Welcome back to Inspirit!',
                          style: TextStyle(
                            color: AppColor.textGreyColor,
                            fontSize: 14.sp,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Montaga',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => QRScannerWidget(
                                      onDetect: (code) {
                                        debugPrint('QR Code: $code');
                                        Navigator.pop(context);
                                      },
                                    ),
                              ),
                            );
                          },
                          child: Image.asset(ImageAssets.scanner, width: 30.w),
                        ),
                        SizedBox(width: 15.w),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              Schedule(arguments: arguments),
                              transition: Transition.rightToLeft,
                            );
                          },
                          child: Image.asset(ImageAssets.schedule, width: 30.w),
                        ),
                        SizedBox(width: 15.w),
                        Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                            color: AppColor.white1Color,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(
                                HomeNotification(),
                                transition: Transition.rightToLeft,
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.notifications_none_sharp,
                                    size: 30.sp,
                                    color: AppColor.black87Color,
                                  ),
                                ),
                                Positioned(
                                  top: 2.h,
                                  left: 20.w,
                                  child: Container(
                                    padding: EdgeInsets.all(1.sp),
                                    decoration: BoxDecoration(
                                      color: AppColor.whiteColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(3.sp),
                                      decoration: BoxDecoration(
                                        color: AppColor.redColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '2',
                                          style: TextStyle(
                                            color: AppColor.whiteColor,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                      ],
                    ),
                  ],
                );
              }),
              SliverToBoxAdapter(child: Column(children: [OthersPostView()])),
              // SliverList(
              //   delegate: SliverChildBuilderDelegate((context, index) {
              //     return buildPost();
              //   }, childCount: 20),
              // ),
            ],
          ),

          // FAB Menu Overlay
          Obx(
            () =>
                controller.isFabMenuOpen.value
                    ? GestureDetector(
                      onTap: () => controller.isFabMenuOpen.value = false,
                      child: Container(color: AppColor.black54Color),
                    )
                    : SizedBox(),
          ),

          // FAB Options
          Obx(
            () =>
                controller.isFabMenuOpen.value
                    ? Positioned(
                      bottom: 80.h,
                      right: 70.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _fabOption(
                            label: 'Create Event',
                            ontap:
                                () => Get.to(
                                  CreateEventView(),
                                  transition: Transition.rightToLeft,
                                ),
                          ),
                          _fabOption(
                            label: 'Create Post',
                            ontap:
                                () => Get.to(
                                  CreatePost(),
                                  transition: Transition.rightToLeft,
                                ),
                          ),
                          _fabOption(
                            label: 'Create Memory',
                            ontap:
                                () => Get.to(
                                  AddMemoryView(),
                                  transition: Transition.rightToLeft,
                                ),
                          ),
                        ],
                      ),
                    )
                    : SizedBox(),
          ),
        ],
      ),

      // FAB
      floatingActionButton: Obx(
        () => Padding(
          padding: EdgeInsets.only(right: 8.w, bottom: 8.h),
          child: Transform.rotate(
            angle:
                controller.isFabMenuOpen.value
                    ? 45 * 3.1416 / 180
                    : 90 * 3.1416 / 180,
            child: FloatingActionButton(
              onPressed: () => controller.isFabMenuOpen.toggle(),
              backgroundColor: AppColor.beigeBrown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(
                Icons.add,
                size: 40.sp,
                color: AppColor.whiteTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fabOption({required String label, required VoidCallback? ontap}) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        width: 180.w,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.black26Color,
              blurRadius: 6.r,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColor.textGreyColor,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
