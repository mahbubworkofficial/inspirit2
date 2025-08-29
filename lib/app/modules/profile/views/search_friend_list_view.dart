import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/profile_controller.dart';

class SearchFriendListView extends GetView<ProfileController> {
  const SearchFriendListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        leadingWidth: 30.w,
        title: Obx(
          () => InputTextWidget(
            onChanged: (value) {
              controller.searchQuery.value = value;
            },
            backIcon: controller.searchQuery.value.isEmpty ? false : true,
            imageIcon: ImageAssets.cross3,
            borderColor: AppColor.backgroundColor,
            hintText: 'Search',
            hintTextColor: AppColor.textGreyColor2,
            leadingIcon: ImageAssets.search,
            textColor: AppColor.textGreyColor2,
            leading: true,
            height: 48.h,
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
                      'No friend found',
                      style: TextStyle(
                        color: AppColor.greyTone,
                        fontSize: 18.sp,
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

  Widget _buildGroupTile(ProfileController controller) {
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
          fontSize: 17.sp,
        ),
      ),
      subtitle: Text(
        'Thanks everyone',
        style: TextStyle(color: AppColor.greyTone, fontSize: 15.sp),
      ),
      trailing: GestureDetector(
        onTap: () => controller.isRequestSent.toggle(),
        child: Obx(
          () => Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.textGreenColor, width: 1.5.w),
            ),
            child: Text(
              controller.isRequestSent.value ? 'Sent Request' : 'Join',
              style: TextStyle(
                color: AppColor.textGreenColor,
                fontSize: 15.sp,
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
            fontSize: 17.sp,
          ),
        ),
        subtitle: Text(
          'Thanks everyone',
          style: TextStyle(color: AppColor.greyTone, fontSize: 15.sp),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 5.h),
            Container(
              width: 94.w,
              height: 36,
              decoration: ShapeDecoration(
                color: AppColor.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: AppColor.textSendColor),
                ),
              ),
              child: Center(
                child: Text(
                  'remove',
                  style: TextStyle(
                    color: AppColor.textSendColor,
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
