import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/constants/app_theme.dart';

class ResponsiveAppShell extends StatelessWidget {
  const ResponsiveAppShell({
    super.key,
    required this.selectedIndex,
    required this.child,
  });

  final int? selectedIndex;
  final Widget child;

  static const _destinations = <_AppDestination>[
    _AppDestination(
      label: 'Home',
      route: '/home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _AppDestination(
      label: 'manage',
      route: '/manage',
      icon: Icons.work_outline_rounded,
      selectedIcon: Icons.work_rounded,
    ),
    // _AppDestination(
    //   label: 'Gift',
    //   route: '/gift',
    //   icon: Icons.card_giftcard_outlined,
    //   selectedIcon: Icons.card_giftcard_rounded,
    // ),
    _AppDestination(
      label: 'Report',
      route: '/report',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
    _AppDestination(
      label: 'Profile',
      route: '/profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  static int? _destinationIndexForRoute(String route) {
    final path = Uri.tryParse(route)?.path ?? route;
    bool matchesAny(Iterable<String> routes) => routes.any(
      (candidate) => path == candidate || path.startsWith('$candidate/'),
    );

    if (matchesAny(['/home', '/dashboard'])) return 0;
    if (matchesAny({
      '/manage',
      '/wedding',
      '/wedding-detail',
      '/guest',
      '/guest-detail',
      '/gift',
      '/gift-detail',
      '/gallery',
    })) {
      return 1;
    }
    if (matchesAny(['/report'])) return 2;
    if (matchesAny(['/profile', '/setting'])) return 3;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final routeIndex = _destinationIndexForRoute(Get.currentRoute);
        final requestedIndex = selectedIndex;
        final validFallback = requestedIndex != null &&
                requestedIndex >= 0 &&
                requestedIndex < _destinations.length
            ? requestedIndex
            : null;
        final activeIndex = routeIndex ?? validFallback;
        if (constraints.maxWidth >= 900) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: _WideNavigationRail(selectedIndex: activeIndex),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: _CompactNavigationBar(
            selectedIndex: activeIndex,
            isSmall: constraints.maxWidth < 600,
          ),
        );
      },
    );
  }
}

class _WideNavigationRail extends StatelessWidget {
  const _WideNavigationRail({required this.selectedIndex});

  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      key: const ValueKey('responsive-navigation-rail'),
      selectedIndex: selectedIndex,
      labelType: NavigationRailLabelType.all,
      minWidth: 100,
      groupAlignment: -0.75,
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: AppColors.softPink,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      selectedIconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onSurface,
        size: 25,
      ),
      unselectedIconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onSurface,
        size: 25,
      ),
      selectedLabelTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w400,
      ),
      destinations: [
        for (final destination in ResponsiveAppShell._destinations)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.label.tr),
          ),
      ],
      onDestinationSelected: _navigateTo,
    );
  }
}

class _CompactNavigationBar extends StatelessWidget {
  const _CompactNavigationBar({
    required this.selectedIndex,
    required this.isSmall,
  });

  final int? selectedIndex;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        key: const ValueKey('responsive-navigation-bar'),
        height: isSmall ? 64 : 72,
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 6 : 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            for (
              var index = 0;
              index < ResponsiveAppShell._destinations.length;
              index++
            )
              Expanded(
                child: _CompactNavigationItem(
                  destination: ResponsiveAppShell._destinations[index],
                  selected: index == selectedIndex,
                  isSmall: isSmall,
                  onTap: () => _navigateTo(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompactNavigationItem extends StatelessWidget {
  const _CompactNavigationItem({
    required this.destination,
    required this.selected,
    required this.isSmall,
    required this.onTap,
  });

  final _AppDestination destination;
  final bool selected;
  final bool isSmall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxPillWidth = isSmall ? 64.0 : 72.0;
        final pillWidth = (constraints.maxWidth - 4)
            .clamp(0.0, maxPillWidth)
            .toDouble();
        final icon = Icon(
          selected ? destination.selectedIcon : destination.icon,
          size: 24,
          color: selected
              ? Theme.of(context).colorScheme.onSurface
              : AppColors.mutedGray,
        );

        return Semantics(
          button: true,
          selected: selected,
          label: destination.label.tr,
          child: Tooltip(
            message: destination.label.tr,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      width: pillWidth,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFFFF0EC)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: icon,
                    ),
                    if (!isSmall) ...[
                      const SizedBox(height: 2),
                      Text(
                        destination.label.tr,
                        maxLines: 1,
                        style: TextStyle(
                          color: selected
                              ? Theme.of(context).colorScheme.onSurface
                              : AppColors.mutedGray,
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void _navigateTo(int index) {
  if (index < 0 || index >= ResponsiveAppShell._destinations.length) return;
  final destination = ResponsiveAppShell._destinations[index];
  if (Get.currentRoute != destination.route) {
    Get.offNamed(destination.route);
  }
}

class _AppDestination {
  const _AppDestination({
    required this.label,
    required this.route,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String route;
  final IconData icon;
  final IconData selectedIcon;
}
