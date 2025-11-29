import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../res/components/notification_service.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/auth_controller.dart';
import 'sign_in_view.dart';

class AuthView extends GetView<AuthController> {
  AuthView({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Use singleton
  final AuthController _controller = Get.put(AuthController());
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10.h),
                  Center(child: Image.asset(ImageAssets.authLogo)),
                  SizedBox(height: 10.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Account',
                        style: TextStyle(
                          color: AppColor.buttonColor,
                          fontSize: 24.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  InputTextWidget(
                    onChanged: (e) {},
                    borderColor: AppColor.backgroundColor,
                    hintText: 'Enter your email',
                    textEditingController: controller.signupEmailController,
                    leadingIcon: ImageAssets.email,
                    textColor: AppColor.textGreyColor2,
                    leading: true,
                  ),
                  SizedBox(height: 15.h),
                  InputTextWidget(
                    onChanged: (e) {},
                    borderColor: AppColor.backgroundColor,
                    hintText: 'Create your password',
                    leadingIcon: ImageAssets.pass,
                    textEditingController: controller.passwordController,
                    leading: true,
                    obscureText: true,
                    textColor: AppColor.textGreyColor2,
                  ),
                  SizedBox(height: 15.h),
                  InputTextWidget(
                    onChanged: (e) {},
                    borderColor: AppColor.backgroundColor,
                    hintText: 'Confirm your password',
                    leadingIcon: ImageAssets.pass,
                    textEditingController: controller.confirmPasswordController,
                    leading: true,
                    obscureText: true,
                    textColor: AppColor.textGreyColor2,
                  ),
                  SizedBox(height: 20.h),
                  Obx(
                    () => CustomButton(
                      onPress:
                          controller.isLoading.value
                              ? null // Disable button when loading
                              : () async {
                                await controller.signup();
                              },
                      loading: controller.isLoading.value,
                      title: 'SIGN UP',
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: AppColor.textGreyColor3,
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(
                            SignInView(),
                            transition: Transition.rightToLeftWithFade,
                          );
                        },
                        child: Text(
                          ' Sign In',
                          style: TextStyle(
                            color: AppColor.buttonColor,
                            fontSize: 16.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'or',
                    style: TextStyle(
                      color: AppColor.greyTone1,
                      fontSize: 20,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Continue with',
                    style: TextStyle(
                      color: AppColor.greyTone1,
                      fontSize: 16.sp,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 25),
                  Wrap(
                    spacing: 20.w,
                    alignment: WrapAlignment.center,
                    children: [
                      InkWell(
                        onTap: _signInWithGoogle,
                        child: SvgPicture.asset(
                          ImageAssets.google,
                          height: 42.h,
                          width: 78.w,
                        ),
                      ),
                      SvgPicture.asset(
                        ImageAssets.facebook,
                        height: 42.h,
                        width: 78.w,
                      ),
                      SvgPicture.asset(
                        ImageAssets.apple,
                        height: 42.h,
                        width: 78.w,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _signInWithGoogle() async {
    try {
      String fcmToken = await _notificationService.getDeviceToken();
      debugPrint('FCM Token: $fcmToken');
      controller.isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        debugPrint(':::::::::::USER EMAIL::::::::::::::::::::::::::::${user.email}');
        debugPrint(':::::::::::USER NAME::::::::::::::::::::::::::::${user.displayName}');
        debugPrint(':::::::::::USER ID::::::::::::::::::::::::::::${user.uid}');

        await _controller.signUpWithOther(user.email!, fcmToken);
      }
    } catch (e) {
      debugPrint("Error signing in: $e");
    } finally {
      _controller.isLoading.value = false; // Hide the loading screen
    }
  }
}

