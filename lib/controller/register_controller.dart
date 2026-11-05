import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/services/auth_service.dart';

class RegisterController extends GetxController {
  final AuthService _authService = AuthService();
  final fullName = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final isSubmitting = false.obs;

  Future<void> submit() async {
    if (isSubmitting.value) return;

    if (fullName.value.trim().isEmpty ||
        email.value.trim().isEmpty ||
        password.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please complete all required fields.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.value != confirmPassword.value) {
      Get.snackbar(
        'Validation',
        'Passwords do not match.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final credential = await _authService.signUp(
        fullName: fullName.value,
        email: email.value,
        password: password.value,
      );
      if (credential.user != null) {
        Get.offAllNamed('/home');
      }
    } on FirebaseAuthException catch (error) {
      Get.snackbar(
        'Registration failed',
        error.message ?? 'Unable to create account.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Registration failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
