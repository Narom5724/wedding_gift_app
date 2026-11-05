import 'package:flutter/material.dart';

import '../../../models/guest/guest_model.dart';
import 'guest_form_widget.dart';

class GuestAddWidget extends StatelessWidget {
  const GuestAddWidget({super.key, required this.onSubmit, this.onCancel});

  final Future<void> Function(GuestModel) onSubmit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return GuestFormWidget(
      isEditing: false,
      onSubmit: onSubmit,
      onCancel: onCancel,
    );
  }
}
