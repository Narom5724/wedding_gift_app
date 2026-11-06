import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_card_widget.dart';
import 'package:wedding_gift_app/screen/widgets/app_record_table.dart';
import 'package:wedding_gift_app/utils/currency_helper.dart';

class GiftListWidget extends StatelessWidget {
  const GiftListWidget({
    super.key,
    required this.gifts,
    required this.isLoading,
    required this.errorMessage,
    this.isDesktopLayout,
    this.weddingNames = const {},
    this.guestNames = const {},
    required this.onRefresh,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final List<GiftModel> gifts;
  final bool isLoading;
  final String errorMessage;
  final bool? isDesktopLayout;
  final Map<String, String> weddingNames;
  final Map<String, String> guestNames;
  final Future<void> Function() onRefresh;
  final ValueChanged<GiftModel> onTap;
  final ValueChanged<GiftModel> onEdit;
  final Future<void> Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 44),
              const SizedBox(height: 12),
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (gifts.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Center(child: Text('No gifts recorded.')),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isDesktopLayout ?? constraints.maxWidth >= 600) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: AppRecordTable(
                onRowTap: gifts.map((gift) => () => onTap(gift)).toList(),
                columns: const [
                  'Wedding',
                  'Guest',
                  'Amount',
                  'Received by',
                  'Date',
                  'Notes',
                  'Actions',
                ],
                rows: gifts.map((gift) {
                  return [
                    Text(weddingNames[gift.weddingId] ?? '-'),
                    Text(guestNames[gift.guestId] ?? '-'),
                    Text(
                      CurrencyHelper.formatAmount(gift.amount, gift.currency),
                    ),
                    Text(gift.paymentMethod),
                    Text(DateFormat('dd MMM yyyy').format(gift.receivedDate)),
                    Text(gift.notes),
                    PopupMenuButton<String>(
                      tooltip: 'Gift actions',
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit(gift);
                        } else if (value == 'delete') {
                          onDelete(gift.id);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ];
                }).toList(),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return GiftCardWidget(
                gift: gift,
                onTap: () => onTap(gift),
                weddingName: weddingNames[gift.weddingId] ?? '-',
                guestName: guestNames[gift.guestId] ?? '-',
                onEdit: () => onEdit(gift),
                onDelete: () => onDelete(gift.id),
              );
            },
          ),
        );
      },
    );
  }
}


