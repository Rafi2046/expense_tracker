import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:expense_tracker/features/tours/widgets/join_tour_sheet.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/widgets/tour_create_button.dart';
import 'package:expense_tracker/features/tours/widgets/delete_tour_dialog.dart';
import 'package:expense_tracker/features/tours/widgets/complete_tour_dialog.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({super.key});

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  final Map<String, int> _memberCounts = {};

  Future<void> _confirmDeleteTour(BuildContext context, Tour tour) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = tour.ownerUid == null || currentUid == null || tour.ownerUid == currentUid;

    final confirmed = await showDeleteTourDialog(
      context,
      tour.name,
      isOwner: isOwner,
    );
    if (confirmed && context.mounted) {
      context.read<TourProvider>().deleteTour(tour.id);
    }
  }

  Future<void> _toggleCompleteTour(Tour tour) async {
    final confirmed = await showCompleteTourDialog(
      context,
      tour.name,
      tour.isCompleted,
    );
    if (!confirmed) return;
    if (!mounted) return;
    final success = await context.read<TourProvider>().toggleTourCompletion(
      tour.id,
      !tour.isCompleted,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('only_creator_mark_completion')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  final Map<String, double> _totalSpent = {};
  int _currentPageIndex = 0;
  String? _lastProfileId;
  int _lastTourHash = 0;
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
            content: Text(msg),
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

  void _openEditTourSheet(Tour tour) {
    CreateTourSheet.show(
      context: context,
      tour: tour,
      onTourCreated: (_) {},
    );
  }

  void _showCreateJoinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(context);
        final bottomInset = MediaQuery.of(context).padding.bottom;
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(0, 16, 0, bottomInset + 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.activeGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.plusCircle,
                      color: AppColors.activeGreen, size: 24),
                ),
                title: Text(
                  context.translate('create_new_tour'),
                  style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _openCreateTourSheet();
                },
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.activeGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.qrCode,
                      color: AppColors.activeGreen, size: 24),
                ),
                title: Text(
                  context.translate('join_invite_code'),
                  style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const JoinTourSheet(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showViewAllDialog() {
    final tours = context.read<TourProvider>().tours;
    final names = tours.map((t) => t.name).toList();
    if (names.isEmpty) return;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${context.translate('all_tours')} (${names.length})',
          style: AppTextStyles.dialogTitle.copyWith(color: theme.colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: names.map((n) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(n,
                style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface)),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text(context.translate('close'), style: AppTextStyles.viewAllText),
          ),
        ],
      ),
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
    final currentHash = Object.hashAll(provider.tours.map((t) => t.id));
    if (_lastProfileId != activeProfileId || _lastTourHash != currentHash) {
      _lastProfileId = activeProfileId;
      _lastTourHash = currentHash;
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: tours.isNotEmpty
          ? TourCreateButton(onPressed: _showCreateJoinSheet)
          : null,
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
              onViewAll: _showViewAllDialog,
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
                        final currentUid = FirebaseAuth.instance.currentUser?.uid;
                        final isOwner = (tour.ownerUid == null && tour.inviteCode == null) || (currentUid != null && tour.ownerUid != null && tour.ownerUid == currentUid);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: TourCard(
                            tour: tour,
                            memberCount: _memberCounts[tour.id] ?? 0,
                            totalSpent: _totalSpent[tour.id] ?? 0,
                            index: index,
                            isOwner: isOwner,
                            onEdit: () => _openEditTourSheet(tour),
                            onDelete: () => _confirmDeleteTour(context, tour),
                            onToggleComplete: isOwner ? () => _toggleCompleteTour(tour) : null,
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