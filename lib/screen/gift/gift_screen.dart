import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/controller/gift_controller.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_add_widget.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_delete_dialog.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_edit_widget.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_list_widget.dart';

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> {
  late final GiftController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<GiftController>();
    controller.loadRelatedNames();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: Get.back),
            title: Text('gifts'.tr),
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(isWide ? 12 : 16),
              child: Obx(() {
                final gifts = controller.gifts.toList();

                return Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'search_gifts'.tr,
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                      onChanged: controller.updateSearch,
                    ),
                    const SizedBox(height: 18),
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
                        isDesktopLayout: isWide,
                        weddingNames: {...controller.weddingNames},
                        guestNames: {...controller.guestNames},
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
