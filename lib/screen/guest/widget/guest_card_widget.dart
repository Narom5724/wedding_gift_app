import 'package:flutter/material.dart';

import '../../../models/guest/guest_model.dart';

class GuestCardWidget extends StatelessWidget {
  const GuestCardWidget({
    super.key,
    required this.guest,
    required this.onEdit,
    required this.onDelete,
  });

  final GuestModel guest;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(guest.fullName),
        subtitle: Text('${guest.relationship} • ${guest.phone}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
