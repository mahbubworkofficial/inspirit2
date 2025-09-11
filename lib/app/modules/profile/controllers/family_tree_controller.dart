import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jordyn/app/modules/auth/controllers/auth_controller.dart';
import 'package:jordyn/res/app_url/app_url.dart';

import '../../../../res/colors/app_color.dart';
import '../../../../widgets/show_custom_snack_bar.dart';
import '../views/family_member.dart';

class FamilyTreeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final RxMap<String, FamilyMember> familyMembers = <String, FamilyMember>{}.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _initializeFamilyTree();
    fetchFamilyTreeData();
  }

  void _initializeFamilyTree() {
    // Initialize family members without image paths
    familyMembers['grandpa2'] = FamilyMember(id: 'grandpa2', name: 'Grandpa', initialImage: null);
    familyMembers['grandpa1'] = FamilyMember(id: 'grandpa1', name: 'Grandpa', initialImage: null);
    familyMembers['grandma2'] = FamilyMember(id: 'grandma2', name: 'Grandma', initialImage: null);
    familyMembers['grandma1'] = FamilyMember(id: 'grandma1', name: 'Grandma', initialImage: null);
    familyMembers['dad'] = FamilyMember(id: 'dad', name: 'Dad', initialImage: null);
    familyMembers['mom'] = FamilyMember(id: 'mom', name: 'Mom', initialImage: null);
    familyMembers['uncle'] = FamilyMember(id: 'uncle', name: 'Uncle', initialImage: null);
    familyMembers['aunt'] = FamilyMember(id: 'aunt', name: 'Aunt', initialImage: null);
    familyMembers['son1'] = FamilyMember(id: 'son1', name: 'Son', initialImage: null);
    familyMembers['son2'] = FamilyMember(id: 'son2', name: 'Son', initialImage: null);
    familyMembers['brother'] = FamilyMember(id: 'brother', name: 'Brother', initialImage: null);
    familyMembers['sister'] = FamilyMember(id: 'sister', name: 'Sister', initialImage: null);
    familyMembers['me'] = FamilyMember(id: 'me', name: 'Me', initialImage: null);
  }

  Future<void> pickImage(String memberId) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final String imagePath = pickedFile.path;
      familyMembers[memberId]?.image.value = imagePath;

      // Send the updated image to the server
      await _updateFamilyTreeImage(memberId, File(imagePath));
    }
  }

  Future<void> _updateFamilyTreeImage(String memberId, File imageFile) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('_updateFamilyTreeImage: No auth token available');
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to update family tree image.',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;
    final url = Uri.parse(AppUrl.treeUrl);

    try {
      var request = http.MultipartRequest('PATCH', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['me'] = '16' // Assuming user ID for 'me'
        ..fields['grandma1'] = familyMembers['grandma1']?.image.value ?? ''
        ..fields['grandpa1'] = familyMembers['grandpa1']?.image.value ?? ''
        ..fields['grandma2'] = familyMembers['grandma2']?.image.value ?? ''
        ..fields['grandpa2'] = familyMembers['grandpa2']?.image.value ?? ''
        ..fields['mom'] = familyMembers['mom']?.image.value ?? ''
        ..fields['dad'] = familyMembers['dad']?.image.value ?? ''
        ..fields['brother'] = familyMembers['brother']?.image.value ?? ''
        ..fields['sister'] = familyMembers['sister']?.image.value ?? ''
        ..fields['son1'] = familyMembers['son1']?.image.value ?? ''
        ..fields['son2'] = familyMembers['son2']?.image.value ?? '';

      request.files.add(await http.MultipartFile.fromPath(memberId, imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (response.statusCode == 200) {
        if (data[memberId] != null) {
          familyMembers[memberId]?.image.value = data[memberId];
        }
        showCustomSnackBar(
          title: 'Success',
          message: 'Image updated successfully!',
          isSuccess: true,
        );
      } else if (response.statusCode == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          var retryRequest = http.MultipartRequest('PATCH', url)
            ..headers['Authorization'] = 'Bearer $newToken'
            ..fields['me'] = '16'
            ..fields['grandma1'] = familyMembers['grandma1']?.image.value ?? ''
            ..fields['grandpa1'] = familyMembers['grandpa1']?.image.value ?? ''
            ..fields['grandma2'] = familyMembers['grandma2']?.image.value ?? ''
            ..fields['grandpa2'] = familyMembers['grandpa2']?.image.value ?? ''
            ..fields['mom'] = familyMembers['mom']?.image.value ?? ''
            ..fields['dad'] = familyMembers['dad']?.image.value ?? ''
            ..fields['brother'] = familyMembers['brother']?.image.value ?? ''
            ..fields['sister'] = familyMembers['sister']?.image.value ?? ''
            ..fields['son1'] = familyMembers['son1']?.image.value ?? ''
            ..fields['son2'] = familyMembers['son2']?.image.value ?? '';

          retryRequest.files.add(await http.MultipartFile.fromPath(memberId, imageFile.path));

          final retryResponse = await retryRequest.send();
          final retryResponseData = await retryResponse.stream.bytesToString();
          final retryData = jsonDecode(retryResponseData);

          if (retryResponse.statusCode == 200) {
            if (retryData[memberId] != null) {
              familyMembers[memberId]?.image.value = retryData[memberId];
            }
            showCustomSnackBar(
              title: 'Success',
              message: 'Image updated successfully!',
              backgroundColor: AppColor.lightGreenColor,
              isSuccess: true,
            );
          } else {
            final errorMsg = retryData['error'] ?? 'Failed to update image after token refresh';
            debugPrint('_updateFamilyTreeImage Retry Error: $errorMsg');
            showCustomSnackBar(
              title: 'Error',
              message: errorMsg,
              isSuccess: false,
            );
            Get.offAllNamed('/login');
          }
        } else {
          showCustomSnackBar(
            title: 'Error',
            message: 'Failed to refresh token. Please log in again.',
            isSuccess: false,
          );
          Get.offAllNamed('/login');
        }
      } else {
        final errorMsg = data['error'] ?? 'Failed to update image';
        debugPrint('_updateFamilyTreeImage Error: $errorMsg');
        showCustomSnackBar(
          title: 'Error',
          message: errorMsg,
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('_updateFamilyTreeImage Exception: $e\n$stackTrace');
      showCustomSnackBar(
        title: 'Error',
        message: 'An error occurred: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> fetchFamilyTreeData() async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('fetchFamilyTreeData: No auth token available');
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view family tree.',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;
    final url = Uri.parse(AppUrl.treeUrl);

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        familyMembers['me']?.image.value = data['me'] is String ? data['me'] : null;
        familyMembers['grandpa1']?.image.value = data['grandpa1'] is String ? data['grandpa1'] : null;
        familyMembers['grandma1']?.image.value = data['grandma1'] is String ? data['grandma1'] : null;
        familyMembers['grandma2']?.image.value = data['grandma2'] is String ? data['grandma2'] : null;
        familyMembers['grandpa2']?.image.value = data['grandpa2'] is String ? data['grandpa2'] : null;
        familyMembers['mom']?.image.value = data['mom'] is String ? data['mom'] : null;
        familyMembers['dad']?.image.value = data['dad'] is String ? data['dad'] : null;
        familyMembers['brother']?.image.value = data['brother'] is String ? data['brother'] : null;
        familyMembers['sister']?.image.value = data['sister'] is String ? data['sister'] : null;
        familyMembers['son1']?.image.value = data['son1'] is String ? data['son1'] : null;
        familyMembers['son2']?.image.value = data['son2'] is String ? data['son2'] : null;
        showCustomSnackBar(
          title: 'Success',
          message: 'Family tree data fetched successfully.',
          isSuccess: true,
        );
      } else if (response.statusCode == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await http.get(
            url,
            headers: {
              'Authorization': 'Bearer $newToken',
              'Content-Type': 'application/json',
            },
          );

          if (retryResponse.statusCode == 200) {
            final data = jsonDecode(retryResponse.body);
            familyMembers['me']?.image.value = data['me'] is String ? data['me'] : null;
            familyMembers['grandpa1']?.image.value = data['grandpa1'] is String ? data['grandpa1'] : null;
            familyMembers['grandma1']?.image.value = data['grandma1'] is String ? data['grandma1'] : null;
            familyMembers['grandma2']?.image.value = data['grandma2'] is String ? data['grandma2'] : null;
            familyMembers['grandpa2']?.image.value = data['grandpa2'] is String ? data['grandpa2'] : null;
            familyMembers['mom']?.image.value = data['mom'] is String ? data['mom'] : null;
            familyMembers['dad']?.image.value = data['dad'] is String ? data['dad'] : null;
            familyMembers['brother']?.image.value = data['brother'] is String ? data['brother'] : null;
            familyMembers['sister']?.image.value = data['sister'] is String ? data['sister'] : null;
            familyMembers['son1']?.image.value = data['son1'] is String ? data['son1'] : null;
            familyMembers['son2']?.image.value = data['son2'] is String ? data['son2'] : null;
            showCustomSnackBar(
              title: 'Success',
              message: 'Family tree data fetched successfully.',
              backgroundColor: AppColor.lightGreenColor,
              isSuccess: true,
            );
          } else {
            final retryData = jsonDecode(retryResponse.body);
            final errorMsg = retryData['error'] ?? 'Failed to fetch family tree data after token refresh';
            debugPrint('fetchFamilyTreeData Retry Error: $errorMsg');
            showCustomSnackBar(
              title: 'Error',
              message: errorMsg,
              isSuccess: false,
            );
            Get.offAllNamed('/login');
          }
        } else {
          showCustomSnackBar(
            title: 'Error',
            message: 'Failed to refresh token. Please log in again.',
            isSuccess: false,
          );
          Get.offAllNamed('/login');
        }
      } else {
        final data = jsonDecode(response.body);
        final errorMsg = data['error'] ?? 'Failed to fetch family tree data';
        debugPrint('fetchFamilyTreeData Error: $errorMsg');
        showCustomSnackBar(
          title: 'Error',
          message: errorMsg,
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('fetchFamilyTreeData Exception: $e\n$stackTrace');
      showCustomSnackBar(
        title: 'Error',
        message: 'An error occurred: $e',
        isSuccess: false,
      );
    }
  }
}