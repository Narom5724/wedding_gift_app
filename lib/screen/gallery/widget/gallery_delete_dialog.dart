import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showGalleryDeleteDialog(BuildContext context) async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Delete image?'),
      content: const Text('This removes the image from the gallery.'),
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
