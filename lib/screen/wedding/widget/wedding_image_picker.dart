import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class WeddingImagePicker extends StatelessWidget {
  const WeddingImagePicker({
    super.key,
    required this.imageUrl,
    required this.selectedImage,
    required this.selectedImageBytes,
    required this.isBusy,
    required this.onPick,
    required this.onClear,
  });

  final String imageUrl;
  final XFile? selectedImage;
  final Uint8List? selectedImageBytes;
  final bool isBusy;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasExistingImage = imageUrl.isNotEmpty;
    final hasSelectedImage = selectedImageBytes != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final preview = ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: compact ? 76 : 96,
            height: compact ? 76 : 88,
            child: hasSelectedImage
                ? Image.memory(selectedImageBytes!, fit: BoxFit.cover)
                : hasExistingImage
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _placeholder(theme),
                  )
                : _placeholder(theme),
          ),
        );
        final actions = Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            TextButton.icon(
              onPressed: isBusy ? null : onPick,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: Text(
                (hasExistingImage ? 'replace_photo' : 'choose_photo').tr,
              ),
            ),
            if (hasSelectedImage)
              TextButton(
                onPressed: isBusy ? null : onClear,
                child: Text('remove_selection'.tr),
              ),
          ],
        );
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasSelectedImage
                  ? selectedImage!.name
                  : hasExistingImage
                  ? 'current_cover_photo'.tr
                  : 'no_photo_selected'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'choose_photo_action'.trParams({
                'action': (hasExistingImage ? 'replace' : 'upload').tr,
              }),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            actions,
          ],
        );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        preview,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasSelectedImage
                                    ? selectedImage!.name
                                    : hasExistingImage
                                    ? 'current_cover_photo'.tr
                                    : 'no_photo_selected'.tr,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'choose_photo_action'.trParams({
                                  'action':
                                      (hasExistingImage ? 'replace' : 'upload')
                                          .tr,
                                }),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    actions,
                  ],
                )
              : Row(
                  children: [
                    preview,
                    const SizedBox(width: 14),
                    Expanded(child: text),
                  ],
                ),
        );
      },
    );
  }

  Widget _placeholder(ThemeData theme) {
    return ColoredBox(
      color: theme.colorScheme.primaryContainer,
      child: Icon(
        Icons.add_photo_alternate_outlined,
        size: 32,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
