import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/guest_controller.dart';
import 'widget/guest_add_widget.dart';
import 'widget/guest_delete_dialog.dart';
import 'widget/guest_edit_widget.dart';
import 'widget/guest_list_widget.dart';

class GuestScreen extends GetView<GuestController> {
  const GuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: Get.back),
            title: Text('guests'.tr),
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(isWide ? 12 : 16),
              child: Obx(() {
                final guests = controller.guestList.toList();

                return Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, searchConstraints) {
                        final sideBySide = searchConstraints.maxWidth >= 600;
                        final searchField = TextField(
                          decoration: InputDecoration(
                            hintText: 'search_guests'.tr,
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                          onChanged: controller.updateSearch,
                        );
                        final relationshipField = TextField(
                          decoration: InputDecoration(
                            hintText: 'filter_guest_relationship'.tr,
                            prefixIcon: const Icon(Icons.tune_rounded),
                          ),
                          onChanged: controller.updateRelationshipFilter,
                        );

                        if (!sideBySide) {
                          return Column(
                            children: [
                              searchField,
                              const SizedBox(height: 10),
                              relationshipField,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(flex: 3, child: searchField),
                            const SizedBox(width: 12),
                            Expanded(flex: 2, child: relationshipField),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, rowConstraints) {
                        final compactAction = rowConstraints.maxWidth < 400;

                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${guests.length} '
                                '${(guests.length == 1 ? 'guest' : 'guests').tr.toUpperCase()}',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (compactAction)
                              IconButton.filled(
                                tooltip: 'add_guest'.tr,
                                onPressed: () => _showAddDialog(context),
                                icon: const Icon(Icons.add),
                              )
                            else
                              FilledButton.icon(
                                onPressed: () => _showAddDialog(context),
                                icon: const Icon(Icons.add),
                                label: Text('add_guest'.tr),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GuestListWidget(
                        guests: guests,
                        isLoading: controller.isLoading.value,
                        isDesktopLayout: isWide,
                        errorMessage: controller.errorMessage.value,
                        onRefresh: controller.loadGuests,
                        onEdit: (guest) => showDialog(
                          context: context,
                          builder: (_) => GuestEditWidget(
                            guest: guest,
                            onSubmit: (model) async {
                              await controller.updateGuest(model);
                              Get.back();
                              Get.snackbar(
                                'success'.tr,
                                'guest_updated'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            onCancel: () => Get.back(),
                          ),
                        ),
                        onDelete: (guestId) async {
                          final confirmed = await showGuestDeleteDialog(
                            context,
                          );
                          if (!confirmed) return;

                          try {
                            await controller.deleteGuest(guestId);
                            Get.snackbar(
                              'success'.tr,
                              'guest_deleted'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } catch (error) {
                            Get.snackbar(
                              'delete_failed'.tr,
                              controller.errorMessage.value.isNotEmpty
                                  ? controller.errorMessage.value
                                  : error.toString(),
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
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

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => GuestAddWidget(
        onSubmit: (model) async {
          await controller.createGuest(model);
          Get.back();
          Get.snackbar(
            'success'.tr,
            'guest_created'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onCancel: () => Get.back(),
      ),
    );
  }
}
