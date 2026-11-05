import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/constants/app_theme.dart';
import 'package:wedding_gift_app/controller/dashboard_controller.dart';
import 'package:wedding_gift_app/screen/widgets/section_header.dart';
import 'package:wedding_gift_app/screen/widgets/summary_card.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.warmCream,
        foregroundColor: AppColors.charcoal,
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial overview',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.mutedGray),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Wedding performance',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.rosePink,
                    size: 32,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Summary'),
            const SizedBox(height: 16),
            Obx(
              () => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SummaryCard(
                    icon: Icons.cake_rounded,
                    title: 'Weddings',
                    value: '${controller.summary.value.totalWeddings}',
                    subtitle: 'Created',
                    color: AppColors.rosePink,
                  ),
                  SummaryCard(
                    icon: Icons.people_alt_rounded,
                    title: 'Guests',
                    value: '${controller.summary.value.totalGuests}',
                    subtitle: 'Planning list',
                    color: AppColors.champagneGold,
                  ),
                  SummaryCard(
                    icon: Icons.card_giftcard_rounded,
                    title: 'Gift records',
                    value: '${controller.summary.value.totalGiftRecords}',
                    subtitle: 'Recorded',
                    color: AppColors.champagneGold,
                  ),
                  SummaryCard(
                    icon: Icons.attach_money_rounded,
                    title: 'Gift total',
                    value:
                        '៛${NumberFormat('#,##0').format(controller.summary.value.totalKhr)}',
                    subtitle: 'KHR received',
                    color: AppColors.rosePink,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _InfoCard(
              title: 'USD total',
              value:
                  '\$${NumberFormat('#,##0.00').format(controller.summary.value.totalUsd)}',
              icon: Icons.attach_money_rounded,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              title: 'KHR total',
              value:
                  '៛${NumberFormat('#,##0').format(controller.summary.value.totalKhr)}',
              icon: Icons.currency_exchange_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
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
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedGray),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
