import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/dialogue.dart';
import '../controllers/chat_controller.dart';

class BlockUser extends GetView<ChatController> {
  const BlockUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Block User',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                        style: TextStyle(
                          color: AppColor.textGreyColor,
                          fontSize: 20,
                          fontFamily: 'Schuyler',
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 30),
                      Image.asset(ImageAssets.text),
                      Spacer(), // Pushes the button to the bottom
                      CustomButton(
                        title: 'Block User',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        onPress: () async {
                          Get.back();
                          controller.isuserblocked.value = true;
                          showDialog(
                            context: context,
                            builder:
                                (context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: CenteredDialogWidget(
                                    title: 'User Blocked',
                                    subtitle:
                                        'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim',
                                    imageAsset: ImageAssets.postReport,
                                    backgroundColor: AppColor.backgroundColor,
                                    iconBackgroundColor: Colors.transparent,
                                    iconColor: AppColor.buttonColor,
                                    borderRadius: 30.0,
                                    horizontalPadding: 1,
                                  ),
                                ),
                          );
                        },
                        buttonColor: AppColor.buttonColor,
                        height: 50,
                        radius: 30,
                      ),
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
}
