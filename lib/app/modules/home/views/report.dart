import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/dialogue.dart';
import '../controllers/home_controller.dart';
import '../widget/custom_button.dart';

class Report extends GetView<HomeController> {
  const Report({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Report Post',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 20,
                        ),
                        child: Text(
                          'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                          style: TextStyle(
                            color: AppColor.textGreyColor,
                            fontSize: 20,
                            fontFamily: 'Schuyler',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      Obx(
                        () => Column(
                          children: [
                            _buildReportOption('Inappropriate Content'),
                            _buildReportOption('Misinformation'),
                            _buildReportOption('Harassment or Hate Speech'),
                            _buildReportOption('Privacy Violation'),
                            _buildReportOption('Other'),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 30.0),
                        child: CustomButton(
                          title: 'Report',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          height: 50,
                          radius: 30,
                          onPress: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (dialogContext) {
                                Future.delayed(Duration(seconds: 2), () {
                                  Navigator.of(dialogContext).pop();
                                  Get.back();
                                });

                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: CenteredDialogWidget(
                                    title: 'Post Reported',
                                    subtitle:
                                        'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim',
                                    imageAsset: ImageAssets.postReport,
                                    backgroundColor: AppColor.backgroundColor,
                                    iconBackgroundColor: Colors.transparent,
                                    iconColor: AppColor.buttonColor,
                                    borderRadius: 30.0,
                                    horizontalPadding: 1,
                                  ),
                                );
                              },
                            );
                          },
                          buttonColor:
                              controller.isselected.value
                                  ? AppColor.buttonColor
                                  : AppColor.buttonDisableColor,
                        ),
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

  Widget _buildReportOption(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CustomActionButton(
        text: value,
        onPressed: () {
          controller.selectedreportype(value);
          if (!controller.isselected.value) {
            controller.isselected.value = true;
          }
        },
        backgroundColor:
            controller.selectedreportype.value == value
                ? AppColor.beigeBrown
                : AppColor.softBeige,
        borderColor: Colors.transparent,
        textColor:
            controller.selectedreportype.value == value
                ? AppColor.whiteTextColor
                : AppColor.greyTone,
      ),
    );
  }
}
