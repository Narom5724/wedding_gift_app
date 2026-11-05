import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:wedding_gift_app/controller/gallery_controller.dart';
import 'package:wedding_gift_app/services/storage_service.dart';
import 'package:wedding_gift_app/screen/gallery/widget/gallery_add_widget.dart';
import 'package:wedding_gift_app/screen/gallery/widget/gallery_delete_dialog.dart';
import 'package:wedding_gift_app/screen/gallery/widget/gallery_grid_widget.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late final GalleryController controller;
  bool _isPickingOrUploading = false;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    controller = Get.find<GalleryController>();
  }

  Future<void> _pickAndUploadImage() async {
    if (_isPickingOrUploading) return;
    setState(() {
      _isPickingOrUploading = true;
      _uploadStatus = 'Choose an image';
    });
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
        requestFullMetadata: false,
      );
      if (file == null) return;

      if (mounted) setState(() => _uploadStatus = 'Uploading image');
      final uploadResult = await StorageService().uploadImage(
        file: file,
        folder: 'gallery',
      );
      if (mounted) setState(() => _uploadStatus = 'Saving image');
      await controller.addImage(
        uploadResult['imageUrl'] ?? '',
        storagePath: uploadResult['storagePath'] ?? '',
      );
      if (!mounted) return;
      Get.snackbar(
        'Success',
        'Image uploaded.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      if (!mounted) return;
      Get.snackbar(
        'Upload failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isPickingOrUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      floatingActionButton: GalleryAddWidget(
        onAdd: _pickAndUploadImage,
        isLoading: _isPickingOrUploading,
        loadingLabel: _uploadStatus,
      ),
      body: Obx(() {
        final images = controller.images.toList(growable: false);
        return GalleryGridWidget(
          images: images,
          isLoading: controller.isLoading.value,
          hasMore: controller.hasMore.value,
          errorMessage: controller.errorMessage.value,
          onLoadMore: controller.loadMore,
          onRetry: controller.refreshGallery,
          onDelete: (url) async {
            final confirmed = await showGalleryDeleteDialog(context);
            if (!confirmed) return false;

            try {
              await controller.deleteImage(url);
              return true;
            } catch (error) {
              Get.snackbar(
                'Delete failed',
                error.toString(),
                snackPosition: SnackPosition.BOTTOM,
              );
              return false;
            }
          },
        );
      }),
    );
  }
}
