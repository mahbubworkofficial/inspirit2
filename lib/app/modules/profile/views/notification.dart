import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../res/colors/app_color.dart';
import '../controllers/profile_controller.dart';
import '../widget/custom_container.dart';

class NotificationSettings extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Notification Setting',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leadingWidth: 30,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                style: TextStyle(
                  color: AppColor.textGreyColor,
                  fontSize: 20,
                  fontFamily: 'Schuyler',
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 20),
              CustomSwitchTile(
                title: 'Lorem ipsum dolor sit',
                controller: controller,
              ),
              CustomSwitchTile(
                title: 'Lorem ipsum dolor sit',
                controller: controller,
              ),
              CustomSwitchTile(
                title: 'Lorem ipsum dolor sit',
                controller: controller,
              ),
              CustomSwitchTile(
                title: 'Lorem ipsum dolor sit',
                controller: controller,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
