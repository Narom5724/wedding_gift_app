import 'package:flutter/material.dart';

import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_form_widget.dart';

class WeddingAddWidget extends StatelessWidget {
  const WeddingAddWidget({super.key, required this.onSubmit, this.onCancel});

  final Future<void> Function(WeddingModel) onSubmit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return WeddingFormWidget(
      isEditing: false,
      onSubmit: onSubmit,
      onCancel: onCancel,
    );
  }
}
