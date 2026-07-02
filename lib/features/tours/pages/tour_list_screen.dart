import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/features/tours/widgets/tour_card.dart';
import 'package:expense_tracker/features/tours/pages/tour_dashboard_screen.dart';
import 'package:expense_tracker/features/tours/pages/tour_member_management_screen.dart';

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
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    String selectedCurrency = 'BDT';
    String? coverPhotoPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('New Tour', style: AppTextStyles.dialogTitle),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Tour Name',
                    hintText: 'e.g. Bali Trip 2026',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: AppTextStyles.partyFormInput.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCurrency,
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  dropdownColor: theme.colorScheme.surface,
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
                    DropdownMenuItem(value: 'BDT', child: Text('৳ BDT')),
                    DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
                    DropdownMenuItem(value: 'GBP', child: Text('£ GBP')),
                    DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
                    DropdownMenuItem(value: 'JPY', child: Text('¥ JPY')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setSheetState(() => selectedCurrency = v);
                    }
                  },
                  style: AppTextStyles.partyFormInput.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final source = await showModalBottomSheet<ImageSource>(
                      context: ctx,
                      backgroundColor: Colors.transparent,
                      builder: (sCtx) => Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 36, height: 4, decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
                            const SizedBox(height: 20),
                            const Text('Cover Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 20),
                            ListTile(
                              leading: const Icon(Icons.camera_alt_rounded),
                              title: const Text('Take Photo'),
                              onTap: () => Navigator.pop(sCtx, ImageSource.camera),
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library_rounded),
                              title: const Text('Choose from Gallery'),
                              onTap: () => Navigator.pop(sCtx, ImageSource.gallery),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (source != null) {
                      final picked = await ImagePicker().pickImage(source: source, maxWidth: 1200, imageQuality: 85);
                      if (picked != null) {
                        setSheetState(() => coverPhotoPath = picked.path);
                      }
                    }
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: coverPhotoPath != null
                          ? null
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                        style: BorderStyle.solid,
                      ),
                      image: coverPhotoPath != null
                          ? DecorationImage(image: FileImage(File(coverPhotoPath!)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: coverPhotoPath == null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 22),
                              const SizedBox(width: 8),
                              Text('Add cover photo', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 14)),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final tour = Tour(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      name: name,
                      coverPhoto: coverPhotoPath,
                      currency: selectedCurrency,
                      createdAt: DateTime.now(),
                      profileId: context.read<TourProvider>().activeProfileId,
                    );
                    final navigator = Navigator.of(ctx);
                    context.read<TourProvider>().createTour(tour).then((_) {
                      navigator.pop();
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
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.activeGreen,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Create Tour', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TourProvider>();
    final tours = provider.tours;

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
                        Text(
                          'Where to next?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s2),
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
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(Icons.person, size: 24, color: Colors.grey.shade500),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
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
            const SizedBox(height: 28),
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
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _openCreateTourSheet,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create your first tour'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.activeGreen,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ],
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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.map_outlined, size: 26, color: AppColors.activeGreen),
                      const SizedBox(width: AppSpacing.s8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Tours Completed', style: AppTextStyles.reportStatLabel.copyWith(color: AppColors.textMuted)),
                            ),
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              '$_completedToursCount',
                              style: AppTextStyles.cardValueGreen.copyWith(fontSize: 26),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: AppColors.dividerColor.withValues(alpha: 0.3),
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
                              child: Text('Active Buddies', style: AppTextStyles.reportStatLabel.copyWith(color: AppColors.textMuted)),
                            ),
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              '$totalBuddies',
                              style: AppTextStyles.cardValueGreen.copyWith(fontSize: 26),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Icon(Icons.people_outline, size: 26, color: AppColors.activeGreen),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
      child: GestureDetector(
        onTap: _openCreateTourSheet,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.p16, horizontal: AppSpacing.p20),
          decoration: BoxDecoration(
            color: AppColors.activeGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.activeGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.flight_takeoff, size: 22, color: AppColors.buttonColor),
              ),
              const SizedBox(width: AppSpacing.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan your next adventure',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      'Start tracking expenses for your new trip.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.buttonColor),
            ],
          ),
        ),
      ),
    );
  }
}
