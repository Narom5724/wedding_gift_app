import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'package:wedding_gift_app/utils/currency_helper.dart';

class GiftCardWidget extends StatelessWidget {
  const GiftCardWidget({
    super.key,
    required this.gift,
    required this.onTap,
    required this.weddingName,
    required this.guestName,
    required this.onEdit,
    required this.onDelete,
  });

  final GiftModel gift;
  final VoidCallback onTap;
  final String weddingName;
  final String guestName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.card_giftcard_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(CurrencyHelper.formatAmount(gift.amount, gift.currency)),
        subtitle: Text(
          '$guestName · $weddingName\n'
          '${DateFormat('dd MMM yyyy').format(gift.receivedDate)} · ${gift.paymentMethod}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
