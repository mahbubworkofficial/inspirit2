import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../auth/controllers/authcameracontroller.dart';
import '../../chat/controllers/bottom_sheet_controller.dart';
import '../../chat/views/chat_view.dart';
import '../../explore/views/explore.dart';
import '../../memory/views/memory.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile.dart';
import '../controllers/home_controller.dart';
import 'home_view.dart';

class Navigation extends GetView<HomeController> {
  Navigation({super.key});

  final BottomSheetController bs = Get.put(BottomSheetController());
  final AuthBottomSheetController as = Get.put(AuthBottomSheetController());
  final ProfileController profileController = Get.put(ProfileController());
  final List<String> labels = ['Home', 'Explore', 'Memory', 'Chat', 'Profile'];
  final List<String> icons = [
    ImageAssets.home,
    ImageAssets.explore,
    ImageAssets.memory,
    ImageAssets.chat,
  ];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profileController.userProfile.value == null && !profileController.isLoading.value) {
        profileController.fetchUserProfile();
      }
    });
    return Scaffold(
      body: Obx(
        () =>
            [
              HomeView(arguments: 'ExporleView'),
              Explore(arguments: 'ExporleView'),
              Memory(arguments: 'EventView'),
              ChatView(),
              Profile(arguments: 'EventView'),
            ][controller.currentIndex.value],
      ),
      bottomNavigationBar: SafeArea(
        child: Obx(
          () => Container(
            height: .085.sh,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: .030.sw),
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: AppColor.greyColor1,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final isSelected = controller.currentIndex.value == index;
                return GestureDetector(
                  onTap: () {
                    controller.currentIndex.value = index;
                    controller.isFabMenuOpen.value = false;
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (index == 4)
                        Obx(() {
                          final profile = profileController.userProfile.value;
                          return CircleAvatar(
                            radius: 17.sp,
                            backgroundColor: Colors.transparent,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60.r),
                              child:
                              profile?.profilePhoto != null
                                  ? Image.network(
                                profile!.profilePhoto!,
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
                          );
                        })
                      else
                        Image.asset(
                          icons[index],
                          width: 26.sp,
                          height: 26.sp,
                          color:
                              isSelected ? AppColor.darkGrey : AppColor.greyBC,
                        ),
                      index == 4?SizedBox(height: 2.h):SizedBox(height: 6.h),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color:
                              isSelected ? AppColor.darkGrey : AppColor.greyBC,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
