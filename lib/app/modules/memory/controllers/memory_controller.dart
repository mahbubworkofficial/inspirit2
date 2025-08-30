import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../res/colors/app_color.dart';
import '../../../../res/components/api_service.dart';
import '../../../../widgets/show_custom_snack_ber.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/views/navbar.dart';
import '../models/condolence.dart';
import '../models/memory.dart';
import '../models/person.dart';
import '../views/memory_details_view.dart';
import '../views/memory_history_view.dart';

class MemoryController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService apiService = ApiService();

  RxInt selectedIndex = (-1).obs;
  RxString selectedEventType = ''.obs;
  var selectedRole = ''.obs;
  var personId = ''.obs;
  var memoryId = ''.obs;
  var personsList = <Person>[].obs;
  var hasMore = true.obs;
  var personsListCount = 0.obs;
  var page = 1.obs;
  var memoriesList = <Memory>[].obs;
  var memoriesListCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxString errorMessage = ''.obs;
  var searchQuery = ''.obs;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final dodController = TextEditingController();
  final detailsController = TextEditingController();
  var whoCanSee = ''.obs;
  Rxn<File> pickedImage = Rxn<File>();
  RxList<String> imagePaths = <String>[].obs;
  final RxString selectedTab = 'Memorial'.obs;
  final RxString historySelectedTab = 'Memorial'.obs;
  final count = 0.obs;
  RxBool isFabVisible = true.obs;
  RxBool isMemorialSelected = false.obs;
  final condolenceTextController = TextEditingController();
  var isSendingCondolence = false.obs;
  var hasText = false.obs;
  var condolencesCount = 0.obs;
  var condolences = <Condolence>[].obs;
  final int pageSize = 20;
  var isFetching = false.obs;

  void _setLoading(bool v) {
    if (isLoading.value != v) isLoading.value = v;
  }

  void _setMoreLoading(bool value) {
    if (isMoreLoading.value != value) isMoreLoading.value = value;
  }

  void _setError(String msg) {
    errorMessage.value = msg;
    showCustomSnackBar(
      title: 'Error',
      message: msg,
      backgroundColor: AppColor.redColor,
      isSuccess: false,
    );
  }

  Future<void> pickVideoOrImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(); // 👈 multiple images

    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        imagePaths.add(file.path); // add each image path
      }
      isMemorialSelected.value = false;
      showCustomSnackBar(
        title: 'Success',
        message: '${pickedFiles.length} image(s) added successfully',
        isSuccess: true,
      );
    } else {
      showCustomSnackBar(
        title: 'Info',
        message: 'No images selected',
        isSuccess: false,
      );
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < imagePaths.length) {
      imagePaths.removeAt(index);
      showCustomSnackBar(
        title: 'Success',
        message: 'Image removed successfully',
        isSuccess: true,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    condolenceTextController.addListener(() {
      hasText.value = condolenceTextController.text.trim().isNotEmpty;
    });
    fetchCondolences();
  }
  Future<void> fetchCondolences({bool isLoadMore = false}) async {
    if (isFetching.value) {
      debugPrint('fetchCondolences: Already fetching, skipping');
      return;
    }
    if (authController.accessToken.value.isEmpty) {
      debugPrint('fetchCondolences: No auth token available');
      _setLoading(false);
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view condolences',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;

    if (isLoadMore) {
      if (!hasMore.value || isMoreLoading.value) {
        debugPrint('fetchCondolences: No more data or already loading more');
        return;
      }
      _setMoreLoading(true);
      page.value += 1;
    } else {
      _setLoading(true);
      page.value = 1;
      condolences.clear();
    }

    isFetching.value = true;
    debugPrint('fetchCondolences: Starting with token: $token, page: ${page.value}');

    try {
      final response = await apiService.fetchCondolences(token, page: page.value);
      debugPrint('fetchCondolences response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        if (data.isEmpty) {
          hasMore(false);
          debugPrint('fetchCondolences: No more condolences available');
          condolencesCount.value++;
        } else {
          final newCondolences = data.map((json) => Condolence.fromJson(json)).toList();
          // Deduplicate by id
          final existingIds = condolences.map((c) => c.id).toSet();
          final uniqueCondolences = newCondolences.where((c) => !existingIds.contains(c.id)).toList();
          condolences.addAll(uniqueCondolences);
          debugPrint('fetchCondolences: Added ${uniqueCondolences.length} new condolences, total: ${condolences.length}');
        }
      } else {
        hasMore(false);
        final errorMsg = response['data']['error'] ?? 'Failed to load condolences';
        debugPrint('fetchCondolences Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchCondolences Exception: $e\n$stackTrace');
      _setLoading(false);
      hasMore(false);
      _setError('Failed to load condolences: $e');
    } finally {
      _setLoading(false);
      _setMoreLoading(false);
      isFetching.value = false;
    }
  }

  Future<void> submitCondolence() async {
    final token = authController.accessToken.value;
    if (token.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to submit a condolence',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final text = condolenceTextController.text.trim();
    if (text.isEmpty || isSendingCondolence.value) return;

    isSendingCondolence.value = true;
    try {
      final response = await apiService.createCondolence(token, text);
      if (response['statusCode'] == 200) {
        final created = Condolence.fromJson(
          response['data'] as Map<String, dynamic>,
        );
        condolences.insert(
          0,
          created,
        ); // Insert at top for immediate visibility
        condolenceTextController.clear();
        hasText.value = false;
        Get.to(MemoryHistoryView(), transition: Transition.leftToRightWithFade);
        showCustomSnackBar(
          title: 'Success',
          message: 'Condolence submitted successfully!',
          backgroundColor: AppColor.lightGreenColor,
          isSuccess: true,
        );
      } else {
        showCustomSnackBar(
          title: 'Error',
          message: response['data']['error'] ?? 'Failed to submit condolence',
          backgroundColor: AppColor.redColor,
          isSuccess: false,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to submit condolence: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    } finally {
      isSendingCondolence.value = false;
    }
  }

  Future<void> fetchMemories({bool isLoadMore = false}) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
      _setLoading(false);
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view memories',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;

    if (isLoadMore) {
      if (!hasMore.value || isMoreLoading.value) return;
      _setMoreLoading(true);
      page.value += 1;
    } else {
      _setLoading(true);
      page.value = 1;
      memoriesList.clear();
    }

    debugPrint(
      'Calling fetchMemories with token: $token, personId: ${personId.value}, page: ${page.value}',
    );

    try {
      final response = await apiService.fetchMemories(token, personId.value);
      debugPrint('fetchMemories response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        if (data.isEmpty) {
          hasMore(false);
          debugPrint('No more memories available');
          memoriesListCount.value++;
        } else {
          memoriesList.addAll(
            data.map((json) => Memory.fromJson(json)).toList(),
          );
          debugPrint('Memories added: ${memoriesList.length}');
        }
      } else {
        hasMore(false);
        final errorMsg = response['data']['error'] ?? 'Failed to load memories';
        debugPrint('fetchMemories Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchMemories Exception: $e\n$stackTrace');
      _setLoading(false);
      hasMore(false);
      _setError('Failed to load memories: $e');
    } finally {
      _setLoading(false);
      _setMoreLoading(false);
    }
  }

  Future<void> deletePerson(String requestId) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
      _setLoading(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to delete friend request',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    _setLoading(true);

    try {
      final response = await apiService.deletePerson(token, requestId);
      debugPrint('deleteFriendRequest response: $response');

      if (response['statusCode'] == 204) {
        // Optionally update friendsList by removing the deleted request
        personsList.removeWhere((person) => person.id == int.parse(requestId));
        showCustomSnackBar(
          title: 'Success',
          message: 'Friend request deleted successfully',
          isSuccess: true,
        );
      } else {
        final errorMsg =
            response['data']['error'] ?? 'Failed to delete friend request';
        _setError(errorMsg);
      }
    } catch (e, st) {
      debugPrint('deleteFriendRequest Exception: $e\n$st');
      _setError('Failed to delete friend request: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPersons({bool isLoadMore = false}) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
      _setLoading(false);
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view persons',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;

    if (isLoadMore) {
      if (!hasMore.value || isMoreLoading.value) return;
      _setMoreLoading(true);
      page.value += 1;
    } else {
      _setLoading(true);
      page.value = 1;
      personsList.clear();
    }

    debugPrint('Calling fetchPersons with token: $token, page: ${page.value}');

    try {
      final response = await apiService.fetchPersons(token);
      debugPrint('fetchPersons response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        if (data.isEmpty) {
          hasMore(false);
          debugPrint('No more persons available');
          personsListCount.value++;
        } else {
          personsList.addAll(
            data.map((json) => Person.fromJson(json)).toList(),
          );
          debugPrint('Persons added: ${personsList.length}');
        }
      } else {
        hasMore(false);
        final errorMsg = response['data']['error'] ?? 'Failed to load persons';
        debugPrint('fetchPersons Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchPersons Exception: $e\n$stackTrace');
      _setLoading(false);
      hasMore(false);
      _setError('Failed to load persons: $e');
    } finally {
      _setLoading(false);
      _setMoreLoading(false);
    }
  }

  Future<void> updatePerson() async {
    final id = personId.value.trim();
    final name = nameController.text.trim();
    final dateOfBirth = dobController.text.trim();
    final dateOfDeath = dodController.text.trim();
    final details = detailsController.text.trim();
    final File profilePhoto = pickedImage.value!;
    final whoCanSee = selectedRole.value;
    final token = authController.accessToken.value;

    debugPrint(
      "nameController______________________ ${nameController.text} _______________________",
    );
    debugPrint('Updating profile with token: $token');
    debugPrint('Updating profile with id: $id');
    debugPrint('Updating profile with name: $name');
    debugPrint('Updating profile with dateOfBirth: $dateOfBirth');
    debugPrint('Updating profile with dateOfDeath: $dateOfDeath');
    debugPrint('Updating profile with details: $details');

    try {
      _setLoading(true);
      final response = await apiService.updatePerson(
        id,
        name,
        dateOfBirth,
        dateOfDeath,
        details,
        profilePhoto,
        whoCanSee,
        token,
      );
      if (response['statusCode'] == 200) {
        final data = response['data'];
        final message = data['message'] ?? 'Password set successfully';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        authController.isSignedIn.value = true;
        final String index = Get.arguments?['index'] as String? ?? '0';
        Get.to(
          MemoryDetailsView(),
          transition: Transition.rightToLeftWithFade,
          arguments: {'index': index.toString()},
        );
      } else {
        final data = response['data'];
        final errorMsg =
            data['messages'] is String
                ? data['messages']
                : data['detail'] ?? 'Unknown error occurred';
        errorMessage.value = errorMsg;
        _setError('Failed to update profile: $errorMsg');
      }
    } catch (e, st) {
      debugPrint('Failed to update profile: $e\n$st');
      errorMessage.value = 'Error: $e';
      _setError('Failed to update profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> postPerson() async {
    final name = nameController.text.trim();
    final dateOfBirth = dobController.text.trim();
    final dateOfDeath = dodController.text.trim();
    final details = detailsController.text.trim();
    final File profilePhoto = pickedImage.value!;
    final whoCanSee = selectedRole.value;
    final token = authController.accessToken.value;
    debugPrint('Updating profile with token: $token');

    try {
      _setLoading(true);
      final response = await apiService.createPerson(
        name,
        dateOfBirth,
        dateOfDeath,
        details,
        profilePhoto,
        whoCanSee,
        token,
      );
      if (response['statusCode'] == 200) {
        final data = response['data'];
        final message = data['message'] ?? 'Password set successfully';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        authController.isSignedIn.value = true;
        Get.to(MemoryDetailsView(), transition: Transition.rightToLeftWithFade);
      } else {
        final data = response['data'];
        final errorMsg =
            data['messages'] is String
                ? data['messages']
                : data['detail'] ?? 'Unknown error occurred';
        errorMessage.value = errorMsg;
        _setError('Failed to update profile: $errorMsg');
      }
    } catch (e, st) {
      debugPrint('Failed to update profile: $e\n$st');
      errorMessage.value = 'Error: $e';
      _setError('Failed to update profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMemory() async {
    final id = memoryId.value.trim();
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final dateOfMemory = dateController.text.trim(); // yyyy-mm-dd
    final token = authController.accessToken.value;
    debugPrint('Updating profile with token: $token');

    _setLoading(true);
    final response = await apiService.updateMemory(
      id,
      title,
      dateOfMemory,
      description,
      imagePaths.map((path) => File(path)).toList(),
      token,
    );

    if (response['statusCode'] == 201 || response['statusCode'] == 200) {
      debugPrint('Memory updated successfully ________ $response');
      showCustomSnackBar(
        title: 'Success',
        message: 'Memory updated successfully!',
        isSuccess: true,
      );
      // Get.dialog(
      //   Dialog(
      //     backgroundColor: Colors.transparent,
      //     elevation: 0,
      //     child: CenteredDialogWidget(
      //       title: 'Profile Updated',
      //       horizontalPadding: 2.w,
      //       verticalPadding: 20.h,
      //       subtitle:
      //       'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim',
      //       imageAsset: ImageAssets.post_report,
      //       backgroundColor: AppColor.backgroundColor,
      //       iconBackgroundColor: Colors.transparent,
      //       iconColor: AppColor.buttonColor,
      //       borderRadius: 30.r,
      //     ),
      //   ),
      // );
      Get.off(() => Navigation(), transition: Transition.fadeIn);
      // Future.delayed(const Duration(seconds: 2), () {
      //   try {
      //   } catch (e) {
      //     showCustomSnackBar(
      //       title: 'Navigation Error',
      //       message: 'Failed to navigate to Event screen: $e',
      //       isSuccess: false,
      //     );
      //   }
      // });
    } else {
      final errorMsg =
          response['data']['error'] ??
          response['data']['detail'] ??
          'Unknown error';
      _setError('Failed to update memory: $errorMsg');
    }
    _setLoading(false);
  }

  Future<void> postMemory() async {
    final id = personId.value.trim();
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final dateOfMemory = dateController.text.trim(); // yyyy-mm-dd
    final token = authController.accessToken.value;
    debugPrint('Updating profile with token: $token');

    _setLoading(true);
    final response = await apiService.createMemory(
      id,
      title,
      dateOfMemory,
      description,
      imagePaths.map((path) => File(path)).toList(),
      token,
    );

    if (response['statusCode'] == 201) {
      showCustomSnackBar(
        title: 'Success',
        message: 'Memory posted successfully!',
        isSuccess: true,
      );
      // Get.dialog(
      //   Dialog(
      //     backgroundColor: Colors.transparent,
      //     elevation: 0,
      //     child: CenteredDialogWidget(
      //       title: 'Profile Updated',
      //       horizontalPadding: 2.w,
      //       verticalPadding: 20.h,
      //       subtitle:
      //       'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim',
      //       imageAsset: ImageAssets.post_report,
      //       backgroundColor: AppColor.backgroundColor,
      //       iconBackgroundColor: Colors.transparent,
      //       iconColor: AppColor.buttonColor,
      //       borderRadius: 30.r,
      //     ),
      //   ),
      // );
      Get.off(() => Navigation(), transition: Transition.fadeIn);
      // Future.delayed(const Duration(seconds: 2), () {
      //   try {
      //   } catch (e) {
      //     showCustomSnackBar(
      //       title: 'Navigation Error',
      //       message: 'Failed to navigate to Event screen: $e',
      //       isSuccess: false,
      //     );
      //   }
      // });
    } else {
      final errorMsg =
          response['data']['error'] ??
          response['data']['detail'] ??
          'Unknown error';
      _setError('Failed to post memory: $errorMsg');
    }
    _setLoading(false);
  }

  void setSelectedRole(String role) {
    selectedRole.value = role;
  }

  void selectOption(int index, String text) {
    selectedIndex.value = index;
    selectedEventType.value = text;
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
  }

  void setHistorySelectedTab(String tab) {
    historySelectedTab.value = tab;
  }

  void setSelectedTab(String tab) {
    selectedTab.value = tab;
  }

  void toggleFabVisibility() {
    isFabVisible.value = !isFabVisible.value;
  }

  @override
  void onClose() {
    condolenceTextController.dispose();
    super.onClose();
  }
}
