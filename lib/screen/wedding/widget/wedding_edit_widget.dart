import 'package:flutter/material.dart';

import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_form_widget.dart';

class WeddingEditWidget extends StatelessWidget {
  const WeddingEditWidget({
    super.key,
    required this.wedding,
    required this.onSubmit,
    this.onCancel,
  });

  final WeddingModel wedding;
  final Future<void> Function(WeddingModel) onSubmit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return WeddingFormWidget(
      initialWedding: wedding,
      isEditing: true,
      onSubmit: onSubmit,
      onCancel: onCancel,
    );
  }
}
