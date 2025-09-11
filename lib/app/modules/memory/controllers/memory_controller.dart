import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../res/colors/app_color.dart';
import '../../../../res/components/api_service.dart';
import '../../../../widgets/show_custom_snack_bar.dart';
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
    showCustomSnackBar(title: 'Error', message: msg, isSuccess: false);
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
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;

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
    debugPrint(
      'fetchCondolences: Starting with token: $token, page: ${page.value}',
    );

    try {
      final response = await apiService.fetchCondolences(
        token,
        page: page.value,
      );
      debugPrint('fetchCondolences response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        if (data.isEmpty) {
          hasMore(false);
          debugPrint('fetchCondolences: No more condolences available');
          condolencesCount.value++;
        } else {
          final newCondolences =
              data.map((json) => Condolence.fromJson(json)).toList();
          final existingIds = condolences.map((c) => c.id).toSet();
          final uniqueCondolences =
              newCondolences.where((c) => !existingIds.contains(c.id)).toList();
          condolences.addAll(uniqueCondolences);
          debugPrint(
            'fetchCondolences: Added ${uniqueCondolences.length} new condolences, total: ${condolences.length}',
          );
        }
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchCondolences(
            newToken!,
            page: page.value,
          );
          debugPrint('Retry fetchCondolences response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'] as List<dynamic>;
            if (data.isEmpty) {
              hasMore(false);
              debugPrint('fetchCondolences: No more condolences available');
              condolencesCount.value++;
            } else {
              final newCondolences =
                  data.map((json) => Condolence.fromJson(json)).toList();
              final existingIds = condolences.map((c) => c.id).toSet();
              final uniqueCondolences =
                  newCondolences
                      .where((c) => !existingIds.contains(c.id))
                      .toList();
              condolences.addAll(uniqueCondolences);
              debugPrint(
                'fetchCondolences: Added ${uniqueCondolences.length} new condolences, total: ${condolences.length}',
              );
            }
          } else {
            hasMore(false);
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to load condolences after token refresh';
            debugPrint('Retry fetchCondolences Error: $errorMsg');
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
        final errorMsg =
            response['data']['error'] ?? 'Failed to load condolences';
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
    final refresh = authController.refreshToken.value;
    if (token.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to submit a condolence',

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
        condolences.insert(0, created);
        condolenceTextController.clear();
        hasText.value = false;
        Get.to(
          () => MemoryHistoryView(),
          transition: Transition.leftToRightWithFade,
        );
        showCustomSnackBar(
          title: 'Success',
          message: 'Condolence submitted successfully!',
          isSuccess: true,
        );
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.createCondolence(
            newToken!,
            text,
          );
          if (retryResponse['statusCode'] == 200) {
            final created = Condolence.fromJson(
              retryResponse['data'] as Map<String, dynamic>,
            );
            condolences.insert(0, created);
            condolenceTextController.clear();
            hasText.value = false;
            Get.to(
              () => MemoryHistoryView(),
              transition: Transition.leftToRightWithFade,
            );
            showCustomSnackBar(
              title: 'Success',
              message: 'Condolence submitted successfully!',
              backgroundColor: AppColor.lightGreenColor,
              isSuccess: true,
            );
          } else {
            showCustomSnackBar(
              title: 'Error',
              message:
                  retryResponse['data']['error'] ??
                  'Failed to submit condolence after token refresh',

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
        showCustomSnackBar(
          title: 'Error',
          message: response['data']['error'] ?? 'Failed to submit condolence',

          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('submitCondolence Exception: $e\n$stackTrace');
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to submit condolence: $e',

        isSuccess: false,
      );
    } finally {
      isSendingCondolence.value = false;
    }
  }

  Future<void> fetchMemories({bool isLoadMore = false}) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('fetchMemories: No auth token available');
      _setLoading(false);
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view memories',

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
          debugPrint('fetchMemories: No more memories available');
          memoriesListCount.value++;
        } else {
          memoriesList.addAll(
            data.map((json) => Memory.fromJson(json)).toList(),
          );
          debugPrint('Memories added: ${memoriesList.length}');
        }
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchMemories(
            newToken!,
            personId.value,
          );
          debugPrint('Retry fetchMemories response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'] as List<dynamic>;
            if (data.isEmpty) {
              hasMore(false);
              debugPrint('fetchMemories: No more memories available');
              memoriesListCount.value++;
            } else {
              memoriesList.addAll(
                data.map((json) => Memory.fromJson(json)).toList(),
              );
              debugPrint('Memories added: ${memoriesList.length}');
            }
          } else {
            hasMore(false);
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to load memories after token refresh';
            debugPrint('Retry fetchMemories Error: $errorMsg');
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
      debugPrint('deletePerson: No auth token available');
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
    final String refresh = authController.refreshToken.value;
    _setLoading(true);

    try {
      final response = await apiService.deletePerson(token, requestId);
      debugPrint('deletePerson response: $response');

      if (response['statusCode'] == 204) {
        personsList.removeWhere((person) => person.id == int.parse(requestId));
        showCustomSnackBar(
          title: 'Success',
          message: 'Friend request deleted successfully',
          isSuccess: true,
        );
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.deletePerson(
            newToken!,
            requestId,
          );
          debugPrint('Retry deletePerson response: $retryResponse');

          if (retryResponse['statusCode'] == 204) {
            personsList.removeWhere(
              (person) => person.id == int.parse(requestId),
            );
            showCustomSnackBar(
              title: 'Success',
              message: 'Friend request deleted successfully',
              backgroundColor: AppColor.lightGreenColor,
              isSuccess: true,
            );
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to delete friend request after token refresh';
            debugPrint('Retry deletePerson Error: $errorMsg');
            _setError(errorMsg);
            Get.offAllNamed('/login');
          }
        } else {
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        final errorMsg =
            response['data']['error'] ?? 'Failed to delete friend request';
        debugPrint('deletePerson Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('deletePerson Exception: $e\n$stackTrace');
      _setError('Failed to delete friend request: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPersons({bool isLoadMore = false}) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('fetchPersons: No auth token available');
      _setLoading(false);
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view persons',

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
          debugPrint('fetchPersons: No more persons available');
          personsListCount.value++;
        } else {
          personsList.addAll(
            data.map((json) => Person.fromJson(json)).toList(),
          );
          debugPrint('Persons added: ${personsList.length}');
        }
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchPersons(newToken!);
          debugPrint('Retry fetchPersons response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'] as List<dynamic>;
            if (data.isEmpty) {
              hasMore(false);
              debugPrint('fetchPersons: No more persons available');
              personsListCount.value++;
            } else {
              personsList.addAll(
                data.map((json) => Person.fromJson(json)).toList(),
              );
              debugPrint('Persons added: ${personsList.length}');
            }
          } else {
            hasMore(false);
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to load persons after token refresh';
            debugPrint('Retry fetchPersons Error: $errorMsg');
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
    final File? profilePhoto = pickedImage.value;
    final whoCanSee = selectedRole.value;
    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;

    debugPrint('Updating person with token: $token');
    debugPrint('Updating person with id: $id');
    debugPrint('Updating person with name: $name');
    debugPrint('Updating person with dateOfBirth: $dateOfBirth');
    debugPrint('Updating person with dateOfDeath: $dateOfDeath');
    debugPrint('Updating person with details: $details');

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
        final message = data['message'] ?? 'Person updated successfully';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        authController.isSignedIn.value = true;
        final String index = Get.arguments?['index'] as String? ?? '0';
        Get.to(
          () => MemoryDetailsView(),
          transition: Transition.rightToLeftWithFade,
          arguments: {'index': index.toString()},
        );
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.updatePerson(
            id,
            name,
            dateOfBirth,
            dateOfDeath,
            details,
            profilePhoto,
            whoCanSee,
            newToken!,
          );
          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'];
            final message = data['message'] ?? 'Person updated successfully';
            showCustomSnackBar(
              title: 'Success',
              message: message,
              backgroundColor: AppColor.lightGreenColor,
              isSuccess: true,
            );
            authController.isSignedIn.value = true;
            final String index = Get.arguments?['index'] as String? ?? '0';
            Get.to(
              () => MemoryDetailsView(),
              transition: Transition.rightToLeftWithFade,
              arguments: {'index': index.toString()},
            );
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to update person after token refresh';
            debugPrint('Retry updatePerson Error: $errorMsg');
            _setError(errorMsg);
            Get.offAllNamed('/login');
          }
        } else {
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        final data = response['data'];
        final errorMsg =
            data['messages'] is String
                ? data['messages']
                : data['detail'] ?? 'Unknown error occurred';
        debugPrint('updatePerson Error: $errorMsg');
        _setError('Failed to update person: $errorMsg');
      }
    } catch (e, stackTrace) {
      debugPrint('updatePerson Exception: $e\n$stackTrace');
      _setError('Failed to update person: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> postPerson() async {
    final name = nameController.text.trim();
    final dateOfBirth = dobController.text.trim();
    final dateOfDeath = dodController.text.trim();
    final details = detailsController.text.trim();
    final File? profilePhoto = pickedImage.value;
    final whoCanSee = selectedRole.value;
    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;

    debugPrint('Creating person with token: $token');

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
        final message = data['message'] ?? 'Person created successfully';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        authController.isSignedIn.value = true;
        Get.to(
          () => MemoryDetailsView(),
          transition: Transition.rightToLeftWithFade,
        );
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.createPerson(
            name,
            dateOfBirth,
            dateOfDeath,
            details,
            profilePhoto,
            whoCanSee,
            newToken!,
          );
          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'];
            final message = data['message'] ?? 'Person created successfully';
            showCustomSnackBar(
              title: 'Success',
              message: message,
              backgroundColor: AppColor.lightGreenColor,
              isSuccess: true,
            );
            authController.isSignedIn.value = true;
            Get.to(
              () => MemoryDetailsView(),
              transition: Transition.rightToLeftWithFade,
            );
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to create person after token refresh';
            debugPrint('Retry createPerson Error: $errorMsg');
            _setError(errorMsg);
            Get.offAllNamed('/login');
          }
        } else {
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        final data = response['data'];
        final errorMsg =
            data['messages'] is String
                ? data['messages']
                : data['detail'] ?? 'Unknown error occurred';
        debugPrint('createPerson Error: $errorMsg');
        _setError('Failed to create person: $errorMsg');
      }
    } catch (e, stackTrace) {
      debugPrint('createPerson Exception: $e\n$stackTrace');
      _setError('Failed to create person: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMemory() async {
    final id = memoryId.value.trim();
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final dateOfMemory = dateController.text.trim();
    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;

    debugPrint('Updating memory with token: $token');

    try {
      _setLoading(true);
      final response = await apiService.updateMemory(
        id,
        title,
        dateOfMemory,
        description,
        imagePaths.map((path) => File(path)).toList(),
        token,
      );
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        debugPrint('Memory updated successfully: $response');
        showCustomSnackBar(
          title: 'Success',
          message: 'Memory updated successfully!',
          isSuccess: true,
        );
        Get.off(() => Navigation(), transition: Transition.fadeIn);
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.updateMemory(
            id,
            title,
            dateOfMemory,
            description,
            imagePaths.map((path) => File(path)).toList(),
            newToken!,
          );
          if (retryResponse['statusCode'] == 200 ||
              retryResponse['statusCode'] == 201) {
            debugPrint('Memory updated successfully: $retryResponse');
            showCustomSnackBar(
              title: 'Success',
              message: 'Memory updated successfully!',
              backgroundColor: AppColor.lightGreenColor,
              isSuccess: true,
            );
            Get.off(() => Navigation(), transition: Transition.fadeIn);
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to update memory after token refresh';
            debugPrint('Retry updateMemory Error: $errorMsg');
            _setError(errorMsg);
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
        debugPrint('updateMemory Error: $errorMsg');
        _setError('Failed to update memory: $errorMsg');
      }
    } catch (e, stackTrace) {
      debugPrint('updateMemory Exception: $e\n$stackTrace');
      _setError('Failed to update memory: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> postMemory() async {
    final id = personId.value.trim();
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final dateOfMemory = dateController.text.trim();
    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;

    debugPrint('Creating memory with token: $token');

    try {
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
        Get.off(() => Navigation(), transition: Transition.fadeIn);
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.createMemory(
            id,
            title,
            dateOfMemory,
            description,
            imagePaths.map((path) => File(path)).toList(),
            newToken!,
          );
          if (retryResponse['statusCode'] == 201) {
            showCustomSnackBar(
              title: 'Success',
              message: 'Memory posted successfully!',
              backgroundColor: AppColor.lightGreenColor,
              isSuccess: true,
            );
            Get.off(() => Navigation(), transition: Transition.fadeIn);
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to post memory after token refresh';
            debugPrint('Retry createMemory Error: $errorMsg');
            _setError(errorMsg);
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
        debugPrint('createMemory Error: $errorMsg');
        _setError('Failed to post memory: $errorMsg');
      }
    } catch (e, stackTrace) {
      debugPrint('createMemory Exception: $e\n$stackTrace');
      _setError('Failed to post memory: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void onClose() {
    condolenceTextController.dispose();
    super.onClose();
  }
}
