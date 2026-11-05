import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/constants/app_theme.dart';
import 'package:wedding_gift_app/controller/auth_controller.dart';
import 'package:wedding_gift_app/controller/dashboard_controller.dart';
import 'package:wedding_gift_app/controller/guest_controller.dart';
import 'package:wedding_gift_app/controller/gift_controller.dart';
import 'package:wedding_gift_app/screen/widgets/section_header.dart';
import 'package:wedding_gift_app/screen/widgets/summary_card.dart';
import 'package:wedding_gift_app/utils/currency_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DashboardController dashboardController;
  late final GuestController guestController;
  late final GiftController giftController;
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    dashboardController = Get.put(DashboardController());
    guestController = Get.put(GuestController());
    giftController = Get.put(GiftController());
  }

  Future<void> _openAndRefresh(String route) async {
    await Get.toNamed(route);
    if (!mounted) return;
    await Future.wait([
      dashboardController.loadDashboard(),
      guestController.loadGuests(),
      giftController.loadGifts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final quickActions = [
      _QuickActionConfig(
        icon: Icons.cake_rounded,
        label: 'add_wedding_action'.tr,
        route: '/wedding',
      ),
      _QuickActionConfig(
        icon: Icons.person_add_alt_1_rounded,
        label: 'add_guest_action'.tr,
        route: '/guest',
      ),
      _QuickActionConfig(
        icon: Icons.card_giftcard_rounded,
        label: 'record_gift_action'.tr,
        route: '/gift',
      ),
      _QuickActionConfig(
        icon: Icons.image_rounded,
        label: 'gallery'.tr,
        route: '/gallery',
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await dashboardController.loadDashboard();
          await giftController.loadGifts();
          await guestController.loadGuests();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final padding = EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 20,
              vertical: 20,
            );

            return ListView(
              padding: padding,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'good_evening'.tr,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              authController.userName.value.isEmpty
                                  ? 'wedding_planner'.tr
                                  : authController.userName.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.rosePink,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.softPink,
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.rosePink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'wedding_planner'.tr,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          Text(
                            DateFormat('EEE, MMM d').format(DateTime.now()),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.rosePink, Color(0xFFD9A4A8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'hero_title'.tr,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: AppColors.white),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'hero_subtitle'.tr,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.white.withValues(
                                      alpha: 0.85,
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              onPressed: () => _openAndRefresh('/wedding'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.rosePink,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.add_rounded),
                              label: Text('create_wedding'.tr),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 42,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SectionHeader(title: 'overview'.tr),
                const SizedBox(height: 16),
                Obx(
                  () => Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SummaryCard(
                        icon: Icons.cake_rounded,
                        title: 'total_weddings'.tr,
                        value:
                            '${dashboardController.summary.value.totalWeddings}',
                        subtitle: 'active_plans'.tr,
                        color: AppColors.rosePink,
                        height: 236,
                      ),
                      SummaryCard(
                        icon: Icons.people_alt_rounded,
                        title: 'total_guests'.tr,
                        value:
                            '${dashboardController.summary.value.totalGuests}',
                        subtitle: 'families_invited'.tr,
                        color: AppColors.champagneGold,
                        height: 236,
                      ),
                      SummaryCard(
                        icon: Icons.card_giftcard_rounded,
                        title: 'gift_records'.tr,
                        value:
                            '${dashboardController.summary.value.totalGiftRecords}',
                        subtitle: 'received_today'.tr,
                        color: AppColors.champagneGold,
                        height: 236,
                      ),
                      SummaryCard(
                        icon: Icons.attach_money_rounded,
                        title: 'total_gift_amount'.tr,
                        value: CurrencyHelper.formatAmount(
                          dashboardController.summary.value.totalUsd,
                          CurrencyHelper.usd,
                        ),
                        secondaryValue: CurrencyHelper.formatAmount(
                          dashboardController.summary.value.totalKhr,
                          CurrencyHelper.khr,
                        ),
                        subtitle: 'gift_amounts_received'.tr,
                        color: AppColors.rosePink,
                        height: 236,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SectionHeader(title: 'quick_actions'.tr),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: quickActions
                      .map(
                        (item) => SizedBox(
                          width: isWide ? 190 : 150,
                          child: _QuickActionTile(
                            icon: item.icon,
                            label: item.label,
                            onTap: () => _openAndRefresh(item.route),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 28),
                SectionHeader(
                  title: 'recent_activity'.tr,
                  actionText: 'view_all'.tr,
                  onActionTap: () => _openAndRefresh('/gift'),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => giftController.gifts.isEmpty
                      ? _EmptyState(
                          icon: Icons.favorite_outline_rounded,
                          title: 'no_recent_gifts'.tr,
                          subtitle: 'recent_gifts_subtitle'.tr,
                          actionLabel: 'record_a_gift'.tr,
                          onAction: () => _openAndRefresh('/gift'),
                        )
                      : Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: giftController.gifts.map((gift) {
                              final displayId =
                                  dashboardController.guestNames[gift
                                      .guestId] ??
                                  'guest'.tr;
                              final displayWedding =
                                  dashboardController.weddingNames[gift
                                      .weddingId] ??
                                  'wedding'.tr;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.softPink,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.card_giftcard_rounded,
                                        color: AppColors.rosePink,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayId,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          Text(
                                            displayWedding,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyHelper.formatAmount(
                                            gift.amount,
                                            gift.currency,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Text(
                                          DateFormat(
                                            'dd MMM',
                                          ).format(gift.receivedDate),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
                const SizedBox(height: 28),
                SectionHeader(
                  title: 'upcoming_weddings'.tr,
                  actionText: 'view_all'.tr,
                  onActionTap: () => _openAndRefresh('/wedding'),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => dashboardController.upcomingWeddings.isEmpty
                      ? _EmptyState(
                          icon: Icons.event_available_rounded,
                          title: 'no_upcoming_weddings'.tr,
                          subtitle: 'upcoming_weddings_subtitle'.tr,
                          actionLabel: 'add_wedding_action_button'.tr,
                          onAction: () => _openAndRefresh('/wedding'),
                        )
                      : Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: dashboardController.upcomingWeddings
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: AppColors.softPink,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month_rounded,
                                            color: AppColors.rosePink,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.rosePink),
              ),
              const SizedBox(height: 14),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 54, color: AppColors.rosePink),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.rosePink,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionConfig {
  const _QuickActionConfig({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}
