import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showGuestDeleteDialog(BuildContext context) async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Delete guest?'),
      content: const Text('This will remove the guest record.'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Delete'),
        ),
      ],
    ),
    barrierDismissible: true,
  );

  return confirmed ?? false;
}
