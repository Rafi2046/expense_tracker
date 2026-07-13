import 'package:expense_tracker/features/transactions/pages/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/features/bottom_navigation/widgets/exit_dialog.dart';
import 'package:expense_tracker/features/dashboard/pages/dashboard_screen.dart';
import 'package:expense_tracker/features/settings/pages/settings_screen.dart';
import 'package:expense_tracker/features/tours/pages/tour_list_screen.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    TourListScreen(),
    SettingsScreen(),
  ];

  final List<NavItem> _navItems = const [
    NavItem(title: 'Home', iconData: LucideIcons.home),
    NavItem(title: 'Transactions', iconData: LucideIcons.badgeDollarSign),
    NavItem(title: 'Tours', iconData: LucideIcons.users),
    NavItem(title: 'Settings', iconData: LucideIcons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final currentNavigatorState =
            _navigatorKeys[_currentIndex].currentState;
        if (currentNavigatorState != null && currentNavigatorState.canPop()) {
          currentNavigatorState.pop();
        } else if (_currentIndex != 0) {
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
          children: List.generate(
            _screens.length,
            (index) => Navigator(
              key: _navigatorKeys[index],
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(builder: (context) => _screens[index]);
              },
            ),
          ),
        ),

        bottomNavigationBar: Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 10,
            top: 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        Theme.of(context).dividerTheme.color ??
                        const Color(0xFFF1F1F1),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.2
                            : 0.05,
                      ),
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
            ],
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
    final activeColor = Theme.of(context).primaryColor;
    final inactiveColor = Colors.grey.shade400;
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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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

                  Icon(
                    item.iconData,
                    size: 20,
                    color: isSelected ? activeColor : inactiveColor,
                  ),

                  if (isSelected) ...[
                    const SizedBox(height: 2),
                    Text(
                      context.translate(item.title.toLowerCase()),
                      style: AppTextStyles.caption.copyWith(
                        fontSize: AppFontSizes.size10,
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
      ),
    );
  }
}

class NavItem {
  final String title;
  final IconData iconData;

  const NavItem({required this.title, required this.iconData});
}
