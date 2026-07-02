import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/features/tours/widgets/tour_card.dart';
import 'package:expense_tracker/features/tours/widgets/create_tour_sheet.dart';
import 'package:expense_tracker/features/tours/pages/tour_dashboard_screen.dart';
import 'package:expense_tracker/core/providers/session_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/profile_manager_provider.dart';
import 'package:expense_tracker/features/dashboard/pages/select_profile_screen.dart';
import 'package:expense_tracker/features/tours/pages/tour_member_management_screen.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({super.key});

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  final Map<String, int> _memberCounts = {};
  final Map<String, double> _totalSpent = {};
  int _currentCarouselIndex = 0;
  int _completedToursCount = 0;
  String? _lastProfileId;

  ImageProvider? _resolveImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http')) return NetworkImage(photoUrl);
    if (File(photoUrl).existsSync()) return FileImage(File(photoUrl));
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCounts());
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
        _totalSpent[row['tourId'] as String] =
            (row['total'] as num).toDouble();
      }

      final settlementResult = await db.rawQuery(
        'SELECT tourId, COUNT(*) as cnt FROM tour_settlements '
        'WHERE tourId IN ($placeholders) AND isDeleted = 0 GROUP BY tourId',
        tourIds,
      );
      final settledTourIds =
          settlementResult.map((r) => r['tourId'] as String).toSet();
      _completedToursCount = tourIds.where((id) =>
          (_totalSpent[id] ?? 0) > 0 && settledTourIds.contains(id)).length;
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
    final theme = Theme.of(context);
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

    final photoUrl = currentProfile.id == 'default_profile' ? session.photoUrl : null;
    final initials = currentProfile.id == 'default_profile'
        ? session.initials
        : (currentProfile.name.isNotEmpty ? currentProfile.name.substring(0, 1).toUpperCase() : 'P');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.p20, AppSpacing.p16, AppSpacing.p20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.activeGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'WHERE TO NEXT?',
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppColors.activeGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s6),
                        Text(
                          'Your Tours',
                          style: AppTextStyles.sectionHeaderTitle.copyWith(
                            fontSize: 32,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      ProfileSwitchSheet.show(
                        context: context,
                        currentProfileId: currentProfile.id,
                        profiles: profileProvider.profiles,
                        onProfileSelected: (selectedProfile) {
                          profileProvider.selectProfile(selectedProfile);
                          context.read<ProfileManagerProvider>().switchProfile(
                            selectedProfile.id,
                          );
                        },
                        onCreateNewTap: () async {
                          final newProfile = await Navigator.push<UserProfile>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelectProfileScreen(),
                            ),
                          );
                          if (newProfile != null && context.mounted) {
                            context.read<ProfileManagerProvider>().switchProfile(
                              newProfile.id,
                            );
                          }
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      backgroundImage: _resolveImage(photoUrl),
                      child: _resolveImage(photoUrl) == null
                          ? Text(
                              initials,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: GoogleFonts.workSans().fontFamily,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Expanded(
              child: tours.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildTourCarousel(theme, tours),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppImages.tour,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.explore_rounded,
                  size: 150,
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.3)
                      : AppColors.activeGreen,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your journey starts here',
                style: AppTextStyles.sectionHeaderTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Create a tour to split group expenses\nseamlessly with your travel buddies.',
                textAlign: TextAlign.center,
                style: AppTextStyles.dialogBody.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _openCreateTourSheet,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Create your first tour'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.activeGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTourCarousel(ThemeData theme, List<Tour> tours) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TourProvider>().clearSelection();
        await _loadCounts();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '${tours.length} ${tours.length == 1 ? 'ACTIVE TOUR' : 'ACTIVE TOURS'}',
                  style: AppTextStyles.reportStatLabel.copyWith(
                    letterSpacing: 1.5,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              CarouselSlider.builder(
                itemCount: tours.length,
                options: CarouselOptions(
                  scrollDirection: Axis.horizontal,
                  height: MediaQuery.of(context).size.height * 0.30,
                  enlargeCenterPage: true,
                  viewportFraction: 0.80,
                  enableInfiniteScroll: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  onPageChanged: (index, reason) {
                    setState(() => _currentCarouselIndex = index);
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  final tour = tours[index];
                  return TourCard(
                    tour: tour,
                    memberCount: _memberCounts[tour.id] ?? 0,
                    totalSpent: _totalSpent[tour.id] ?? 0,
                    index: index,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => TourDashboardScreen(tourId: tour.id),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                              FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: tours.asMap().entries.map((entry) {
                  final i = entry.key;
                  final isActive = i == _currentCarouselIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.activeGreen
                          : AppColors.activeGreen.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.s24),
              _buildJourneySection(theme, tours),
              const SizedBox(height: AppSpacing.s16),
              _buildPlanBanner(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJourneySection(ThemeData theme, List<Tour> tours) {
    final isDark = theme.brightness == Brightness.dark;
    final totalBuddies = tours.fold<int>(
      0,
      (sum, t) => sum + (_memberCounts[t.id] ?? 0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Journey', style: AppTextStyles.sectionHeaderTitle),
          const SizedBox(height: AppSpacing.s14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.p20, horizontal: AppSpacing.p24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: isDark ? 0.15 : 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.activeGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.map_outlined, size: 22, color: AppColors.activeGreen),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Tours Completed',
                                style: AppTextStyles.reportStatLabel.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              '$_completedToursCount',
                              style: GoogleFonts.workSans(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.activeGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                  child: Container(
                    width: 1,
                    height: 48,
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Active Buddies',
                                style: AppTextStyles.reportStatLabel.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              '$totalBuddies',
                              style: GoogleFonts.workSans(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.activeGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.activeGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.people_outline, size: 22, color: AppColors.activeGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanBanner(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    theme.cardColor,
                    theme.cardColor.withValues(alpha: 0.8),
                  ]
                : [
                    AppColors.activeGreen.withValues(alpha: 0.08),
                    AppColors.activeGreen.withValues(alpha: 0.03),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: isDark ? 0.15 : 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openCreateTourSheet,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.p16, horizontal: AppSpacing.p20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.activeGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.flight_takeoff, size: 22, color: AppColors.activeGreen),
                    ),
                    const SizedBox(width: AppSpacing.s14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plan your next adventure',
                            style: GoogleFonts.workSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s2),
                          Text(
                            'Start tracking expenses for your new trip.',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.activeGreen),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
