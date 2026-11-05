import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WeddingSearchField extends StatelessWidget {
  const WeddingSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onDateFilter,
    required this.isDateFiltered,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onDateFilter;
  final bool isDateFiltered;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'search_weddings'.tr,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          tooltip: isDateFiltered
              ? 'clear_date_filter'.tr
              : 'filter_by_date'.tr,
          onPressed: onDateFilter,
          icon: Icon(
            isDateFiltered
                ? Icons.event_busy_outlined
                : Icons.calendar_month_outlined,
          ),
        ),
      ),
    );
  }
}
