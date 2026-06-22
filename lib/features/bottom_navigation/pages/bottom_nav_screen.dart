import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/features/analytics/pages/analytics_screen.dart';
import 'package:expense_tracker/features/bottom_navigation/widgets/exit_dialog.dart';
import 'package:expense_tracker/features/dashboard/pages/dashboard_screen.dart';
import 'package:expense_tracker/features/ledger/pages/ledger_screen.dart';
import 'package:expense_tracker/features/settings/pages/settings_screen.dart';
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
    LedgerScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  final List<NavItem> _navItems = const [
    NavItem(title: 'Home', icon: AppImages.homeIcon),
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
        backgroundColor: const Color(0xFFF8F9FA),
        body: _screens[_currentIndex],

        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFBBCABF), width: 2)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
      ),
    );
  }

  Widget _buildNavItem({
    required NavItem item,
    required int index,
    required bool isSelected,
  }) {
    const activeColor = Color(0xFF006C49);
    const inactiveColor = Color(0xFF31394D);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(height: 2, width: 24, color: activeColor),
            ),
            const SizedBox(height: 6),

            Image.asset(
              item.icon,
              width: 24,
              height: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),

            Text(
              context.translate(item.title.toLowerCase()),
              style: TextStyle(
                fontSize: 12,
                fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final String title;
  final String icon;

  const NavItem({required this.title, required this.icon});
}
