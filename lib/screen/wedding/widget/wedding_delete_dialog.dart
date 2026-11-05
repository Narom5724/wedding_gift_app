import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showWeddingDeleteDialog(
  BuildContext context,
  String weddingId,
) async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: Text('delete_wedding_confirmation'.tr),
      content: Text('delete_action_cannot_undo'.tr),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text('delete'.tr),
        ),
      ],
    ),
    barrierDismissible: true,
  );

  return confirmed ?? false;
}
