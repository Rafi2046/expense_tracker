import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/features/tours/widgets/tour_card.dart';
import 'package:expense_tracker/features/tours/widgets/create_tour_sheet.dart';
import 'package:expense_tracker/features/tours/pages/tour_dashboard_screen.dart';
import 'package:expense_tracker/core/providers/session_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/features/tours/pages/tour_member_management_screen.dart';
import 'package:expense_tracker/features/tours/widgets/tour_list_header.dart';
import 'package:expense_tracker/features/tours/widgets/tour_list_empty_state.dart';
import 'package:expense_tracker/features/tours/widgets/quick_action_hub.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({super.key});

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  final Map<String, int> _memberCounts = {};

  void _confirmDeleteTour(BuildContext context, Tour tour) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: const Text('Delete Tour',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TourProvider>().deleteTour(tour.id);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCompleteTour(Tour tour) async {
    final success = await context.read<TourProvider>().toggleTourCompletion(
      tour.id,
      !tour.isCompleted,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only the tour creator can mark completion status'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  final Map<String, double> _totalSpent = {};
  int _currentPageIndex = 0;
  String? _lastProfileId;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCounts();
      TourProvider.onNotification = (msg) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$msg'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      };
    });
  }

  @override
  void dispose() {
    TourProvider.onNotification = null;
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCounts() async {
    final provider = context.read<TourProvider>();
    final tourIds = provider.tours.map((t) => t.id).toList();
    if (tourIds.isEmpty) return;

    try {
      final db = await DatabaseHelper.instance.database;
      final placeholders = tourIds.map((_) => '?').join(',');

      final memberResult = await db.rawQuery(
        'SELECT tourId, COUNT(*) as cnt FROM tour_participants '
            'WHERE tourId IN ($placeholders) AND isDeleted = 0 GROUP BY tourId',
        tourIds,
      );
      for (final row in memberResult) {
        _memberCounts[row['tourId'] as String] = row['cnt'] as int;
      }

      final spentResult = await db.rawQuery(
        'SELECT tourId, COALESCE(SUM(amount), 0) as total FROM tour_expenses '
            'WHERE tourId IN ($placeholders) AND isDeleted = 0 GROUP BY tourId',
        tourIds,
      );
      for (final row in spentResult) {
        _totalSpent[row['tourId'] as String] = (row['total'] as num).toDouble();
      }
    } catch (e) {
      debugPrint('TourListScreen._loadCounts error: $e');
    }
    if (mounted) setState(() {});
  }

  void _openCreateTourSheet() {
    CreateTourSheet.show(
      context: context,
      onTourCreated: (tour) {
        context.read<TourProvider>().createTour(tour).then((_) {
          if (mounted) {
            _loadCounts();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TourMemberManagementScreen(
                  tourId: tour.id,
                  isInitialSetup: true,
                ),
              ),
            ).then((_) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TourDashboardScreen(tourId: tour.id),
                  ),
                );
              }
            });
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TourProvider>();
    final tours = provider.tours;

    final profileProvider = context.watch<ProfileProvider>();
    final currentProfile = profileProvider.currentProfile;
    final session = context.watch<SessionProvider>();

    final activeProfileId = provider.activeProfileId;
    if (_lastProfileId != activeProfileId) {
      _lastProfileId = activeProfileId;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadCounts());
    }

    final photoUrl = currentProfile.id == 'default_profile'
        ? session.photoUrl
        : null;
    final initials = currentProfile.id == 'default_profile'
        ? session.initials
        : (currentProfile.name.isNotEmpty
        ? currentProfile.name.substring(0, 1).toUpperCase()
        : 'P');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TourListHeader(
              currentProfile: currentProfile,
              photoUrl: photoUrl,
              initials: initials,
              totalTours: tours.length,
              totalBuddies: tours.fold<int>(0, (sum, t) => sum + (_memberCounts[t.id] ?? 0)),
            ),
            const SizedBox(height: AppSpacing.s12),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<TourProvider>().refreshTours();
                  await _loadCounts();
                },
                child: tours.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: TourListEmptyState(onCreateTour: _openCreateTourSheet),
                        ),
                      )
                    : _buildTourListContent(Theme.of(context), tours),
              ),
            ),
            QuickActionHub(
              onCreateNew: _openCreateTourSheet,
              onViewAll: () {
                final names = tours.map((t) => t.name).toList();
                if (names.isEmpty) return;
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'All Tours (${names.length})',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: names.map((n) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(n, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      )).toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close', style: TextStyle(color: AppColors.activeGreen)),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTourListContent(ThemeData theme, List<Tour> tours) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.only(
                top: 4,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: tours.length,
                      onPageChanged: (index) {
                        setState(() => _currentPageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        final tour = tours[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: TourCard(
                            tour: tour,
                            memberCount: _memberCounts[tour.id] ?? 0,
                            totalSpent: _totalSpent[tour.id] ?? 0,
                            index: index,
                            onDelete: () => _confirmDeleteTour(context, tour),
                            onToggleComplete: () => _toggleCompleteTour(tour),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondary) =>
                                      TourDashboardScreen(tourId: tour.id),
                                  transitionsBuilder:
                                      (context, animation, secondary, child) =>
                                      FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                  transitionDuration:
                                  const Duration(milliseconds: 300),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: tours.asMap().entries.map((entry) {
                      final i = entry.key;
                      final isActive = i == _currentPageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.activeGreen
                              : AppColors.activeGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}