import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/navbar.dart';
import '../modules/notification_subscription/bindings/notification_subscription_binding.dart';
import '../modules/notification_subscription/views/notification_subscription_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/splash_view.dart';


part 'app_routes.dart';

class AppPages {
  AppPages._();
  static const initial = Routes.splash;
  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => Navigation(),
      transition: Transition.rightToLeft,
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.splash,
      page: () => SplashView(),
      transition: Transition.noTransition,
      binding: OnboardingBinding(),
    ),
    GetPage(name: _Paths.auth, page: () => AuthView(), binding: AuthBinding()),
    GetPage(
      name: _Paths.notificationSubscription,
      page: () => const NotificationSubscriptionView(),
      binding: NotificationSubscriptionBinding(),
    ),
  ];
}
