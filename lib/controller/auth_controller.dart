import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final isLoggedIn = false.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhoneNumber = ''.obs;
  final userPhotoUrl = ''.obs;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _authService.authStateChanges.listen(_updateUser);
  }

  Future<void> _updateUser(User? user) async {
    isLoggedIn.value = user != null;
    userName.value = _fallbackName(user);
    userEmail.value = user?.email ?? '';
    userPhoneNumber.value = user?.phoneNumber ?? '';
    userPhotoUrl.value = user?.photoURL ?? '';
    if (user == null) return;

    try {
      final fullName = await _authService.fetchUserName(user.uid);
      if (fullName != null &&
          FirebaseAuth.instance.currentUser?.uid == user.uid) {
        userName.value = fullName;
      }
    } catch (error, stackTrace) {
      debugPrint('Unable to load user profile name: $error\n$stackTrace');
    }
  }

  String _fallbackName(User? user) {
    final displayName = user?.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;

    final emailName = user?.email?.split('@').first.trim() ?? '';
    return emailName.isNotEmpty ? emailName : '';
  }

  Future<void> logout() async {
    await _authService.signOut();
    userName.value = '';
    userEmail.value = '';
    userPhoneNumber.value = '';
    userPhotoUrl.value = '';
    isLoggedIn.value = false;
    await Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
