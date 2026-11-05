import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_card_widget.dart';
import 'package:wedding_gift_app/utils/currency_helper.dart';

class GiftListWidget extends StatelessWidget {
  const GiftListWidget({
    super.key,
    required this.gifts,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  final List<GiftModel> gifts;
  final bool isLoading;
  final String errorMessage;
  final Future<void> Function() onRefresh;
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
        if (constraints.maxWidth >= 760) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Gift ID')),
                    DataColumn(label: Text('Wedding ID')),
                    DataColumn(label: Text('Guest ID')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Received by')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Notes')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: gifts.map((gift) {
                    return DataRow(
                      cells: [
                        DataCell(Text(gift.id)),
                        DataCell(Text(gift.weddingId)),
                        DataCell(Text(gift.guestId)),
                        DataCell(
                          Text(
                            CurrencyHelper.formatAmount(
                              gift.amount,
                              gift.currency,
                            ),
                          ),
                        ),
                        DataCell(Text(gift.paymentMethod)),
                        DataCell(
                          Text(
                            DateFormat('dd MMM yyyy').format(gift.receivedDate),
                          ),
                        ),
                        DataCell(Text(gift.notes)),
                        DataCell(
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
                        ),
                      ],
                    );
                  }).toList(),
                ),
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
