import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
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
    } catch (e) {
      debugPrint('TourListScreen._loadCounts error: $e');
    }
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
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Tours', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, fontFamily: 'WorkSans')),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: FloatingActionButton(
          heroTag: 'tour_list_fab',
          onPressed: _openCreateTourSheet,
          backgroundColor: AppColors.activeGreen,
          elevation: 4,
          child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
        ),
      ),
      body: tours.isEmpty
          ? _buildEmptyState(theme)
          : _buildTourGrid(theme, tours),
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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.white.withValues(alpha: 0.05)
                    : const Color(0xFF2EBD85).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.explore_rounded,
                size: 44,
                color: isDark
                    ? AppColors.white.withValues(alpha: 0.3)
                    : AppColors.activeGreen,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Your journey starts here',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                fontFamily: 'WorkSans',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Create a tour to split group expenses\nseamlessly with your travel buddies.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
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

  Widget _buildTourGrid(ThemeData theme, List<Tour> tours) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TourProvider>().clearSelection();
        await _loadCounts();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        child: CustomScrollView(
          slivers: [
            SliverLayoutBuilder(
              builder: (context, constraints) {
                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      '${tours.length} ${tours.length == 1 ? 'Tour' : 'Tours'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
                childCount: tours.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
