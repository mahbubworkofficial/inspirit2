import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../res/components/api_service.dart';
import '../../../../widgets/show_custom_snack_bar.dart';
import '../../../routes/app_pages.dart';
import '../../chat/controllers/bottom_sheet_controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../explore/controller/explore_controller.dart';
import '../../explore/controller/post_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/navbar.dart';
import '../../memory/controllers/memory_controller.dart';
import '../../onboarding/views/webview_screen.dart';
import '../../profile/controllers/family_tree_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../views/create_profile_view.dart';
import '../views/forget_verify_email_view.dart';
import '../views/update_password_view.dart';
import '../views/verify_email_view.dart';
import 'authcameracontroller.dart';

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
  final Map<String, String> _inMemoryStorage = {};
  RxInt secondsRemaining = 60.obs;
  RxString formattedTime = '01:00'.obs;
  var countdown = 54.obs;
  Timer? _timer;
  Map<String, String> get planIdMap => {
    'Basic': '1',
    'Premium': '2',
    'Gold': '3',
  };

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController setPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController forgetEmailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    _startCountdown();
  }

  Rx<String?> selectedPlan = Rx<String?>(null);
  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  void updateOtp(String value) {
    isOtpVerified.value = value.isNotEmpty;
    isOtp.value = value;
    debugPrint('OTP updated, isOtpVerified: ${isOtpVerified.value}');
  }

  void startTimer() {
    stopTimer();
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
          isSuccess: false,
        );
        _inMemoryStorage.remove(key);
      }
    } else {
      _inMemoryStorage.remove(key);
      debugPrint('Deleted $key from in-memory storage');
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      isCheckingToken(true);
      final token = await _readFromStorage('access_token');
      final refreshToken = await _readFromStorage('refresh_token');
      final verifyToken = await _readFromStorage('verify');
      debugPrint('Token on app start: $token');

      if (token != null && token.isNotEmpty) {
        accessToken.value = token;

        if (verifyToken == 'yes') {
          isLoggedIn.value = true;
          isSignedIn.value = true;
          debugPrint('Valid token found, user is logged in');
        } else {
          isLoggedIn.value = false;
          isSignedIn.value = true;
          debugPrint('Token found, but verification failed');
        }
      } else if (refreshToken != null && refreshToken.isNotEmpty) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          final newToken = await _readFromStorage('access_token');
          accessToken.value = newToken!;
          isLoggedIn.value = true;
          isSignedIn.value = true;
          debugPrint('Token was refreshed and user is now logged in');
        } else {
          isLoggedIn.value = false;
          debugPrint('Failed to refresh token');
        }
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

  Future<bool> refreshAccessToken() async {
    final refresh = await _readFromStorage('refresh_token');
    try {
      final response = await apiService.refreshToken(refresh!);
      if (response['statusCode'] == 200) {
        debugPrint('response __________________ $response');
        final newAccessToken = response['data']['access'];
        final newRefreshToken = response['data']['refresh'];
        await _writeToStorage('access_token', newAccessToken);
        await _writeToStorage('refresh_token', newRefreshToken);
        accessToken.value = newAccessToken;
        refreshToken.value = newRefreshToken;
        debugPrint('New access token: $newAccessToken');
        debugPrint('New refresh token: $newRefreshToken');
        debugPrint('Token refreshed successfully');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }

  Future<void> storeTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _readFromStorage('access_token');
  }

  Future<void> createSubscription() async {
    final String token = accessToken.value;
    final String refresh = refreshToken.value;
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
      isLoading(true);
      final response = await apiService.createSubscription(
        planId,
        token,
        successUrl,
        cancelUrl,
      );

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final checkoutUrl = response['data']['checkout_url'] as String?;
        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          Get.to(() => WebViewScreen(url: checkoutUrl));
        } else {
          showCustomSnackBar(
            title: 'Error',
            message: 'No checkout URL provided',
            isSuccess: false,
          );
          debugPrint('Error: No checkout URL provided');
        }
      } else if (response['statusCode'] == 401) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          final newToken = await getAccessToken();
          final retryResponse = await apiService.createSubscription(
            planId,
            newToken!,
            successUrl,
            cancelUrl,
          );

          if (retryResponse['statusCode'] == 200 || retryResponse['statusCode'] == 201) {
            final checkoutUrl = retryResponse['data']['checkout_url'] as String?;
            if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
              Get.to(() => WebViewScreen(url: checkoutUrl));
            } else {
              showCustomSnackBar(
                title: 'Error',
                message: 'No checkout URL provided after token refresh',
                isSuccess: false,
              );
              debugPrint('Error: No checkout URL provided after token refresh');
            }
          } else {
            final errorMsg = retryResponse['data']['error'] ?? 'Failed to create subscription after token refresh';
            debugPrint('Retry createSubscription Error: $errorMsg');
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
        final errorMsg = response['data']['error'] ?? 'Failed to create subscription';
        debugPrint('createSubscription Error: $errorMsg');
        showCustomSnackBar(
          title: 'Error',
          message: errorMsg,
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('createSubscription Exception: $e\n$stackTrace');
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to create subscription: $e',
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> verify() async {
    await _writeToStorage('verify', 'yes');
  }

  Future<void> signUpWithOther(String email, String fcmToken) async {
    isLoading.value = true;
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
        final responseBody = jsonDecode(response.body);
        final accessToken = responseBody['access_token'];
        final refreshToken = responseBody['refresh_token'];
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

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      } else {
        showCustomSnackBar(
          title: 'Error',
          message:
              'Login failed: Sign-up failed\nPlease Use Different Username',
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Signup error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Signup failed: $e',
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
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Signup error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Signup failed: $e',
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
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Login error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Login failed: $e',
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

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
          isSuccess: false,
        );
        debugPrint('Request failed: $errorMsg 1');
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Request failed';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Request failed: $errorMsg',
          isSuccess: false,
        );
        debugPrint('Request failed: $errorMsg 2');
      }
    } catch (e, stackTrace) {
      debugPrint('Forget password error: $e\nStack trace: $stackTrace');
      debugPrint('Forget password error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Request failed: $e',
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

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
        debugPrint(
          'message: ___________________ $message _____________________',
        );
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('No access token received');
        }
        await _writeToStorage('access_token', accessToken);
        await _writeToStorage('refresh_token', refreshToken ?? '');
        await _writeToStorage('verify', verify ?? '');
        _readFromStorage('access_token');
        _readFromStorage('refresh_token');
        _readFromStorage('verify');
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
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('OTP verification error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'OTP verification failed: $e',
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

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
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('OTP verification error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'OTP verification failed: $e',
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

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
          isSuccess: false,
        );
        debugPrint('Request failed: $errorMsg 1');
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Failed to resend OTP';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Failed to resend OTP: $errorMsg',
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Resend OTP error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to resend OTP: $e',
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
          isSuccess: false,
        );
        debugPrint('Request failed: $errorMsg 1');
      } else {
        final errorMsg =
            response['data']['error'] ??
            response['data']['message'] ??
            'Failed to resend OTP';
        errorMessage.value = errorMsg;
        showCustomSnackBar(
          title: 'Error',
          message: 'Failed to resend OTP: $errorMsg',
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Resend OTP error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to resend OTP: $e',
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

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
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Set password error: $e\nStack trace: $stackTrace');
      errorMessage.value = 'Error: $e';
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to set password: $e',
        isSuccess: false,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    debugPrint('Logging out');
    try {
      // Clear secure storage
      await _deleteFromStorage('access_token');
      await _deleteFromStorage('refresh_token');
      await _deleteFromStorage('verify');

      // Reset AuthController state
      clear();

      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        profileController.accessToken.value = '';
        profileController.userName.value = '';
        profileController.profilePhoto.value = '';
        profileController.email.value = '';
        profileController.about.value = '';
        profileController.isVerified.value = false;
        profileController.friendsCount.value = 0;
        profileController.isFriend.value = false;
        profileController.name.value = '';
        profileController.currentUser.value = '';
        profileController.userId.value = '';
        profileController.userProfile.value = null;
        profileController.othersUserProfile.value = null;
        profileController.otherUserPosts.clear();
        profileController.otherUserPostsCount.value = 0;
        profileController.pickedImage.value = null;
        profileController.nameController.clear();
        profileController.userNameController.clear();
        profileController.aboutController.clear();
        profileController.friendsList.clear();
        profileController.friendsListCount.value = 0;
        profileController.usersList.clear();
        profileController.accountSelectedTab.value = 'Post';
        profileController.selectedTab.value = 'account';
        profileController.count.value = 0;
        profileController.isRequestSent.value = false;
        profileController.searchQuery.value = '';
        profileController.isSwitched.value = false;
        profileController.hasMore.value = true;
        profileController.isMoreLoading.value = false;
        profileController.page.value = 1;
      }

      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        profileController.accessToken.value = '';
        profileController.userName.value = '';
        profileController.profilePhoto.value = '';
        profileController.email.value = '';
        profileController.about.value = '';
        profileController.isVerified.value = false;
        profileController.friendsCount.value = 0;
        profileController.isFriend.value = false;
        profileController.name.value = '';
        profileController.currentUser.value = '';
        profileController.userId.value = '';
        profileController.userProfile.value = null;
        profileController.othersUserProfile.value = null;
        profileController.otherUserPosts.clear();
        profileController.otherUserPostsCount.value = 0;
        profileController.pickedImage.value = null;
        profileController.nameController.clear();
        profileController.userNameController.clear();
        profileController.aboutController.clear();
        profileController.friendsList.clear();
        profileController.friendsListCount.value = 0;
        profileController.usersList.clear();
        profileController.accountSelectedTab.value = 'Post';
        profileController.selectedTab.value = 'account';
        profileController.count.value = 0;
        profileController.isRequestSent.value = false;
        profileController.searchQuery.value = '';
        profileController.isSwitched.value = false;
        profileController.hasMore.value = true;
        profileController.isMoreLoading.value = false;
        profileController.page.value = 1;
      }

      if (Get.isRegistered<MemoryController>()) {
        final memoryController = Get.find<MemoryController>();
        memoryController.selectedIndex.value = -1;
        memoryController.selectedEventType.value = '';
        memoryController.selectedRole.value = '';
        memoryController.personId.value = '';
        memoryController.memoryId.value = '';
        memoryController.personsList.clear();
        memoryController.hasMore.value = true;
        memoryController.personsListCount.value = 0;
        memoryController.page.value = 1;
        memoryController.memoriesList.clear();
        memoryController.memoriesListCount.value = 0;
        memoryController.isLoading.value = false;
        memoryController.isMoreLoading.value = false;
        memoryController.errorMessage.value = '';
        memoryController.searchQuery.value = '';
        memoryController.titleController.clear();
        memoryController.descriptionController.clear();
        memoryController.dateController.clear();
        memoryController.nameController.clear();
        memoryController.dobController.clear();
        memoryController.dodController.clear();
        memoryController.detailsController.clear();
        memoryController.whoCanSee.value = '';
        memoryController.pickedImage.value = null;
        memoryController.imagePaths.clear();
        memoryController.selectedTab.value = 'Memorial';
        memoryController.historySelectedTab.value = 'Memorial';
        memoryController.count.value = 0;
        memoryController.isFabVisible.value = true;
        memoryController.isMemorialSelected.value = false;
        memoryController.condolenceTextController.clear();
        memoryController.isSendingCondolence.value = false;
        memoryController.hasText.value = false;
        memoryController.condolencesCount.value = 0;
        memoryController.condolences.clear();
        memoryController.isFetching.value = false;
      }

      if (Get.isRegistered<ChatController>()) {
        final chatController = Get.find<ChatController>();
        chatController.cleanupChat();
        chatController.messages.clear();
        chatController.message.value = '';
        chatController.isTyping.value = false;
        chatController.textController.clear();
        chatController.isMessageLoading.value = false;
        chatController.isRoomLoading.value = false;
        chatController.isRoomsLoading.value = false;
        chatController.chatError.value = '';
        chatController.roomsError.value = '';
        chatController.roomId.value = null;
        chatController.rooms.clear();
        chatController.isFileUploading.value = false;
        chatController.currentRoomId = null;
        chatController.isrequestsent.value = false;
        chatController.searchQuery.value = '';
        chatController.isuserblocked.value = false;
        chatController.istapped.value = false;
        chatController.pickedImage.value = null;
        chatController.selectedUsers.clear();
        chatController.selectedGroupType.value = 'Public';
      }

      if (Get.isRegistered<FamilyTreeController>()) {
        final familyTreeController = Get.find<FamilyTreeController>();
        familyTreeController.familyMembers.clear();
      }

      if (Get.isRegistered<ExploreController>()) {
        final exploreController = Get.find<ExploreController>();
        exploreController.selectedIndex.value = -1;
        exploreController.selectedEventType.value = '';
        exploreController.isEventSelected.value = false;
        exploreController.searchQuery.value = '';
        exploreController.isLoading.value = false;
        exploreController.isMoreLoading.value = false;
        exploreController.hasMore.value = true;
        exploreController.errorMessage.value = '';
        exploreController.eventId.value = '';
        exploreController.eventType.value = '';
        exploreController.eventsList.clear();
        exploreController.otherUserEvents.clear();
        exploreController.eventsListCount.value = 0;
        exploreController.otherUserEventsCount.value = 0;
        exploreController.page.value = 1;
        exploreController.userId.value = '';
        exploreController.hasText.value = false;
        exploreController.titleController.clear();
        exploreController.dateController.clear();
        exploreController.timeController.clear();
        exploreController.locationController.clear();
        exploreController.descriptionController.clear();
        exploreController.imagePaths.clear();
        exploreController.selectedTab.value = 'User';
        exploreController.mapController.value?.dispose();
        exploreController.mapController.value = null;
      }

      if (Get.isRegistered<PostController>()) {
        final postController = Get.find<PostController>();
        postController.posts.clear();
        postController.postsCount.value = 0;
        postController.othersPost.clear();
        postController.othersPostCount.value = 0;
        postController.isLoading.value = true;
        postController.page.value = 1;
        postController.hasMore.value = true;
        postController.isMoreCommentsLoading.value = false;
        postController.commentsPage.value = 1;
        postController.hasText.value = false;
        postController.commentTextController.clear();
        postController.isCommentsLoading.value = false;
        postController.commentsCount.value = 0;
        postController.hasMoreComments.value = false;
        postController.comments.clear();
        postController.editingComment.clear();
        postController.isMoreLoading.value = false;
        postController.currentCommentsPostId.value = '';
        postController.isSendingComment.value = false;
        postController.likingComment.clear();
        postController.deletingComment.clear();
      }

      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.isLoading.value = false;
        homeController.pickedImage.value = null;
        homeController.isMemorialSelected.value = false;
        homeController.content.value = '';
        homeController.scheduledDate.value = null;
        homeController.scheduledTime.value = null;
        homeController.contentController.clear();
        homeController.currentIndex.value = 0;
        homeController.isFabMenuOpen.value = false;
        homeController.isselected.value = false;
        homeController.selectedreportype.value = "";
        homeController.showAll.value = true;
        homeController.pickedImageschedule.value = null;
      }

      if (Get.isRegistered<AuthBottomSheetController>()) {
        final authBottomSheetController = Get.find<AuthBottomSheetController>();
        authBottomSheetController.pickedImage.value = null;
      }

      if (Get.isRegistered<BottomSheetController>()) {
        final bottomSheetController = Get.find<BottomSheetController>();
        bottomSheetController.pickedImage.value = null;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

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
        isSuccess: false,
      );
    }
  }

  void clear() {
    signupEmail.value = '';
    accessToken.value = '';
    refreshToken.value = '';
    isOtpVerified.value = false;
    errorMessage.value = '';
    isLoggedIn.value = false;
    isSignedIn.value = false;
    isVerify.value = '';
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    signupEmailController.clear();
    forgetEmailController.clear();
    otpController.clear();
    selectedPlan.value = null;
    debugPrint('Cleared AuthController state');
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
