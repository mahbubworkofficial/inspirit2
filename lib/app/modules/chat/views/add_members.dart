import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/chat_controller.dart';
import 'create_group1.dart';

class AddMembers extends StatelessWidget {
  final ChatController controller = Get.find();
  AddMembers({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Add User',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leadingWidth: 30,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Obx(() {
            final filteredNames =
                controller.names
                    .where(
                      (name) => name.toLowerCase().contains(
                        controller.searchQuery.value.toLowerCase(),
                      ),
                    )
                    .toList();

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        child: Obx(
                          () => InputTextWidget(
                            onChanged: (value) {
                              controller.searchQuery.value = value;
                            },
                            backIcon:
                                controller.searchQuery.value.isEmpty
                                    ? false
                                    : true,
                            imageIcon: ImageAssets.cross3,
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
                      SizedBox(height: 10.h),
                      if (filteredNames.isEmpty)
                        Expanded(
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
                        SizedBox(
                          height: 0.7.sh,
                          child: ListView.builder(
                            itemCount: filteredNames.length,
                            itemBuilder:
                                (context, index) =>
                                    _buildUserTile(filteredNames[index]),
                          ),
                        ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: CustomButton(
                          title: 'Next',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          onPress: () async {
                            Get.to(
                              CreateGroup1(),
                              transition: Transition.rightToLeft,
                            );
                          },
                          buttonColor: AppColor.buttonColor,
                          height: 50,
                          radius: 30.r,
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          });
        },
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
          '_$name',
          style: TextStyle(color: AppColor.greyTone, fontSize: 15),
        ),
        trailing: Obx(
          () => GestureDetector(
            onTap: () {
              controller.toggleSelection(name);
            },
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color:
                    controller.isSelected(name)
                        ? AppColor.blueColor
                        : Colors.transparent,
                border: Border.all(
                  color:
                      controller.isSelected(name)
                          ? Colors.transparent
                          : AppColor.greyTone,
                ),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child:
                  controller.isSelected(name)
                      ? Center(
                        child: Icon(Icons.check, color: AppColor.whiteColor, size: 20.sp),
                      )
                      : null,
            ),
          ),
        ),
      ),
    );
  }
}
