import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../res/components/api_service.dart';
import '../../../../widgets/dialogue.dart';
import '../../../../widgets/show_custom_snack_ber.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  final ApiService apiService = ApiService();
  final AuthController authController = Get.find<AuthController>();
  var isLoading = RxBool(false);
  var pickedImage = Rx<File?>(null);
  var isMemorialSelected = RxBool(false);
  var content = ''.obs; // For the post content
  var scheduledDate = Rx<String?>(null); // Optional scheduled date
  var scheduledTime = Rx<String?>(null); // Optional scheduled time
  final TextEditingController contentController = TextEditingController();

  // Create post method
  Future<void> createPost() async {
    final String token = authController.accessToken.value;

    // Ensure content is not empty
    if (content.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Content is required!',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
      return;
    }

    try {
      isLoading(true); // Show loading indicator
      final response = await apiService.postCreate(
        content: content.value,
        image: pickedImage.value,
        scheduledDate: scheduledDate.value,
        scheduledTime: scheduledTime.value,
        token: token,
      );

      if (response['statusCode'] == 201) {
        final message = response['data']['message'] ?? 'Post created successfully!';
        showCustomSnackBar(
          title: 'Success',
          message: message,
          isSuccess: true,
        );

        // Show success dialog
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: CenteredDialogWidget(
              title: 'Post Reported',
              subtitle: 'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim.',
              imageAsset: ImageAssets.postReport,
              backgroundColor: AppColor.backgroundColor,
              iconBackgroundColor: Colors.transparent,
              iconColor: AppColor.buttonColor,
              borderRadius: 30.0.r,
            ),
          ),
        );
        content = ''.obs;
      } else {
        final errorMsg = response['data']['error'] ?? response['data']['message'] ?? 'Post creation failed';
        showCustomSnackBar(
          title: 'Error',
          message: errorMsg,
          backgroundColor: AppColor.redColor,
          isSuccess: false,
        );
      }
    } catch (e) {
      debugPrint('Post creation error: $e');
      showCustomSnackBar(
        title: 'Error',
        message: 'Post creation failed: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    } finally {
      isLoading(false); // Hide loading indicator
    }
  }

  // Handle other UI functionalities
  var currentIndex = 0.obs;
  var isFabMenuOpen = false.obs;
  RxBool isselected = false.obs;
  var selectedreportype = "".obs;
  var showAll = true.obs;

  void toggleView(bool value) {
    showAll.value = value;
  }
  Rxn<File> pickedImageschedule = Rxn<File>();


}
