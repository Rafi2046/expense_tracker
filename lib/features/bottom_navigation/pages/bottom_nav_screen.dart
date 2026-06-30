import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/features/analytics/pages/analytics_screen.dart';
import 'package:expense_tracker/features/bottom_navigation/widgets/exit_dialog.dart';
import 'package:expense_tracker/features/dashboard/pages/dashboard_screen.dart';
import 'package:expense_tracker/features/ledger/pages/ledger_screen.dart';
import 'package:expense_tracker/features/settings/pages/settings_screen.dart';
import 'package:expense_tracker/features/tours/pages/tour_list_screen.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TourListScreen(),
    LedgerScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  final List<NavItem> _navItems = const [
    NavItem(title: 'Home', icon: AppImages.homeIcon),
    NavItem(title: 'Tours', icon: null, iconData: Symbols.groups),
    NavItem(title: 'Ledger', icon: AppImages.ledgerIcon),
    NavItem(title: 'Analytics', icon: AppImages.analyticsIcon),
    NavItem(title: 'Settings', icon: AppImages.settingsIcon),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => const ExitDialog(),
          );
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),

        bottomNavigationBar: Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 10,
            top: 6,
          ),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF1F1F1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                _navItems.length,
                (index) => _buildNavItem(
                  item: _navItems[index],
                  index: index,
                  isSelected: _currentIndex == index,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required NavItem item,
    required int index,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Theme.of(context).primaryColor;
    final inactiveColor = isDark ? Colors.white54 : const Color(0xFF31394D);
    final indicatorColor = Theme.of(context).primaryColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          child: Container(
            height: double.infinity,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  // Top active indicator bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3,
                    width: 18,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 3),
                ],

                item.iconData != null
                    ? Icon(
                        item.iconData,
                        size: 22,
                        color: isSelected ? activeColor : inactiveColor,
                      )
                    : Image.asset(
                        item.icon!,
                        width: 22,
                        height: 22,
                        color: isSelected ? activeColor : inactiveColor,
                      ),

                if (isSelected) ...[
                  const SizedBox(height: 2),
                  Text(
                    context.translate(item.title.toLowerCase()),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                      fontWeight: FontWeight.w600,
                      color: activeColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final String title;
  final String? icon;
  final IconData? iconData;

  const NavItem({required this.title, this.icon, this.iconData});
}
