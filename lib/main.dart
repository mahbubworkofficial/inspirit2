import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/modules/chat/controllers/chat_controller.dart';
import 'app/modules/explore/controller/explore_controller.dart';
import 'app/modules/explore/controller/post_controller.dart';
import 'app/modules/memory/controllers/memory_controller.dart';
import 'app/modules/onboarding/controllers/onboarding_controller.dart';
import 'app/modules/profile/controllers/family_tree_controller.dart';
import 'app/modules/profile/controllers/profile_controller.dart';
import 'app/routes/app_pages.dart';
import 'res/colors/app_color.dart';
import 'res/components/api_service.dart';
import 'res/components/notification_service.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await Firebase.initializeApp();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register dependencies
  Get.put(ApiService());
  Get.put(AuthController());
  Get.put(OnboardingController());
  Get.put(ChatController());
  Get.put(ProfileController());
  Get.put(PostController());
  Get.put(ExploreController());
  Get.put(MemoryController());
  Get.put(FamilyTreeController());
  runApp(
    ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Jordyn",
            initialRoute: AppPages.initial,
            getPages: AppPages.routes,
            theme: ThemeData(
              scaffoldBackgroundColor: AppColor.backgroundColor,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: AppColor.backgroundColor,
                scrolledUnderElevation: 0,
              ),
            ),
          ),
        );
      },
    ),
  );
}
