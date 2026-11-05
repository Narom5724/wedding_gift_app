import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wedding_gift_app/firebase_options.dart';
import 'package:wedding_gift_app/controller/auth_controller.dart';
import 'package:wedding_gift_app/controller/setting_controller.dart';

import 'constants/app_theme.dart';
import 'locator.dart';
import 'routes/app_route.dart';
import 'routes/app_screen.dart';
import 'services/storage_service.dart';
import 'utils/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  var supabaseUrl = '';
  var supabaseAnonKey = '';
  var storageBucketName = '';
  try {
    await dotenv.load(fileName: 'assets/.env');
    supabaseUrl = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
    storageBucketName =
        dotenv.env['SUPABASE_STORAGE_BUCKET']?.trim() ?? 'gallery';
  } catch (error) {
    debugPrint(
      'Unable to load Supabase environment config (${error.runtimeType}). '
      'Gallery upload and deletion will be unavailable.',
    );
  }

  StorageService.configureBucketName(storageBucketName);

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final firebaseProjectId = Firebase.app().options.projectId;
  if (firebaseProjectId != 'wedding-gift-app-74269') {
    throw StateError(
      'Firebase is connected to "$firebaseProjectId", expected '
      '"wedding-gift-app-74269".',
    );
  }

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
    } catch (error) {
      debugPrint(
        'Supabase initialization failed (${error.runtimeType}). '
        'Check the Supabase URL, publishable key, and network connection.',
      );
    }
  } else {
    debugPrint(
      'Supabase is not configured. Gallery upload and deletion are unavailable.',
    );
  }

  setupLocator();

  final isDarkModeSaved = GetStorage().read('isDarkMode') ?? false;
  runApp(MyApp(isDarkModeSaved: isDarkModeSaved));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.isDarkModeSaved = false});

  final bool isDarkModeSaved;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wedding Gift Book',
      debugShowCheckedModeBanner: false,
      theme: WeddingAppTheme.lightTheme,
      darkTheme: WeddingAppTheme.darkTheme,
      themeMode: isDarkModeSaved ? ThemeMode.dark : ThemeMode.light,
      translations: AppTranslations(),
      locale: Locale(GetStorage().read<String>('language') ?? 'en'),
      fallbackLocale: const Locale('en'),
      initialRoute: AppRoute.splash,
      initialBinding: BindingsBuilder(() {
        Get.put<AuthController>(AuthController(), permanent: true);
        Get.put<SettingController>(SettingController(), permanent: true);
      }),
      getPages: AppScreen.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
