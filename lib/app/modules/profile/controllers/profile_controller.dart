import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../res/components/api_service.dart';
import '../../../../widgets/dialogue.dart';
import '../../../../widgets/show_custom_snack_bar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/views/link_social_view.dart';
import '../../explore/models/friend.dart';
import '../../explore/models/user_model.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/navbar.dart';
import '../models/user_profile.dart';

class ProfileController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();

  /// Loading + error
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Controllers (note: if already put elsewhere, prefer Get.find<>())
  final AuthController authController = Get.put(AuthController());
  final HomeController homeController = Get.put(HomeController());

  /// Session/user state
  var accessToken = ''.obs;
  var userName = ''.obs;
  var profilePhoto = ''.obs;
  var email = ''.obs;
  var about = ''.obs;
  var isVerified = false.obs;
  var friendsCount = 0.obs;
  var isFriend = false.obs;
  var name = ''.obs;
  var currentUser = ''.obs;
  var userId = ''.obs;

  /// Models
  var userProfile = Rxn<UserProfile>(); // my profile (model)
  var othersUserProfile =
      Rxn<Map<String, dynamic>>(); // other user's profile (normalized map)
  var otherUserPosts = <Map<String, dynamic>>[].obs;
  var otherUserPostsCount = 0.obs;

  /// Inputs
  Rxn<File> pickedImage = Rxn<File>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  /// Friends/Users
  var friendsList = <Friend>[].obs;
  var friendsListCount = 0.obs;
  var usersList = <UserModel>[].obs;

  /// UI State
  final RxString accountSelectedTab = 'Post'.obs;
  final RxString selectedTab = 'account'.obs;
  final count = 0.obs;
  RxBool isRequestSent = false.obs;
  RxString searchQuery = ''.obs;

  final List<String> names = [
    'Livia Workman',
    'Ethan Rivers',
    'Mila Greene',
    'Noah Carter',
    'Ava Brooks',
    'Lucas Hale',
    'Emma Stone',
    'Liam Woods',
    'Olivia West',
    'Mason Hayes',
    'Isla Knight',
    'Elijah Ford',
    'Chloe Ray',
    'Logan King',
    'Sofia Lane',
    'James Cole',
    'Amelia Blake',
  ];

  var isSwitched = false.obs;

  void _setLoading(bool v) {
    if (isLoading.value != v) isLoading.value = v;
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

  var hasMore = true.obs;
  var isMoreLoading = false.obs;
  var page = 1.obs;

  void setAccountSelectedTab(String tab) => accountSelectedTab.value = tab;
  void setSelectedTab(String tab) => selectedTab.value = tab;
  void toggleSwitch(bool value) => isSwitched.value = value;

  Future<void> acceptFriendRequest(String requestId) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('acceptFriendRequest: No auth token available');
      _setLoading(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to accept friend request',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;
    _setLoading(true);

    try {
      final response = await apiService.acceptFriendRequest(token, requestId);
      debugPrint('acceptFriendRequest response: $response');

      if (response['statusCode'] == 200 || response['statusCode'] == 204) {
        friendsList.removeWhere((friend) => friend.id.toString() == requestId);
        showCustomSnackBar(
          title: 'Success',
          message: 'Friend request accepted successfully',
          isSuccess: true,
        );
        await fetchFriends();
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.acceptFriendRequest(
            newToken!,
            requestId,
          );
          debugPrint('Retry acceptFriendRequest response: $retryResponse');

          if (retryResponse['statusCode'] == 200 ||
              retryResponse['statusCode'] == 204) {
            friendsList.removeWhere(
              (friend) => friend.id.toString() == requestId,
            );
            showCustomSnackBar(
              title: 'Success',
              message: 'Friend request accepted successfully',
              isSuccess: true,
            );
            await fetchFriends();
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to accept friend request after token refresh';
            debugPrint('Retry acceptFriendRequest Error: $errorMsg');
            _setError(errorMsg);
            Get.offAllNamed('/login');
          }
        } else {
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        final errorMsg =
            response['data']['error'] ?? 'Failed to accept friend request';
        debugPrint('acceptFriendRequest Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('acceptFriendRequest Exception: $e\n$stackTrace');
      _setError('Failed to accept friend request: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('rejectFriendRequest: No auth token available');
      _setLoading(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to reject friend request',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;
    _setLoading(true);

    try {
      final response = await apiService.rejectFriendRequest(token, requestId);
      debugPrint('rejectFriendRequest response: $response');

      if (response['statusCode'] == 200 || response['statusCode'] == 204) {
        friendsList.removeWhere((friend) => friend.id.toString() == requestId);
        showCustomSnackBar(
          title: 'Success',
          message: 'Friend request rejected successfully',
          isSuccess: true,
        );
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.rejectFriendRequest(
            newToken!,
            requestId,
          );
          debugPrint('Retry rejectFriendRequest response: $retryResponse');

          if (retryResponse['statusCode'] == 200 ||
              retryResponse['statusCode'] == 204) {
            friendsList.removeWhere(
              (friend) => friend.id.toString() == requestId,
            );
            showCustomSnackBar(
              title: 'Success',
              message: 'Friend request rejected successfully',
              isSuccess: true,
            );
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to reject friend request after token refresh';
            debugPrint('Retry rejectFriendRequest Error: $errorMsg');
            _setError(errorMsg);
            Get.offAllNamed('/login');
          }
        } else {
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        final errorMsg =
            response['data']['error'] ?? 'Failed to reject friend request';
        debugPrint('rejectFriendRequest Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('rejectFriendRequest Exception: $e\n$stackTrace');
      _setError('Failed to reject friend request: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteFriendRequest(String requestId) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('deleteFriendRequest: No auth token available');
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
      final response = await apiService.deleteFriendRequest(token, requestId);
      debugPrint('deleteFriendRequest response: $response');

      if (response['statusCode'] == 204) {
        friendsList.removeWhere((friend) => friend.id == int.parse(requestId));
        showCustomSnackBar(
          title: 'Success',
          message: 'Friend request deleted successfully',
          isSuccess: true,
        );
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.deleteFriendRequest(
            newToken!,
            requestId,
          );
          debugPrint('Retry deleteFriendRequest response: $retryResponse');

          if (retryResponse['statusCode'] == 204) {
            friendsList.removeWhere(
              (friend) => friend.id == int.parse(requestId),
            );
            showCustomSnackBar(
              title: 'Success',
              message: 'Friend request deleted successfully',
              isSuccess: true,
            );
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to delete friend request after token refresh';
            debugPrint('Retry deleteFriendRequest Error: $errorMsg');
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
        debugPrint('deleteFriendRequest Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('deleteFriendRequest Exception: $e\n$stackTrace');
      _setError('Failed to delete friend request: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendFriendRequest(String receiverId) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('sendFriendRequest: No auth token available');
      _setLoading(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to send friend request',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;
    _setLoading(true);

    try {
      final response = await apiService.sendFriendRequest(token, receiverId);
      debugPrint('sendFriendRequest response: $response');

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        showCustomSnackBar(
          title: 'Success',
          message: 'Friend request sent successfully',
          isSuccess: true,
        );
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.sendFriendRequest(
            newToken!,
            receiverId,
          );
          debugPrint('Retry sendFriendRequest response: $retryResponse');

          if (retryResponse['statusCode'] == 200 ||
              retryResponse['statusCode'] == 201) {
            showCustomSnackBar(
              title: 'Success',
              message: 'Friend request sent successfully',
              isSuccess: true,
            );
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to send friend request after token refresh';
            debugPrint('Retry sendFriendRequest Error: $errorMsg');
            _setError(errorMsg);
            Get.offAllNamed('/login');
          }
        } else {
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        final errorMsg =
            response['data']['error'] ?? 'Failed to send friend request';
        debugPrint('sendFriendRequest Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('sendFriendRequest Exception: $e\n$stackTrace');
      _setError('Failed to send friend request: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchFriends() async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('fetchFriends: No auth token available');
      _setLoading(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view friends',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;
    _setLoading(true);

    try {
      final response = await apiService.fetchFriends(token);
      debugPrint('fetchFriends response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data']['friends_and_requests'] as List<dynamic>;
        friendsList.value = data.map((json) => Friend.fromJson(json)).toList();
        friendsListCount.value++;
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchFriends(newToken!);
          debugPrint('Retry fetchFriends response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final data =
                retryResponse['data']['friends_and_requests'] as List<dynamic>;
            friendsList.value =
                data.map((json) => Friend.fromJson(json)).toList();
            friendsListCount.value++;
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to load friends after token refresh';
            debugPrint('Retry fetchFriends Error: $errorMsg');
            _setError(errorMsg);
            Get.offAllNamed('/login');
          }
        } else {
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        final errorMsg = response['data']['error'] ?? 'Failed to load friends';
        debugPrint('fetchFriends Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchFriends Exception: $e\n$stackTrace');
      _setError('Failed to load friends: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile() async {
    final String username = userNameController.value.text.trim();
    final String name = nameController.value.text.trim();
    final File profilePhoto = pickedImage.value!;
    final String token = authController.accessToken.value;
    final String refreshToken = authController.refreshToken.value;
    debugPrint('Updating profile with token: $token');

    try {
      _setLoading(true);

      // Try the first API call to update the profile
      final response = await apiService.updateUserProfile(
        username,
        name,
        profilePhoto,
        token,
      );

      if (response['statusCode'] == 200) {
        // Profile updated successfully
        final data = response['data'];
        final message = data['message'] ?? 'Profile updated successfully';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        authController.isSignedIn.value = true;

        // Navigate to the next screen
        Get.offAll(
          () => LinkSocialView(),
          transition: Transition.rightToLeftWithFade,
        );
      } else if (response['statusCode'] == 401) {
        // Token expired, attempt to refresh and retry the update
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          // Retry the profile update with the new token
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.updateUserProfile(
            username,
            name,
            profilePhoto,
            newToken,
          );

          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'];
            final message = data['message'] ?? 'Profile updated successfully';
            showCustomSnackBar(
              title: 'Success',
              message: message,
              isSuccess: true,
            );
            authController.isSignedIn.value = true;

            Get.offAll(
              () => LinkSocialView(),
              transition: Transition.rightToLeftWithFade,
            );
          } else {
            _setError('Failed to update profile after token refresh.');
          }
        } else {
          _setError('Failed to refresh token. Please log in again.');
        }
      } else {
        // Handle other error responses
        final data = response['data'];
        final errorMsg =
            data['messages'] ?? data['detail'] ?? 'Unknown error occurred';
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

  Future<void> updateProfile1() async {
    final String username = userName.value;
    final String name = nameController.text.trim();
    final File? profilePhoto = pickedImage.value;
    final String token = authController.accessToken.value;
    final String about = aboutController.text.trim();

    if (profilePhoto == null) {
      _setError('Please select a profile photo.');
      return;
    }
    if (username.isEmpty || name.isEmpty || about.isEmpty) {
      _setError('Please fill in all fields.');
      return;
    }

    try {
      _setLoading(true);
      final response = await apiService.updateUserProfile1(
        username,
        name,
        profilePhoto,
        token,
        about,
      );
      if (response['statusCode'] == 200) {
        final data = response['data'];
        final message = data['message'] ?? 'Password set successfully';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        authController.isSignedIn.value = true;
        authController.isLoggedIn.value = true;
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: CenteredDialogWidget(
              title: 'Profile Updated',
              horizontalPadding: 2.w,
              verticalPadding: 20.h,
              subtitle:
                  'Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus, ut dignissim',
              imageAsset: ImageAssets.postReport,
              backgroundColor: AppColor.backgroundColor,
              iconBackgroundColor: Colors.transparent,
              iconColor: AppColor.buttonColor,
              borderRadius: 30.r,
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

  Future<void> fetchUserProfile() async {
    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;
    debugPrint('Fetching profile with token: $token');

    try {
      _setLoading(true);
      final response = await apiService.getUserProfile(token);
      debugPrint('fetchUserProfile response: $response');

      if (response['statusCode'] == 200) {
        final up = UserProfile.fromJson(response['data'] ?? {});
        userProfile.value = up;

        userName.value = up.username;
        name.value = up.name;
        profilePhoto.value = up.profilePhoto ?? '';
        email.value = up.email;
        friendsCount.value = up.friendsCount;

        showCustomSnackBar(
          title: 'Success',
          message: 'Profile fetched successfully',
          isSuccess: true,
        );
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.getUserProfile(newToken!);
          debugPrint('Retry fetchUserProfile response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final up = UserProfile.fromJson(retryResponse['data'] ?? {});
            userProfile.value = up;

            userName.value = up.username;
            name.value = up.name;
            profilePhoto.value = up.profilePhoto ?? '';
            email.value = up.email;
            friendsCount.value = up.friendsCount;

            showCustomSnackBar(
              title: 'Success',
              message: 'Profile fetched successfully',
              isSuccess: true,
            );
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to fetch profile after token refresh';
            debugPrint('Retry fetchUserProfile Error: $errorMsg');
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
            'Failed to fetch profile';
        debugPrint('fetchUserProfile Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchUserProfile Exception: $e\n$stackTrace');
      _setError('Failed to fetch profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchOtherUserPost({bool isLoadMore = false}) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('fetchOtherUserPost: No auth token available');
      _setLoading(false);
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view posts',
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
      otherUserPosts.clear();
    }

    debugPrint(
      'Calling fetchOtherUserPost with token: $token, userId: ${userId.value}, page: ${page.value}',
    );

    try {
      final response = await apiService.fetchOtherUserPost(token, userId.value);
      debugPrint('fetchOtherUserPost response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        if (data.isEmpty) {
          hasMore(false);
          debugPrint('fetchOtherUserPost: No more posts available');
          otherUserPostsCount.value++;
        } else {
          otherUserPosts.addAll(data.cast<Map<String, dynamic>>());
          debugPrint('Posts added: ${otherUserPosts.length}');
        }
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchOtherUserPost(
            newToken!,
            userId.value,
          );
          debugPrint('Retry fetchOtherUserPost response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'] as List<dynamic>;
            if (data.isEmpty) {
              hasMore(false);
              debugPrint('fetchOtherUserPost: No more posts available');
              otherUserPostsCount.value++;
            } else {
              otherUserPosts.addAll(data.cast<Map<String, dynamic>>());
              debugPrint('Posts added: ${otherUserPosts.length}');
            }
          } else {
            hasMore(false);
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to load posts after token refresh';
            debugPrint('Retry fetchOtherUserPost Error: $errorMsg');
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
        final errorMsg = response['data']['error'] ?? 'Failed to load posts';
        debugPrint('fetchOtherUserPost Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchOtherUserPost Exception: $e\n$stackTrace');
      hasMore(false);
      _setError('Failed to load posts: $e');
    } finally {
      _setLoading(false);
      _setMoreLoading(false);
    }
  }

  Future<void> fetchUsers() async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('fetchUsers: No auth token available');
      _setLoading(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view users',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;
    _setLoading(true);

    try {
      final response = await apiService.fetchUsers(token);
      debugPrint('fetchUsers response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        usersList.value = data.map((json) => UserModel.fromJson(json)).toList();
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchUsers(newToken!);
          debugPrint('Retry fetchUsers response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'] as List<dynamic>;
            usersList.value =
                data.map((json) => UserModel.fromJson(json)).toList();
          } else {
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to load users after token refresh';
            debugPrint('Retry fetchUsers Error: $errorMsg');
            _setError(errorMsg);
            Get.offAllNamed('/login');
          }
        } else {
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        final errorMsg = response['data']['error'] ?? 'Failed to load users';
        debugPrint('fetchUsers Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchUsers Exception: $e\n$stackTrace');
      _setError('Failed to load users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleOthersLike(int postId, int index) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('toggleOthersLike: No auth token available');
      _setLoading(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to like posts',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final post = otherUserPosts[index];
    final isLiked = post['is_liked'] ?? false;
    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;

    // Optimistic update
    final updatedPost = Map<String, dynamic>.from(post);
    updatedPost['is_liked'] = !isLiked;
    updatedPost['react_count'] =
        isLiked
            ? (post['react_count'] ?? 0) - 1
            : (post['react_count'] ?? 0) + 1;
    otherUserPosts[index] = updatedPost;
    otherUserPosts.refresh();

    try {
      final response = await apiService.toggleLike(postId, isLiked, token);
      debugPrint('toggleOthersLike response: $response');

      if (response['statusCode'] == 200) {
        debugPrint('Like toggled successfully');
        if (response['data'] is Map<String, dynamic>) {
          final serverData = response['data'] as Map<String, dynamic>;
          final mergedPost = Map<String, dynamic>.from(otherUserPosts[index]);
          mergedPost['is_liked'] = serverData['is_liked'] ?? !isLiked;
          mergedPost['react_count'] =
              serverData['react_count'] ?? updatedPost['react_count'];
          otherUserPosts[index] = mergedPost;
          otherUserPosts.refresh();
        }
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.toggleLike(
            postId,
            isLiked,
            newToken!,
          );
          debugPrint('Retry toggleOthersLike response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            debugPrint('Like toggled successfully');
            if (retryResponse['data'] is Map<String, dynamic>) {
              final serverData = retryResponse['data'] as Map<String, dynamic>;
              final mergedPost = Map<String, dynamic>.from(
                otherUserPosts[index],
              );
              mergedPost['is_liked'] = serverData['is_liked'] ?? !isLiked;
              mergedPost['react_count'] =
                  serverData['react_count'] ?? updatedPost['react_count'];
              otherUserPosts[index] = mergedPost;
              otherUserPosts.refresh();
            }
          } else {
            otherUserPosts[index] = post;
            otherUserPosts.refresh();
            final errorMsg =
                retryResponse['data']['error'] ??
                'Failed to update like after token refresh';
            debugPrint('Retry toggleOthersLike Error: $errorMsg');
            _setError(errorMsg);
            Get.offAllNamed('/login');
          }
        } else {
          otherUserPosts[index] = post;
          otherUserPosts.refresh();
          _setError('Failed to refresh token. Please log in again.');
          Get.offAllNamed('/login');
        }
      } else {
        otherUserPosts[index] = post;
        otherUserPosts.refresh();
        final errorMsg = response['data']['error'] ?? 'Failed to update like';
        debugPrint('toggleOthersLike Error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('toggleOthersLike Exception: $e\n$stackTrace');
      otherUserPosts[index] = post;
      otherUserPosts.refresh();
      _setError('Failed to update like: $e');
    } finally {
      _setLoading(false);
    }
  }
}
