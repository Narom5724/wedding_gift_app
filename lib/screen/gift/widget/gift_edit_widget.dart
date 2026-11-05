import 'package:flutter/material.dart';

import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'gift_form_widget.dart';

class GiftEditWidget extends StatelessWidget {
  const GiftEditWidget({
    super.key,
    required this.gift,
    required this.onSubmit,
    this.onCancel,
  });

  final GiftModel gift;
  final Future<void> Function(GiftModel) onSubmit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return GiftFormWidget(
      initialGift: gift,
      isEditing: true,
      onSubmit: onSubmit,
      onCancel: onCancel,
    );
  }
}
