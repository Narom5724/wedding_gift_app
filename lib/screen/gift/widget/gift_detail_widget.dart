import 'package:flutter/material.dart';

import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'package:wedding_gift_app/utils/currency_helper.dart';

class GiftDetailWidget extends StatelessWidget {
  const GiftDetailWidget({super.key, required this.gift});

  final GiftModel gift;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CurrencyHelper.formatAmount(gift.amount, gift.currency),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(gift.paymentMethod),
          const SizedBox(height: 4),
          Text(gift.guestId),
          if (gift.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(gift.notes),
          ],
        ],
      ),
    );
  }
}
