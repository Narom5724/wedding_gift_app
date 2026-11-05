import 'package:flutter/material.dart';

import '../../../models/guest/guest_model.dart';
import 'guest_card_widget.dart';

class GuestListWidget extends StatelessWidget {
  const GuestListWidget({
    super.key,
    required this.guests,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  final List<GuestModel> guests;
  final bool isLoading;
  final String errorMessage;
  final Future<void> Function() onRefresh;
  final ValueChanged<GuestModel> onEdit;
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

    if (guests.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Center(child: Text('No guests found.')),
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
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Relationship')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Address')),
                    DataColumn(label: Text('Notes')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: guests.map((guest) {
                    return DataRow(
                      cells: [
                        DataCell(Text(guest.fullName)),
                        DataCell(Text(guest.relationship)),
                        DataCell(Text(guest.phone)),
                        DataCell(Text(guest.address)),
                        DataCell(Text(guest.notes)),
                        DataCell(
                          PopupMenuButton<String>(
                            tooltip: 'Guest actions',
                            onSelected: (value) {
                              if (value == 'edit') {
                                onEdit(guest);
                              } else if (value == 'delete') {
                                onDelete(guest.id);
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
            itemCount: guests.length,
            itemBuilder: (context, index) {
              final guest = guests[index];
              return GuestCardWidget(
                guest: guest,
                onEdit: () => onEdit(guest),
                onDelete: () => onDelete(guest.id),
              );
            },
          ),
        );
      },
    );
  }
}
