import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/controller/wedding_controller.dart';
import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_add_widget.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_delete_dialog.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_detail_widget.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_edit_widget.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_list_widget.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_search_field.dart';

class WeddingScreen extends StatefulWidget {
  const WeddingScreen({super.key});

  @override
  State<WeddingScreen> createState() => _WeddingScreenState();
}

class _WeddingScreenState extends State<WeddingScreen> {
  late final WeddingController controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<WeddingController>();
    _searchController = TextEditingController(
      text: controller.searchText.value,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: Get.back),
            title: Text('weddings'.tr),
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(isWide ? 12 : 16),
              child: Obx(() {
                final weddings = controller.weddings.toList();
                final selectedDate = controller.selectedDate.value;
                final searchText = controller.searchText.value;

                return Column(
                  children: [
                    WeddingSearchField(
                      controller: _searchController,
                      onChanged: controller.updateSearch,
                      isDateFiltered: selectedDate != null,
                      onDateFilter: () => _toggleDateFilter(context),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, rowConstraints) {
                        final compactAction = rowConstraints.maxWidth < 400;

                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${weddings.length} '
                                '${(weddings.length == 1 ? 'wedding' : 'weddings').tr.toUpperCase()}',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (compactAction)
                              IconButton.filled(
                                tooltip: 'add_wedding'.tr,
                                onPressed: () => _showAddDialog(context),
                                icon: const Icon(Icons.add),
                              )
                            else
                              FilledButton.icon(
                                onPressed: () => _showAddDialog(context),
                                icon: const Icon(Icons.add),
                                label: Text('add_wedding'.tr),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: WeddingListWidget(
                        weddings: weddings,
                        isLoading: controller.isLoading.value,
                        isDesktopLayout: isWide,
                        errorMessage: controller.errorMessage.value,
                        isFiltered:
                            searchText.isNotEmpty || selectedDate != null,
                        onRefresh: controller.loadWeddings,
                        onClearFilters: () {
                          _searchController.clear();
                          controller.clearFilters();
                        },
                        onAddWedding: () => _showAddDialog(context),
                        onView: (wedding) => showDialog<void>(
                          context: context,
                          builder: (_) => WeddingDetailWidget(wedding: wedding),
                        ),
                        onEdit: (wedding) => _showEditDialog(context, wedding),
                        onDelete: (weddingId) =>
                            _deleteWedding(context, weddingId),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleDateFilter(BuildContext context) async {
    if (controller.selectedDate.value != null) {
      controller.filterByDate(null);
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    controller.filterByDate(date);
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => WeddingAddWidget(
        onSubmit: (model) async {
          await controller.createWedding(model);
          Get.back();
          Get.snackbar(
            'wedding_created'.tr,
            'changes_saved'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onCancel: () => Get.back(),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WeddingModel wedding) {
    showDialog(
      context: context,
      builder: (_) => WeddingEditWidget(
        wedding: wedding,
        onSubmit: (model) async {
          await controller.updateWedding(model);
          Get.back();
          Get.snackbar(
            'wedding_updated'.tr,
            'changes_saved'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onCancel: () => Get.back(),
      ),
    );
  }

  Future<void> _deleteWedding(BuildContext context, String weddingId) async {
    final confirmed = await showWeddingDeleteDialog(context, weddingId);
    if (!confirmed) return;

    try {
      await controller.deleteWedding(weddingId);
      Get.snackbar(
        'success'.tr,
        'wedding_deleted'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'delete_failed'.tr,
        controller.errorMessage.value.isNotEmpty
            ? controller.errorMessage.value
            : 'wedding_delete_failed_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
