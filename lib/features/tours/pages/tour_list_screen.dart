import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                Text(
                  'New Tour',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    fontFamily: 'WorkSans',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Tour Name',
                    hintText: 'e.g. Bali Trip 2026',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCurrency,
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
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
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final tour = Tour(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      name: name,
                      currency: selectedCurrency,
                      createdAt: DateTime.now(),
                      profileId:
                          context.read<TourProvider>().activeProfileId,
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
                    backgroundColor: const Color(0xFF2EBD85),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Tour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
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
        title: Text(
          'Tours',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          heroTag: 'tour_list_fab',
          onPressed: _openCreateTourSheet,
          backgroundColor: const Color(0xFF2EBD85),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      body: tours.isEmpty
          ? _buildEmptyState(theme)
          : _buildTourGrid(theme, tours),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 72,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 20),
            Text(
              'No tours yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a tour to start splitting expenses\nwith your group.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
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
        await context.read<TourProvider>().selectTour('');
        await _loadCounts();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
        child: GridView.builder(
          itemCount: tours.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.78,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
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
                    pageBuilder: (context, animation, secondaryAnimation) => TourDashboardScreen(
                      tourId: tour.id,
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                    transitionDuration: const Duration(milliseconds: 250),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
