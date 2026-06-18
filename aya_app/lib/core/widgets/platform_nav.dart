import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class NavItem {
  const NavItem(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Platform-adaptive bottom navigation:
/// Android → Material 3 NavigationBar (pill indicator)
/// iOS     → CupertinoTabBar (frosted background)
class PlatformNav extends StatelessWidget {
  const PlatformNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: onTap,
        activeColor: AppColors.primary,
        inactiveColor: AppColors.textMuted,
        backgroundColor: Colors.white.withOpacity(0.95),
        items: [
          for (final i in items)
            BottomNavigationBarItem(
              icon: Icon(i.icon),
              activeIcon: Icon(i.activeIcon),
              label: i.label,
            ),
        ],
      );
    }

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        height: 64,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        destinations: [
          for (final i in items)
            NavigationDestination(
              icon: Icon(i.icon, size: 22),
              selectedIcon: Icon(i.activeIcon, size: 22, color: AppColors.primary),
              label: i.label,
            ),
        ],
      ),
    );
  }
}
