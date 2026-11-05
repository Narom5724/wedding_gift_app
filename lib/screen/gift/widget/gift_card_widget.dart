import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'package:wedding_gift_app/utils/currency_helper.dart';

class GiftCardWidget extends StatelessWidget {
  const GiftCardWidget({
    super.key,
    required this.gift,
    required this.onEdit,
    required this.onDelete,
  });

  final GiftModel gift;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(CurrencyHelper.formatAmount(gift.amount, gift.currency)),
        subtitle: Text(
          '${DateFormat('dd MMM yyyy').format(gift.receivedDate)} • ${gift.paymentMethod}',
        ),
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
