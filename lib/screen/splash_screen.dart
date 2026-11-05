import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/constant.dart';
import '../controller/app_controller.dart';

class SplashScreen extends GetView<AppController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.cream],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: 64, color: AppColors.secondary),
                  SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: AppColors.secondary),
                ],
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(controller.initialRoute);
          });

          return const SizedBox.shrink();
        }),
      ),
    );
  }
}
