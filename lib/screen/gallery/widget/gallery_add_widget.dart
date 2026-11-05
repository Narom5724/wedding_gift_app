import 'package:flutter/material.dart';

class GalleryAddWidget extends StatelessWidget {
  const GalleryAddWidget({
    super.key,
    required this.onAdd,
    this.isLoading = false,
    this.loadingLabel = 'Loading image',
  });

  final Future<void> Function() onAdd;
  final bool isLoading;
  final String loadingLabel;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isLoading ? null : onAdd,
      tooltip: isLoading ? loadingLabel : 'Upload image',
      icon: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.upload),
      label: Text(isLoading ? loadingLabel : 'Upload image'),
    );
  }
}
