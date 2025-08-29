import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/chat_controller.dart';

class Search extends StatelessWidget {
  final ChatController controller = Get.find();
  final TextEditingController t1 = TextEditingController();
  Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        leadingWidth: 30,
        title: Obx(
          () => InputTextWidget(
            onChanged: (value) {
              controller.searchQuery.value = value;
            },

            backIcon: controller.searchQuery.value.isEmpty ? false : true,
            imageIcon: ImageAssets.cross3,
            backicontap: () {
              t1.clear();
              controller.searchQuery.value = '';
            },
            borderColor: AppColor.backgroundColor,
            hintText: 'Search',
            hintTextColor: AppColor.textGreyColor2,
            leadingIcon: ImageAssets.search,
            textColor: AppColor.textGreyColor2,
            leading: true,
            height: 48,
          ),
        ),
      ),
      body: Obx(() {
        final filteredNames =
            controller.names
                .where(
                  (name) => name.toLowerCase().contains(
                    controller.searchQuery.value.toLowerCase(),
                  ),
                )
                .toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              if (controller.searchQuery.value.isEmpty)
                _buildGroupTile(controller),
              if (filteredNames.isEmpty)
                SizedBox(
                  height: 0.8.sh,
                  child: Center(
                    child: Text(
                      'No chat found',
                      style: TextStyle(
                        color: AppColor.greyTone,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredNames.length,
                  itemBuilder: (context, index) {
                    return _buildUserTile(filteredNames[index]);
                  },
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGroupTile(ChatController controller) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28.r,
        backgroundColor: AppColor.greyColor,
        child: ClipOval(
          child: Image.asset(
            ImageAssets.flower,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
      title: Text(
        'Dummy Group Name',
        style: TextStyle(
          color: AppColor.darkGrey,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      subtitle: Text(
        'Thanks everyone',
        style: TextStyle(color: AppColor.greyTone, fontSize: 15),
      ),
      trailing: GestureDetector(
        onTap: () => controller.isrequestsent.toggle(),
        child: Obx(
          () => Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.textGreenColor, width: 1.5),
            ),
            child: Text(
              controller.isrequestsent.value ? 'Sent Request' : 'Join',
              style: TextStyle(
                color: AppColor.textGreenColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(String name) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28.r,
          backgroundColor: AppColor.greyColor,
          child: ClipOval(
            child: Image.asset(
              ImageAssets.person2,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: AppColor.darkGrey,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        subtitle: Text(
          'Thanks everyone',
          style: TextStyle(color: AppColor.greyTone, fontSize: 15),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 5.h),
            Text(
              '8:25 PM',
              style: TextStyle(
                color: AppColor.greyTone,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.r),
                color: AppColor.vividBlue,
              ),
              child: Center(
                child: Text(
                  '3',
                  style: TextStyle(
                    color:AppColor.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
