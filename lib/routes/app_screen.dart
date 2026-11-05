import 'package:get/get.dart';

import 'package:wedding_gift_app/binding/auth_binding.dart';
import 'package:wedding_gift_app/binding/dashboard_binding.dart';
import 'package:wedding_gift_app/binding/wedding_binding.dart';
import 'package:wedding_gift_app/binding/guest_binding.dart';
import 'package:wedding_gift_app/binding/gift_binding.dart';
import 'package:wedding_gift_app/binding/report_binding.dart';
import 'package:wedding_gift_app/binding/gallery_binding.dart';
import 'package:wedding_gift_app/screen/auth/login_screen.dart';
import 'package:wedding_gift_app/screen/auth/register_screen.dart';
import 'package:wedding_gift_app/screen/auth/forgot_password_screen.dart';
import 'package:wedding_gift_app/screen/home/home_screen.dart';
import 'package:wedding_gift_app/screen/dashboard/dashboard_screen.dart';
import 'package:wedding_gift_app/screen/manage/manage_screen.dart';
import 'package:wedding_gift_app/screen/wedding/wedding_screen.dart';
import 'package:wedding_gift_app/screen/guest/guest_screen.dart';
import 'package:wedding_gift_app/screen/gift/gift_screen.dart';
import 'package:wedding_gift_app/screen/report/report_screen.dart';
import 'package:wedding_gift_app/screen/gallery/gallery_screen.dart';
import 'package:wedding_gift_app/screen/setting/setting_screen.dart';
import 'package:wedding_gift_app/screen/profile/profile_screen.dart';
import 'package:wedding_gift_app/screen/splash_screen.dart';
import 'package:wedding_gift_app/screen/widgets/responsive_app_shell.dart';
import 'app_route.dart';

class AppScreen {
  static final pages = [
    GetPage(
      name: AppRoute.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoute.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoute.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoute.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppRoute.home,
      page: () =>
          const ResponsiveAppShell(selectedIndex: 0, child: HomeScreen()),
    ),
    GetPage(
      name: AppRoute.dashboard,
      page: () =>
          const ResponsiveAppShell(selectedIndex: 0, child: DashboardScreen()),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoute.manage,
      page: () =>
          const ResponsiveAppShell(selectedIndex: 1, child: ManageScreen()),
    ),
    GetPage(
      name: AppRoute.wedding,
      page: () =>
          const ResponsiveAppShell(selectedIndex: 1, child: WeddingScreen()),
      binding: WeddingBinding(),
    ),
    GetPage(
      name: AppRoute.guest,
      page: () =>
          const ResponsiveAppShell(selectedIndex: 1, child: GuestScreen()),
      binding: GuestBinding(),
    ),
    GetPage(
      name: AppRoute.gift,
      page: () =>
          const ResponsiveAppShell(selectedIndex: 1, child: GiftScreen()),
      binding: GiftBinding(),
    ),
    GetPage(
      name: AppRoute.report,
      page: () =>
          const ResponsiveAppShell(selectedIndex: 2, child: ReportScreen()),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoute.gallery,
      page: () =>
          const ResponsiveAppShell(selectedIndex: 1, child: GalleryScreen()),
      binding: GalleryBinding(),
    ),
    GetPage(
      name: AppRoute.setting,
      page: () =>
          const ResponsiveAppShell(selectedIndex: 3, child: SettingScreen()),
    ),
    GetPage(
      name: AppRoute.profile,
      page: () =>
          const ResponsiveAppShell(selectedIndex: 3, child: ProfileScreen()),
    ),
  ];
}
