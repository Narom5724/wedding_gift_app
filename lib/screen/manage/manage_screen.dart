import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  static const _sections = <_ManageSection>[
    _ManageSection(
      titleKey: 'wedding_management',
      items: [
        _ManageItem(
          titleKey: 'weddings',
          route: '/wedding',
          icon: Icons.favorite_border_rounded,
        ),
        _ManageItem(
          titleKey: 'guests',
          route: '/guest',
          icon: Icons.people_outline_rounded,
        ),
      ],
    ),
    _ManageSection(
      titleKey: 'gift_management',
      items: [
        _ManageItem(
          titleKey: 'gifts',
          route: '/gift',
          icon: Icons.card_giftcard_rounded,
        ),
      ],
    ),
    _ManageSection(
      titleKey: 'planning_management',
      items: [
        _ManageItem(
          titleKey: 'gallery',
          route: '/gallery',
          icon: Icons.photo_library_outlined,
        ),
        _ManageItem(
          titleKey: 'reports',
          route: '/report',
          icon: Icons.receipt_long_outlined,
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final sections = _sections
        .map(
          (section) => (
            section.titleKey.tr,
            section.items
                .where(
                  (item) =>
                      query.isEmpty ||
                      item.titleKey.tr.toLowerCase().contains(query) ||
                      section.titleKey.tr.toLowerCase().contains(query),
                )
                .toList(),
          ),
        )
        .where((section) => section.$2.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
            final columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 520
                ? 2
                : 2;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                24,
              ),
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'search_function'.tr,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'clear_search'.tr,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 22),
                if (sections.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'no_manage_results'.tr,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  )
                else
                  for (final section in sections) ...[
                    Text(
                      section.$1,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, sectionConstraints) {
                        final cardWidth =
                            (sectionConstraints.maxWidth - (columns - 1) * 12) /
                            columns;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final item in section.$2)
                              _ManageCard(
                                item: item,
                                width: cardWidth,
                                onTap: () => Get.toNamed(item.route),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ManageCard extends StatelessWidget {
  const _ManageCard({
    required this.item,
    required this.width,
    required this.onTap,
  });

  final _ManageItem item;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      height: 148,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 30, color: colorScheme.primary),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.titleKey.tr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageSection {
  const _ManageSection({required this.titleKey, required this.items});

  final String titleKey;
  final List<_ManageItem> items;
}

class _ManageItem {
  const _ManageItem({
    required this.titleKey,
    required this.route,
    required this.icon,
  });

  final String titleKey;
  final String route;
  final IconData icon;
}
