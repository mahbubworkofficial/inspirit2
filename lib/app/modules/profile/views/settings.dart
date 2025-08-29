
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/views/link_social_view.dart';
import '../../auth/views/plan_view.dart';
import 'about_app.dart';
import 'block_list_page.dart';
import 'delete_account.dart';
import 'family_tree.dart';
import 'feedback.dart';
import 'notification.dart';
import 'pass_change.dart';
import 'privacy.dart';
import 'terms_of_use.dart';
import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';

class Settings extends GetView<AuthController> {
   Settings({super.key});
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Block List', 'icon': ImageAssets.blocklist},
    {'title': 'Family Tree', 'icon': ImageAssets.familyTree},
    {'title': 'Link your Social Media', 'icon': ImageAssets.socialMedia},
    {'title': 'Subscription', 'icon': ImageAssets.subscription},
    {'title': 'Notification Setting', 'icon': ImageAssets.notification1},
    {'title': 'Change Password', 'icon': ImageAssets.changePass},
    {'title': 'Feedback', 'icon': ImageAssets.feedback},
    {'title': 'About App', 'icon': ImageAssets.aboutApp},
    {'title': 'Privacy Policy', 'icon': ImageAssets.privacy},
    {'title': 'Terms of Use', 'icon': ImageAssets.termsOfUse},
    {'title': 'Logout', 'icon': ImageAssets.logout},
    {'title': 'Delete Account', 'icon': ImageAssets.deleteAccount, 'isDelete': true},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            final isDelete = item['isDelete'] == true;
        
            return ListTile(
        
              leading: Image.asset(
                item['icon'],
                width: 24,
                height: 24,
                color: isDelete ? AppColor.deepRed: AppColor.greyTone,
              ),
              title: Text(
                item['title'],
                style: TextStyle(
                  fontSize: 18,
                  color: isDelete ? AppColor.deepRed: AppColor.greyTone,
                  fontWeight: isDelete ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              onTap: () {
                switch (item['title']) {
                  case 'Block List':
                    Get.to(BlockListPage(), transition: Transition.rightToLeft);
                    break;
                  case 'Family Tree':
                    Get.to(() => FamilyTreePage());
                    break;
                  case 'Link your Social Media':
        Get.to(LinkSocialView());
                    break;
                  case 'Subscription':
        Get.to(PlanView());
                    break;
                  case 'Notification Setting':
                    Get.to(NotificationSettings(), transition: Transition.rightToLeft);
                    break;
                  case 'Change Password':
                    Get.to(PassChange());
                    break;
                  case 'Feedback':
                    Get.to(FeedBack(), transition: Transition.rightToLeft);
                    break;
                  case 'About App':
                    Get.to(AboutApp(), transition: Transition.rightToLeft);
                    break;
                  case 'Privacy Policy':
                    Get.to(Privacy(), transition: Transition.rightToLeft);
                    break;
                  case 'Terms of Use':
                    Get.to(TermsOfUse(), transition: Transition.rightToLeft);
                    break;
                  case 'Logout':
                 controller.logout() ;
                    break;
                  case 'Delete Account':
                    Get.to(DeleteAccount(), transition: Transition.rightToLeft);
                    break;
                }
              },
        
            );
          },
        ),
      )
    );
  }
}
