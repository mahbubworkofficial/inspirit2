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
      backgroundColor: AppColor.redColor,
      isSuccess: false,
    );
  }

  Future<void> acceptFriendRequest(String requestId) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
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
    _setLoading(true);

    try {
      final response = await apiService.acceptFriendRequest(token, requestId);
      debugPrint('acceptFriendRequest response: $response');

      if (response['statusCode'] == 200 || response['statusCode'] == 204) {
        // Optionally update friendsList to reflect accepted status
        friendsList.removeWhere((friend) => friend.id.toString() == requestId);
        showCustomSnackBar(
          title: 'Success',
          message: 'Friend request accepted successfully',
          isSuccess: true,
        );
        // Optionally refresh friends list
        await fetchFriends();
      } else {
        final errorMsg =
            response['data']['error'] ?? 'Failed to accept friend request';
        _setError(errorMsg);
      }
    } catch (e, st) {
      debugPrint('acceptFriendRequest Exception: $e\n$st');
      _setError('Failed to accept friend request: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
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
      } else {
        final errorMsg =
            response['data']['error'] ?? 'Failed to reject friend request';
        _setError(errorMsg);
      }
    } catch (e, st) {
      debugPrint('rejectFriendRequest Exception: $e\n$st');
      _setError('Failed to reject friend request: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteFriendRequest(String requestId) async {
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
      final response = await apiService.deleteFriendRequest(token, requestId);
      debugPrint('deleteFriendRequest response: $response');

      if (response['statusCode'] == 204) {
        // Optionally update friendsList by removing the deleted request
        friendsList.removeWhere((friend) => friend.id == int.parse(requestId));
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

  Future<void> sendFriendRequest(String receiverId) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
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
    _setLoading(true);

    try {
      final response = await apiService.sendFriendRequest(token, receiverId);
      debugPrint('sendFriendRequest response: $response');

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        // Optionally update friendsList or other state if needed
        showCustomSnackBar(
          title: 'Success',
          message: 'Friend request sent successfully',
          isSuccess: true,
        );
      } else {
        final errorMsg =
            response['data']['error'] ?? 'Failed to send friend request';
        _setError(errorMsg);
      }
    } catch (e, st) {
      debugPrint('sendFriendRequest Exception: $e\n$st');
      _setError('Failed to send friend request: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchFriends() async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
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
    _setLoading(true);

    try {
      final response = await apiService.fetchFriends(token);
      debugPrint('fetchFriends response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data']['friends_and_requests'] as List<dynamic>;
        friendsList.value = data.map((json) => Friend.fromJson(json)).toList();
        friendsListCount.value++;
      } else {
        final errorMsg = response['data']['error'] ?? 'Failed to load friends';
        _setError(errorMsg);
      }
    } catch (e, st) {
      debugPrint('fetchFriends Exception: $e\n$st');
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
    debugPrint('Updating profile with token: $token');

    try {
      _setLoading(true);
      final response = await apiService.updateUserProfile(
        username,
        name,
        profilePhoto,
        token,
      );
      if (response['statusCode'] == 200) {
        final data = response['data'];
        final message = data['message'] ?? 'Password set successfully';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        authController.isSignedIn.value = true;
        Get.offAll(
          () => LinkSocialView(),
          transition: Transition.rightToLeftWithFade,
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

  var hasMore = true.obs;
  var isMoreLoading = false.obs;
  var page = 1.obs;

  Future<void> fetchUserProfile() async {
    final String token = authController.accessToken.value;
    try {
      _setLoading(true);
      final response = await apiService.getUserProfile(token);
      debugPrint('API response: $response');

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
      } else {
        String errorMsg = 'Failed to fetch profile';
        if (response['statusCode'] == 401) {
          final data = response['data'] ?? {};
          if (data['messages'] is List &&
              (data['messages'] as List).isNotEmpty) {
            errorMsg =
                (data['messages'] as List)[0]['message'] ??
                'Token is expired or invalid';
          } else {
            errorMsg = data['detail'] ?? 'Authentication failed';
          }
        } else {
          errorMsg = response['data']?['detail'] ?? 'Unknown error occurred';
        }
        errorMessage.value = errorMsg;
        _setError('Failed to fetch profile: $errorMsg');
      }
    } catch (e, st) {
      debugPrint('Fetch profile error: $e\n$st');
      errorMessage.value = 'Error: $e';
      _setError('Failed to fetch profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchOtherUserPost({bool isLoadMore = false}) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
      isLoading(false);
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

    if (isLoadMore) {
      if (!hasMore.value || isMoreLoading.value) return;
      isMoreLoading(true);
      page.value += 1;
    } else {
      isLoading(true);
      page.value = 1;
      otherUserPosts.clear();
    }

    debugPrint(
      'Calling fetchOthersPost with token: $token, page: ${page.value}',
    );
    try {
      final response = await apiService.fetchOtherUserPost(token, userId.value);
      debugPrint('fetchOthersPost response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        if (data.isEmpty) {
          hasMore(false);
          debugPrint('No more posts available');
          otherUserPostsCount.value++;
        } else {
          otherUserPosts.addAll(data.cast<Map<String, dynamic>>());
          // otherUserPosts.refresh();
          debugPrint('Posts added: ${otherUserPosts.length}');
        }
      } else {
        hasMore(false);
        final errorMsg = response['data']['error'] ?? 'Failed to load posts';
        debugPrint('fetchOtherUserPost Error: $errorMsg');
        showCustomSnackBar(title: 'Error', message: errorMsg, isSuccess: false);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchOtherUserPost Exception: $e\n$stackTrace');
      isLoading(false);
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to load posts: $e',
        isSuccess: false,
      );
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }

  Future<void> fetchUsers() async {
    final String token = authController.accessToken.value;

    if (token.isEmpty) {
      debugPrint('No auth token available');
      _setLoading(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view users',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    _setLoading(true);

    try {
      final response = await apiService.fetchUsers(token);
      debugPrint('fetchUsers response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        usersList.value = data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        final errorMsg = response['data']['error'] ?? 'Failed to load users';
        _setError(errorMsg);
      }
    } catch (e, st) {
      debugPrint('fetchUsers Exception: $e\n$st');
      _setError('Failed to load users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleOthersLike(int postId, int index) async {
    final post = otherUserPosts[index];
    final isLiked = post['is_liked'];
    final token = authController.accessToken.value;

    isLoading(true);

    try {
      final response = await apiService.toggleLike(postId, isLiked, token);

      if (response['statusCode'] == 200) {
        // Successfully toggled the like state
        debugPrint('Like toggled successfully');
        post['is_liked'] = !isLiked;
        post['react_count'] =
            isLiked ? post['react_count'] - 1 : post['react_count'] + 1;
        otherUserPosts[index] = Map.from(post); // Update the post in the list
        otherUserPosts.refresh(); // Refresh the UI
      } else {
        // Handle error from API
        Get.snackbar('Error', response['data']['error']);
      }
    } catch (e) {
      // Handle unexpected errors
      Get.snackbar('Error', 'Failed to update like: $e');
    } finally {
      isLoading(false); // Stop loading
    }
  }

  void setAccountSelectedTab(String tab) => accountSelectedTab.value = tab;
  void setSelectedTab(String tab) => selectedTab.value = tab;
  void toggleSwitch(bool value) => isSwitched.value = value;





  void increment() => count.value++;
}
