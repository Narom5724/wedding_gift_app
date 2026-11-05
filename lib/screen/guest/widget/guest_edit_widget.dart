import 'package:flutter/material.dart';

import '../../../models/guest/guest_model.dart';
import 'guest_form_widget.dart';

class GuestEditWidget extends StatelessWidget {
  const GuestEditWidget({
    super.key,
    required this.guest,
    required this.onSubmit,
    this.onCancel,
  });

  final GuestModel guest;
  final Future<void> Function(GuestModel) onSubmit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return GuestFormWidget(
      initialGuest: guest,
      isEditing: true,
      onSubmit: onSubmit,
      onCancel: onCancel,
    );
  }
}
