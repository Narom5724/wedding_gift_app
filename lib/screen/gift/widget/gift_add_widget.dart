import 'package:flutter/material.dart';

import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'gift_form_widget.dart';

class GiftAddWidget extends StatelessWidget {
  const GiftAddWidget({super.key, required this.onSubmit, this.onCancel});

  final Future<void> Function(GiftModel) onSubmit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return GiftFormWidget(
      isEditing: false,
      onSubmit: onSubmit,
      onCancel: onCancel,
    );
  }
}
