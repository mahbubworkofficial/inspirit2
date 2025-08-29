import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'account_drag_view.dart';
import 'account_view.dart';
import '../controllers/profile_controller.dart';

class Profile extends GetView<ProfileController> {
  const Profile({super.key, this.arguments});

  final String? arguments;

  final String myProfile = 'myProfile';

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = ['account', 'account_drag'];

    return Obx(
      () => PageView.builder(
        controller: PageController(
          initialPage: tabs.indexOf(controller.selectedTab.value),
        ),
        onPageChanged: (int page) {
          controller.setSelectedTab(tabs[page]);
        },
        itemCount: tabs.length,
        physics: const ClampingScrollPhysics(),
        pageSnapping: true,
        reverse: false, // Right-to-left sliding effect
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return AccountView(arguments: [arguments, myProfile]);
            case 1:
              return AccountDragView(arguments: [arguments, myProfile]);
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
