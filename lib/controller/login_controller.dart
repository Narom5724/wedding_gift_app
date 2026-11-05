import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  final email = ''.obs;
  final password = ''.obs;
  final isSubmitting = false.obs;

  Future<void> submit() async {
    if (email.value.trim().isEmpty || password.value.trim().isEmpty) {
      Get.snackbar(
        'Validation',
        'Please enter your email and password.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final credential = await _authService.signIn(
        email: email.value,
        password: password.value,
      );
      if (credential.user != null) {
        Get.offAllNamed('/home');
      }
    } on FirebaseAuthException catch (error) {
      Get.snackbar(
        'Login failed',
        error.message ?? 'Unable to sign in.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Login failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
