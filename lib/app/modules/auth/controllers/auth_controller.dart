import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../res/colors/app_color.dart';
import '../../../../res/components/api_service.dart';
import '../../../../widgets/show_custom_snack_ber.dart';
import '../../../routes/app_pages.dart';
import '../../home/views/navbar.dart';
import '../../onboarding/views/webview_screen.dart';
import '../views/create_profile_view.dart';
import '../views/forget_verify_email_view.dart';
import '../views/update_password_view.dart';
import '../views/verify_email_view.dart';

class AuthController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _service = ApiService();

  // State variables
  final RxBool isOtpVerified = false.obs;
  final RxBool isStorageAvailable = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isCheckingToken = true.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isSignedIn = false.obs;
  final RxString isVerify = ''.obs;
  final RxString signupEmail = ''.obs;
  final RxString accessToken = ''.obs;
  final RxString refreshToken = ''.obs;
  final RxString isOtp = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    _startCountdown();
  }

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController setPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController forgetEmailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // In-memory storage fallback
  final Map<String, String> _inMemoryStorage = {};

  Future<void> _writeToStorage(String key, String value) async {
    if (isStorageAvailable.value) {
      try {
        await _storage.write(key: key, value: value);
        debugPrint('Wrote $key to secure storage: $value');
      } catch (e) {
        debugPrint('Storage write error: $e');
        isStorageAvailable.value = false;
        showCustomSnackBar(
          title: 'Warning',
          message: 'Secure storage unavailable, using in-memory storage',
          backgroundColor: AppColor.orangeColor,
          isSuccess: false,
        );
        _inMemoryStorage[key] = value;
      }
    } else {
      _inMemoryStorage[key] = value;
      debugPrint('Wrote $key to in-memory storage: $value');
    }
  }

  Future<String?> _readFromStorage(String key) async {
    if (isStorageAvailable.value) {
      try {
        final value = await _storage.read(key: key);
        debugPrint('Read $key from secure storage: $value');
        return value;
      } catch (e) {
        debugPrint('Storage read error: $e');
        isStorageAvailable.value = false;
        showCustomSnackBar(
          title: 'Warning',
          message:
              'Failed to read from secure storage, using in-memory storage',
          backgroundColor: AppColor.orangeColor,
          isSuccess: false,
        );
        return _inMemoryStorage[key];
      }
    } else {
      final value = _inMemoryStorage[key];
      debugPrint('Read $key from in-memory storage: $value');
      return value;
    }
  }

  Future<void> _deleteFromStorage(String key) async {
    if (isStorageAvailable.value) {
      try {
        await _storage.delete(key: key);
        debugPrint('Deleted $key from secure storage');
      } catch (e) {
        debugPrint('Storage delete error: $e');
        isStorageAvailable.value = false;
        showCustomSnackBar(
          title: 'Warning',
          message: 'Secure storage unavailable, using in-memory storage',
          backgroundColor: AppColor.orangeColor,
          isSuccess: false,
        );
        _inMemoryStorage.remove(key);
      }
    } else {
      _inMemoryStorage.remove(key);
      debugPrint('Deleted $key from in-memory storage');
    }
  }

  // Check login status
  Future<void> checkLoginStatus() async {
    try {
      isCheckingToken(true);
      final token = await _readFromStorage('access_token');
      final verifyToken = await _readFromStorage('verify');
      debugPrint('Token on app start: $token');
      if (token != null && token.isNotEmpty) {
        accessToken.value = token;
        if (verifyToken == 'yes') {
          isLoggedIn.value = true;
          isSignedIn.value = true;
        } else {
          isLoggedIn.value = false;
          isSignedIn.value = true;
        }
        debugPrint('Valid token found, user is logged in');
      } else {
        isLoggedIn.value = false;
        debugPrint('No valid token found');
      }
    } catch (e, stackTrace) {
      debugPrint('Check login error: $e\nStack trace: $stackTrace');
      isLoggedIn.value = false;
    } finally {
      isCheckingToken(false);
    }
  }

  Future<void> storeTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Rx<String?> selectedPlan = Rx<String?>(null);
  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  Map<String, String> get planIdMap => {
    'Basic': '1',
    'Premium': '2',
    'Gold': '3',
  };

  Future<void> createSubscription() async {
    final String token = accessToken.value;
    final successUrl = 'https://api.example.com/success';
    final cancelUrl = 'https://api.example.com/cancel';
    if (selectedPlan.value == null) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please select a plan',
        isSuccess: false,
      );
      return;
    }

    final planId = planIdMap[selectedPlan.value];

    if (planId == null) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Invalid plan selected',
        isSuccess: false,
      );
      return;
    }

    try {
      final response = await apiService.createSubscription(
        planId,
        token,
        successUrl, // Replace with your success URL
        cancelUrl,
      );
      final checkoutUrl = response['checkout_url'] as String?;
      if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
        Get.to(() => WebViewScreen(url: checkoutUrl));
      } else {
        showCustomSnackBar(
          title: 'Error',
          message: 'No checkout URL provided',
          isSuccess: false,
        );
        debugPrint('Error, No checkout URL provided');
      }
    } catch (e) {
      // Error already handled in ApiService
    }
  }

  Future<void> verify() async {
    await _writeToStorage('verify', 'yes');
  }

  Future<void> signUpWithOther(String email, String fcmToken) async {
    isLoading.value = true; // Show the loading screen
    try {
      final response = await _service.signUpWithOther(email, fcmToken);
      debugPrint(
        ':::::::::::::::RESPONSE:::::::::::::::::::::${response.body.toString()}',
      );
      debugPrint(
        ':::::::::::::::CODE:::::::::::::::::::::${response.statusCode}',
      );
      debugPrint(
        ':::::::::::::::REQUEST:::::::::::::::::::::${response.request}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Assuming the server responds with success on code 200 or 201
        final responseBody = jsonDecode(response.body);
        final accessToken = responseBody['access_token'];
        final refreshToken = responseBody['refresh_token'];
        // Store the tokens securely
        await storeTokens(accessToken, refreshToken);
        final verify = responseBody['verify'];
        final message = responseBody['message'];
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('No access token received');
        }
        await _writeToStorage('access_token', accessToken);
        await _writeToStorage('refresh_token', refreshToken ?? '');
        await _writeToStorage('verify', verify ?? '');
        this.accessToken.value = accessToken;
        this.refreshToken.value = refreshToken ?? '';
        isVerify.value = verify ?? '';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        isSignedIn.value = true;
        isVerify == 'yes'.obs
            ? Get.offAll(() => Navigation(), transition: Transition.fadeIn)
            : Get.offAll(
              () => CreateProfileView(),
              transition: Transition.fadeIn,
            );
        debugPrint(
          ':::::::::::::::responseBody:::::::::::::::::::::$responseBody',
        );
        debugPrint(
          ':::::::::::::::accessToken:::::::::::::::::::::$accessToken',
        );
        debugPrint(
          ':::::::::::::::refreshToken:::::::::::::::::::::$refreshToken',
        );

        //Get.off(() => VerifyOTPView());

        // homeController.fetchProfileData();

        // SharedPreferences

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      } else {
        showCustomSnackBar(
          title: 'Error',
          message:
              'Login failed: Sign-up failed\nPlease Use Different Username',
          backgroundColor: AppColor.redColor,
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Signup error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Signup failed: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    final email = signupEmailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    debugPrint('Signing up with email: $email');
    try {
      isLoading(true);
      final response = await apiService.signup(
        email,
        password,
        confirmPassword,
      );
      if (response['statusCode'] == 201) {
        final message = response['data']['message'] ?? 'OTP sent to your email';
        signupEmail.value = email;
        isSignedIn.value = true;
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        Get.to(
          () => VerifyEmailView(),
          transition: Transition.rightToLeftWithFade,
        );
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Signup failed';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Signup failed: $errorMsg',
          backgroundColor: AppColor.redColor,
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Signup error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Signup failed: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    debugPrint('Logging in with email: $email');
    try {
      isLoading(true);
      final response = await apiService.login(email, password);
      if (response['statusCode'] == 200) {
        final data = response['data'];
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        final verify = data['verify'] as String?;
        final message = data['message'] ?? 'Login successful';
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('No access token received');
        }
        await _writeToStorage('access_token', accessToken);
        await _writeToStorage('refresh_token', refreshToken ?? '');
        await _writeToStorage('verify', verify ?? '');
        this.accessToken.value = accessToken;
        this.refreshToken.value = refreshToken ?? '';
        isVerify.value = verify ?? 'no';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        isLoggedIn.value = true;
        isVerify == 'yes'.obs
            ? Get.offAll(() => Navigation(), transition: Transition.fadeIn)
            : Get.offAll(
              () => CreateProfileView(),
              transition: Transition.fadeIn,
            );
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Invalid credentials';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Login failed: $errorMsg',
          backgroundColor: AppColor.redColor,
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Login error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Login failed: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

  // Forget Password
  Future<void> forget() async {
    final email = forgetEmailController.text.trim();
    debugPrint('Forgot password for email: $email');
    try {
      isLoading(true);
      final response = await apiService.forget(email);
      if (response['statusCode'] == 200) {
        final message = response['data']['message'] ?? 'OTP sent to your email';
        signupEmail.value = email;
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        Get.to(
          () => ForgetVerifyEmailView(),
          transition: Transition.rightToLeftWithFade,
        );
      } else if (response['statusCode'] == 429) {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Request failed';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Request failed: $errorMsg',
          backgroundColor: AppColor.orangeColor,
          isSuccess: false,
        );
        // debugPrint('Request failed: $errorMsg 1');
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Request failed';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Request failed: $errorMsg',
          backgroundColor: AppColor.redColor,
          isSuccess: false,
        );
        // debugPrint('Request failed: $errorMsg 2');
      }
    } catch (e, stackTrace) {
      debugPrint('Forget password error: $e\nStack trace: $stackTrace');
      // debugPrint('Forget password error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Request failed: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

  // Update OTP status
  void updateOtp(String value) {
    isOtpVerified.value = value.isNotEmpty;
    isOtp.value = value;
    debugPrint('OTP updated, isOtpVerified: ${isOtpVerified.value}');
  }

  // Verify OTP
  Future<void> verifyOtp() async {
    final email = signupEmail.value;
    final otp = isOtp.value;
    debugPrint('Verifying OTP for email: $email, OTP: $otp');
    try {
      isLoading(true);
      final response = await apiService.verifyOtp(email, otp.toString());
      isSignedIn.value = true;
      if (response['statusCode'] == 200) {
        final data = response['data'];
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        final verify = data['verify'] as String?;
        final message = data['message'] ?? 'Login successful';
        debugPrint('message: ___________________ $message _____________________');
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('No access token received');
        }
        await _writeToStorage('access_token', accessToken);
        await _writeToStorage('refresh_token', refreshToken ?? '');
        await _writeToStorage('verify', verify ?? '');
        this.accessToken.value = accessToken;
        this.refreshToken.value = refreshToken ?? '';
        isVerify.value = verify ?? 'no';
        showCustomSnackBar(
          title: 'Success',
          message: 'Verified. Now set your password.',
          isSuccess: true,
        );
        isSignedIn.value = true;
        isLoggedIn.value = true;
        isVerify == 'yes'.obs
            ? Get.offAll(() => Navigation(), transition: Transition.fadeIn)
            : Get.offAll(
              () => CreateProfileView(),
          transition: Transition.fadeIn,
        );
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Invalid OTP';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'OTP verification failed: $errorMsg',
          backgroundColor: AppColor.redColor,
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('OTP verification error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'OTP verification failed: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

  // Verify OTP
  Future<void> verifyOtp1() async {
    final email = signupEmail.value;
    final otp = isOtp.value;
    debugPrint('Verifying OTP for email: $email, OTP: $otp');
    try {
      isLoading(true);
      final response = await apiService.verifyOtp1(email, otp.toString());
      if (response['statusCode'] == 200) {
        showCustomSnackBar(
          title: 'Success',
          message: 'Verified. Now set your password.',
          isSuccess: true,
        );
        Get.offAll(
          () => UpdatePasswordView(),
          transition: Transition.rightToLeftWithFade,
        );
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Invalid OTP';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'OTP verification failed: $errorMsg',
          backgroundColor: AppColor.redColor,
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('OTP verification error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'OTP verification failed: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    final email = signupEmail.value;
    debugPrint('Resending OTP for email: $email');
    try {
      isLoading(true);
      final response = await apiService.resendOtp(email);
      if (response['statusCode'] == 200) {
        final message =
            response['data']['message'] ?? 'OTP resent successfully';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
      } else if (response['statusCode'] == 429) {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Request failed';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Request failed: $errorMsg',
          backgroundColor: AppColor.orangeColor,
          isSuccess: false,
        );
        // debugPrint('Request failed: $errorMsg 1');
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Failed to resend OTP';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Failed to resend OTP: $errorMsg',
          backgroundColor: AppColor.redColor,
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Resend OTP error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to resend OTP: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> resendOtp1() async {
    final email = signupEmail.value;
    debugPrint('Resending OTP for email: $email');
    try {
      isLoading(true);
      final response = await apiService.resendOtp1(email);
      if (response['statusCode'] == 200) {
        final message =
            response['data']['message'] ?? 'OTP resent successfully';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
      } else if (response['statusCode'] == 429) {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Request failed';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Request failed: $errorMsg',
          backgroundColor: AppColor.orangeColor,
          isSuccess: false,
        );
        // debugPrint('Request failed: $errorMsg 1');
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Failed to resend OTP';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Failed to resend OTP: $errorMsg',
          backgroundColor: AppColor.redColor,
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Resend OTP error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to resend OTP: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

  // Set Password
  Future<void> setPassword() async {
    final email = signupEmail.value;
    final password = setPasswordController.text;
    final confirmPassword = confirmPasswordController.text;
    debugPrint('Setting password for email: $email');
    try {
      isLoading(true);
      final response = await apiService.setPassword(
        email,
        password,
        confirmPassword,
      );
      if (response['statusCode'] == 200) {
        final data = response['data'];
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        final verify = data['verify'] as String?;
        final message = data['message'] ?? 'Password set successfully';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('No access token received');
        }
        await _writeToStorage('access_token', accessToken);
        await _writeToStorage('refresh_token', refreshToken ?? '');
        await _writeToStorage('verify', verify ?? '');
        this.accessToken.value = accessToken;
        this.refreshToken.value = refreshToken ?? '';
        isVerify.value = verify ?? 'no';
        showCustomSnackBar(title: 'Success', message: message, isSuccess: true);
        isSignedIn.value = true;
        isLoggedIn.value = true;
        isVerify == 'yes'.obs
            ? Get.offAll(() => Navigation(), transition: Transition.fadeIn)
            : Get.offAll(
              () => CreateProfileView(),
          transition: Transition.fadeIn,
        );
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Failed to set password';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Failed to set password: $errorMsg',
          backgroundColor: AppColor.redColor,
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Set password error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to set password: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

  // Future<void> updateProfile() async {
  //   final username = userNameController.value;
  //     final name = nameController.value;
  //     final File? profilePhoto = pickedImage.value;
  //   if (profilePhoto != null) {
  //     try {
  //       var response = await _service.updateUserProfile(
  //         username,
  //         name,
  //         profilePhoto,
  //       );
  //       // Handle successful response
  //       if (response != null && response['message'] == "User updated successfully") {
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile")));
  //     }
  //   }
  // }

  // Logout
  Future<void> logout() async {
    debugPrint('Logging out');
    try {
      await _deleteFromStorage('access_token');
      await _deleteFromStorage('refresh_token');
      await _deleteFromStorage('verify');
      accessToken.value = '';
      refreshToken.value = '';
      isLoggedIn.value = false;
      showCustomSnackBar(
        title: 'Success',
        message: 'Logged out successfully',
        isSuccess: true,
      );
      Get.offAllNamed(Routes.auth);
    } catch (e, stackTrace) {
      debugPrint('Logout error: $e\nStack trace: $stackTrace');
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to logout: $e',
        backgroundColor: AppColor.redColor,
        isSuccess: false,
      );
    }
  }

  // Clear state
  void clear() {
    signupEmail.value = '';
    accessToken.value = '';
    refreshToken.value = '';
    isOtpVerified.value = false;
    errorMessage.value = '';
    isLoggedIn.value = false;
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    signupEmailController.clear();
    forgetEmailController.clear();
    otpController.clear();
    debugPrint('Cleared AuthController state');
  }

  // Old password validation
  final RxBool toggleNewPassword = false.obs;
  final RxBool toggleConfirmPassword = false.obs;
  final RxString newPassword = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxBool isRemembered = false.obs;

  Future<void> savePassword() async {
    // Implement password save logic (e.g., API call)
    // Example: Assume success for demonstration
    showCustomSnackBar(
      title: 'Success',
      message: 'Password saved successfully',
      isSuccess: true,
    );
  }

  var isremembered = false.obs;
  var ispasswordvisible = true.obs;

  RxInt secondsRemaining = 60.obs;
  RxString formattedTime = '01:00'.obs;

  Timer? _timer;

  void startTimer() {
    stopTimer(); // Cancel existing timer if running
    secondsRemaining.value = 60;
    _updateFormattedTime();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
        _updateFormattedTime();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateFormattedTime() {
    final int minutes = secondsRemaining.value ~/ 60;
    final int seconds = secondsRemaining.value % 60;
    formattedTime.value =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void stopTimer() {
    _timer?.cancel();
  }

  // Reactive OTP state
  var otp = ''.obs;
  // Reactive countdown timer (in seconds)
  var countdown = 54.obs;

  final count = 0.obs;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // Start countdown timer
  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
      }
    });
  }
}
