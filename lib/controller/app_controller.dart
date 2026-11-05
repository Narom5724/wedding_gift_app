import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppController extends GetxController {
  final isLoading = true.obs;
  final isDarkMode = false.obs;
  String get initialRoute {
    if (Firebase.apps.isEmpty) return '/login';
    return FirebaseAuth.instance.currentUser == null ? '/login' : '/home';
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = GetStorage();
    isDarkMode.value = box.read('isDarkMode') ?? false;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    isLoading.value = false;
  }
}
