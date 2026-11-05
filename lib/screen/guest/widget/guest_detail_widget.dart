import 'package:flutter/material.dart';

import '../../../models/guest/guest_model.dart';

class GuestDetailWidget extends StatelessWidget {
  const GuestDetailWidget({super.key, required this.guest});

  final GuestModel guest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(guest.fullName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(guest.relationship),
          const SizedBox(height: 4),
          Text(guest.phone),
          if (guest.address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(guest.address),
          ],
        ],
      ),
    );
  }
}
