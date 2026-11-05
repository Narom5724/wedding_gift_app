import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/controller/gift_controller.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_add_widget.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_delete_dialog.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_edit_widget.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_list_widget.dart';

class GiftScreen extends GetView<GiftController> {
  const GiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;

        return Scaffold(
          appBar: isWide ? null : AppBar(title: Text('gifts'.tr)),
          body: SafeArea(
            top: isWide,
            child: Padding(
              padding: EdgeInsets.all(isWide ? 12 : 16),
              child: Obx(() {
                final gifts = controller.gifts.toList();

                return Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by name, ID, amount, date, or notes',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: controller.updateSearch,
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, rowConstraints) {
                        final compactAction = rowConstraints.maxWidth < 400;

                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${gifts.length} '
                                '${(gifts.length == 1 ? 'gift' : 'gifts').tr.toUpperCase()}',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (compactAction)
                              IconButton.filled(
                                tooltip: 'add_gift'.tr,
                                onPressed: () => _showAddDialog(context),
                                icon: const Icon(Icons.add),
                              )
                            else
                              FilledButton.icon(
                                onPressed: () => _showAddDialog(context),
                                icon: const Icon(Icons.add),
                                label: Text('add_gift'.tr),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GiftListWidget(
                        gifts: gifts,
                        isLoading: controller.isLoading.value,
                        errorMessage: controller.errorMessage.value,
                        onRefresh: controller.loadGifts,
                        onEdit: (gift) => showDialog(
                          context: context,
                          builder: (_) => GiftEditWidget(
                            gift: gift,
                            onSubmit: (model) async {
                              await controller.updateGift(model);
                              Get.back();
                              Get.snackbar(
                                'success'.tr,
                                'gift_updated'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            onCancel: () => Get.back(),
                          ),
                        ),
                        onDelete: (giftId) async {
                          final confirmed = await showGiftDeleteDialog(context);
                          if (!confirmed) return;

                          try {
                            await controller.deleteGift(giftId);
                            Get.snackbar(
                              'success'.tr,
                              'gift_deleted'.tr,
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
      builder: (_) => GiftAddWidget(
        onSubmit: (model) async {
          await controller.createGift(model);
          Get.back();
          Get.snackbar(
            'success'.tr,
            'gift_created'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onCancel: () => Get.back(),
      ),
    );
  }
}
