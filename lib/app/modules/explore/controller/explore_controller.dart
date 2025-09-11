import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../res/components/api_service.dart';
import '../../../../widgets/dialogue.dart';
import '../../../../widgets/show_custom_snack_bar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/views/navbar.dart';
import '../models/event.dart';

class ExploreController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService apiService = ApiService();

  RxInt selectedIndex = (-1).obs;
  RxString selectedEventType = ''.obs;
  RxBool isEventSelected = false.obs;
  var searchQuery = ''.obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var hasMore = true.obs;
  var errorMessage = ''.obs;
  var eventId = ''.obs;
  var eventType = ''.obs;
  var eventsList = <Event>[].obs;
  var otherUserEvents = <Event>[].obs;
  var eventsListCount = 0.obs;
  var otherUserEventsCount = 0.obs;
  var page = 1.obs;
  var userId = ''.obs;
  RxBool hasText = false.obs;

  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  RxList<String> imagePaths = <String>[].obs;

  final RxString selectedTab = 'User'.obs;
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  static const LatLng initialLocation = LatLng(40.735657, -73.996167);
  final Set<Marker> markers = {
    const Marker(
      markerId: MarkerId('location'),
      position: initialLocation,
      infoWindow: InfoWindow(title: '47 W 13th St, New York'),
    ),
  };

  void onMapCreated(GoogleMapController controller) {
    debugPrint('Map created successfully'); // Debug log
    mapController.value = controller;
  }

  void setSelectedTab(String tab) {
    selectedTab.value = tab;
  }

  void onTextChanged(String value) {
    hasText.value = value.trim().isNotEmpty;
  }

  void _setLoading(bool v) {
    if (isLoading.value != v) isLoading.value = v;
  }

  void selectOption(int index, String text) {
    selectedIndex.value = index;
    selectedEventType.value = text;
  }

  void _setError(String msg) {
    errorMessage.value = msg;
    showCustomSnackBar(
      title: 'Error',
      message: msg,
      isSuccess: false,
    );
  }

  void _setMoreLoading(bool v) {
    if (isMoreLoading.value != v) isMoreLoading.value = v;
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

  Future<void> pickVideoOrImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(); // 👈 multiple images

    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        imagePaths.add(file.path); // add each image path
      }
      isEventSelected.value = false;
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

  Future<void> fetchOtherUserEvents({bool isLoadMore = false}) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
      _setLoading(false);
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view events',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;

    if (isLoadMore) {
      if (!hasMore.value || isMoreLoading.value) return;
      _setMoreLoading(true);
      page.value += 1;
    } else {
      _setLoading(true);
      page.value = 1;
      otherUserEvents.clear();
    }

    debugPrint(
      'Calling fetchOtherUserEvents with token: $token, userId: ${userId.value}, page: ${page.value}',
    );

    try {
      final response = await apiService.fetchOtherUserEvents(
        token,
        userId.value,
        page.value,
      );
      debugPrint('fetchOtherUserEvents response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        if (data.isEmpty) {
          hasMore(false);
          debugPrint('No more events available');
          otherUserEventsCount.value++;
        } else {
          otherUserEvents.addAll(
            data.map((json) => Event.fromJson(json)).toList(),
          );
          debugPrint('Events added: ${otherUserEvents.length}');
        }
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchOtherUserEvents(
            newToken!,
            userId.value,
            page.value,
          );
          debugPrint('Retry fetchOtherUserEvents response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'] as List<dynamic>;
            if (data.isEmpty) {
              hasMore(false);
              debugPrint('No more events available');
              otherUserEventsCount.value++;
            } else {
              otherUserEvents.addAll(
                data.map((json) => Event.fromJson(json)).toList(),
              );
              debugPrint('Events added: ${otherUserEvents.length}');
            }
          } else {
            hasMore(false);
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to load events after token refresh';
            debugPrint('Retry fetchOtherUserEvents Error: $errorMsg');
            _setError(errorMsg);
            Get.offAllNamed('/login');
          }
        } else {
          hasMore(false);
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        hasMore(false);
        final errorMsg = response['data']['error'] ?? 'Failed to load events';
        debugPrint('fetchOtherUserEvents Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchOtherUserEvents Exception: $e\n$stackTrace');
      _setLoading(false);
      hasMore(false);
      _setError('Failed to load events: $e');
    } finally {
      _setLoading(false);
      _setMoreLoading(false);
    }
  }

  Future<void> fetchEvents() async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
      _setLoading(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view events',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;

    _setLoading(true);
    try {
      final response = await apiService.fetchEvents(token);
      debugPrint('fetchEvents response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        eventsList.assignAll(data.map((json) => Event.fromJson(json)).toList());
        eventsListCount.value = eventsList.length;
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchEvents(newToken!);
          debugPrint('Retry fetchEvents response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'] as List<dynamic>;
            eventsList.assignAll(
              data.map((json) => Event.fromJson(json)).toList(),
            );
            eventsListCount.value = eventsList.length;
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to load events after token refresh';
            debugPrint('Retry fetchEvents Error: $errorMsg');
            _setError(errorMsg);
            Get.offAllNamed('/login');
          }
        } else {
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        final errorMsg = response['data']['error'] ?? 'Failed to load events';
        debugPrint('fetchEvents Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchEvents Exception: $e\n$stackTrace');
      _setError('Failed to load events: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEvent() async {
    final id = eventId.value.trim();
    final type = eventType.value.trim();
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final dateOfMemory = dateController.text.trim();
    final time = timeController.text.trim();
    final location = locationController.text.trim();
    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;
    _setLoading(true);
    final response = await apiService.updateEvent(
      id,
      type,
      title,
      dateOfMemory,
      time,
      location,
      description,
      imagePaths.map((path) => File(path)).toList(),
      token,
    );

    if (response['statusCode'] == 200) {
      showCustomSnackBar(
        title: 'Success',
        message: 'Memory updated successfully!',
        isSuccess: true,
      );
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: CenteredDialogWidget(
            title: 'Update Created',
            horizontalPadding: 2.0.w,
            verticalPadding: 20.0.h,
            subtitle:
                'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim',
            imageAsset: ImageAssets.postReport,
            backgroundColor: AppColor.backgroundColor,
            iconBackgroundColor: Colors.transparent,
            iconColor: AppColor.buttonColor,
            borderRadius: 30.0.r,
          ),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        try {
          Get.off(() => Navigation(), transition: Transition.fadeIn);
        } catch (e) {
          showCustomSnackBar(
            title: 'Navigation Error',
            message: 'Failed to navigate to Event screen: $e',
            isSuccess: false,
          );
        }
      });
    } else if (response['statusCode'] == 401) {
      final refreshed = await authController.refreshAccessToken(refresh);
      if (refreshed) {
        final newToken = await authController.getAccessToken();
        final retryResponse = await apiService.updateEvent(
          id,
          type,
          title,
          dateOfMemory,
          time,
          location,
          description,
          imagePaths.map((path) => File(path)).toList(),
          newToken!,
        );

        if (retryResponse['statusCode'] == 200) {
          showCustomSnackBar(
            title: 'Success',
            message: 'Memory updated successfully!',
            isSuccess: true,
          );
          Get.dialog(
            Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: CenteredDialogWidget(
                title: 'Update Created',
                horizontalPadding: 2.0.w,
                verticalPadding: 20.0.h,
                subtitle:
                    'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim',
                imageAsset: ImageAssets.postReport,
                backgroundColor: AppColor.backgroundColor,
                iconBackgroundColor: Colors.transparent,
                iconColor: AppColor.buttonColor,
                borderRadius: 30.0.r,
              ),
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            try {
              Get.off(() => Navigation(), transition: Transition.fadeIn);
            } catch (e) {
              showCustomSnackBar(
                title: 'Navigation Error',
                message: 'Failed to navigate to Event screen: $e',
                isSuccess: false,
              );
            }
          });
        } else {
          final errorMsg =
              retryResponse['data']['error'] ??
              'Failed to update event after token refresh';
          _setError('Failed to Update Event: $errorMsg');
          debugPrint('Retry Failed to Update Event: $errorMsg');
          Get.offAllNamed('/login');
        }
      } else {
        _setError('Failed to refresh token. Please log in again.');
        Get.offAllNamed('/login');
      }
    } else {
      final errorMsg =
          response['data']['error'] ??
          response['data']['detail'] ??
          'Unknown error';
      _setError('Failed to Update Event: $errorMsg');
      debugPrint('Failed to Update Event: $errorMsg');
    }
    _setLoading(false);
  }

  Future<void> postEvent() async {
    final type = selectedEventType.value.trim();
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final dateOfMemory = dateController.text.trim(); // yyyy-mm-dd
    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;
    final time = timeController.text.trim();
    final location = locationController.text.trim();

    _setLoading(true);
    try {
      final response = await apiService.createEvent(
        type,
        title,
        dateOfMemory,
        time,
        location,
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
        Get.off(() => Navigation(), transition: Transition.fadeIn);
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.createEvent(
            type,
            title,
            dateOfMemory,
            time,
            location,
            description,
            imagePaths.map((path) => File(path)).toList(),
            newToken!,
          );

          if (retryResponse['statusCode'] == 201) {
            showCustomSnackBar(
              title: 'Success',
              message: 'Memory posted successfully!',
              isSuccess: true,
            );
            Get.off(() => Navigation(), transition: Transition.fadeIn);
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to post event after token refresh';
            _setError('Failed to post memory: $errorMsg');
            debugPrint('Retry Failed to post memory: $errorMsg');
            Get.offAllNamed('/login');
          }
        } else {
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['detail'] ??
            'Unknown error';
        _setError('Failed to post memory: $errorMsg');
      }
    } catch (e, stackTrace) {
      debugPrint('postEvent Exception: $e\n$stackTrace');
      _setError('Failed to post memory: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void onClose() {
    mapController.value?.dispose();
    debugPrint('Map controller disposed'); // Debug log
    super.onClose();
  }
}
