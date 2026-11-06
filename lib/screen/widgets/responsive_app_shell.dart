import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponsiveAppShell extends StatelessWidget {
  const ResponsiveAppShell({
    super.key,
    required this.selectedIndex,
    required this.child,
  });

  final int? selectedIndex;
  final Widget child;

  // ======================================================
  // NAVIGATION DESTINATIONS
  // ======================================================

  static const List<_AppDestination> _destinations = [
    _AppDestination(
      label: 'Home',
      route: '/home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _AppDestination(
      label: 'Manage',
      route: '/manage',
      icon: Icons.work_outline_rounded,
      selectedIcon: Icons.work_rounded,
    ),
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

  // ======================================================
  // ROUTE INDEX
  // ======================================================

  static int? _destinationIndexForRoute(String route) {
    final path = Uri.tryParse(route)?.path ?? route;

    bool matchesAny(List<String> routes) {
      return routes.any(
        (candidate) => path == candidate || path.startsWith('$candidate/'),
      );
    }

    // Home
    if (matchesAny(['/home', '/dashboard'])) {
      return 0;
    }

    // Manage: Wedding, Guest, Gift, Gallery
    if (matchesAny([
      '/manage',
      '/wedding',
      '/wedding-detail',
      '/guest',
      '/guest-detail',
      '/gift',
      '/gift-detail',
      '/gallery',
    ])) {
      return 1;
    }

    // Report
    if (matchesAny(['/report'])) {
      return 2;
    }

    // Profile and Settings
    if (matchesAny(['/profile', '/setting'])) {
      return 3;
    }

    return null;
  }

  // ======================================================
  // MAIN RESPONSIVE LAYOUT
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final routeIndex = _destinationIndexForRoute(Get.currentRoute);

        final requestedIndex = selectedIndex;

        final validFallback =
            requestedIndex != null &&
                requestedIndex >= 0 &&
                requestedIndex < _destinations.length
            ? requestedIndex
            : null;

        final activeIndex = routeIndex ?? validFallback;

        // Desktop
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

        // Mobile and Tablet
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

// ======================================================
// DESKTOP SIDEBAR
// ======================================================

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

      groupAlignment: -0.85,

      backgroundColor: Colors.white,

      indicatorColor: const Color(0xFFFFF0EC),

      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),

      selectedIconTheme: const IconThemeData(
        color: Color(0xFF351D17),
        size: 25,
      ),

      unselectedIconTheme: const IconThemeData(
        color: Color(0xFF351D17),
        size: 25,
      ),

      selectedLabelTextStyle: const TextStyle(
        color: Color(0xFF351D17),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),

      unselectedLabelTextStyle: const TextStyle(
        color: Color(0xFF351D17),
        fontSize: 13,
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

// ======================================================
// MOBILE / TABLET NAVIGATION
// ======================================================

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

// ======================================================
// COMPACT NAVIGATION ITEM
// ======================================================

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
        final pillWidth = (constraints.maxWidth - 4)
            .clamp(0.0, isSmall ? 64.0 : 72.0)
            .toDouble();

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
                      duration: const Duration(milliseconds: 180),
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
                      child: Icon(
                        selected ? destination.selectedIcon : destination.icon,
                        size: 24,
                        color: const Color(0xFF351D17),
                      ),
                    ),

                    if (!isSmall) ...[
                      const SizedBox(height: 2),
                      Text(
                        destination.label.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF351D17),
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

// ======================================================
// NAVIGATION ACTION
// ======================================================

void _navigateTo(int index) {
  if (index < 0 || index >= ResponsiveAppShell._destinations.length) {
    return;
  }

  final currentIndex = ResponsiveAppShell._destinationIndexForRoute(
    Get.currentRoute,
  );

  if (currentIndex == index) {
    return;
  }

  final destination = ResponsiveAppShell._destinations[index];

  if (Get.currentRoute != destination.route) {
    Get.offNamed(destination.route);
  }
}

// ======================================================
// DESTINATION MODEL
// ======================================================

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
