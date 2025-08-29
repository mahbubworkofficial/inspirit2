

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/bottom_sheet_controller.dart';
import '../controllers/chat_controller.dart';
import 'group_chat.dart';

class UpdateGroupInfo extends StatelessWidget {
  final BottomSheetController bs = Get.put(BottomSheetController());
  final ChatController controller = Get.find();
  final TextEditingController c1 = TextEditingController();

  UpdateGroupInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          'Create Group',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leadingWidth: 30,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                        style: TextStyle(
                          color: AppColor.textGreyColor,
                          fontSize: 20,
                          fontFamily: 'Schuyler',
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: Stack(
                          children: [
                            Obx(() {
                              final file = bs.pickedImage.value;
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(200),
                                child:
                                    file != null
                                        ? Image.file(
                                          file,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          width: 100,
                                          height: 100,
                                          color: AppColor.mutedBlueGrey,
                                          child: Image.asset(
                                            ImageAssets.group,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                              );
                            }),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColor.buttonColor,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: AppColor.whiteTextColor,
                                  ),
                                  onPressed: bs.getBottomSheet,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      InputTextWidget(
                        onChanged: (value) {},
                        borderColor: AppColor.backgroundColor,
                        hintText: 'Create group name',
                        hintTextColor: AppColor.textGreyColor2,
                        textColor: AppColor.textGreyColor2,
                        height: 48,
                      ),
                      const SizedBox(height: 10),
                      InputTextWidget(
                        onChanged: (value) {},
                        borderColor: AppColor.backgroundColor,
                        hintText: 'Group bio',
                        hintTextColor: AppColor.textGreyColor2,
                        textColor: AppColor.textGreyColor2,
                        maxLines: 10,
                        height: 150,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Group Type',
                        style: TextStyle(
                          color: AppColor.textBlackColor,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => Column(
                          children: [
                            groupOption("Public"),
                            groupOption("Private"),
                          ],
                        ),
                      ),
                      const Spacer(), // pushes button to bottom
                      CustomButton(
                        title: 'Update',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        onPress: () async {
                          Get.to(
                            GroupChat(name: c1.text),
                            transition: Transition.rightToLeft,
                          );
                        },
                        buttonColor: AppColor.buttonColor,
                        height: 50,
                        radius: 30,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget groupOption(String label) {
    bool isSelected = controller.selectedGroupType.value == label;
    return GestureDetector(
      onTap: () => controller.selectedGroupType.value = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? AppColor.textTitleColor
                          : AppColor.grey400Color,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.textTitleColor,
                          ),
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColor.greyTone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
