import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/pages/tour_dashboard_screen.dart';

class JoinRequestWaitingScreen extends StatefulWidget {
  final Tour tour;
  final String uid;

  const JoinRequestWaitingScreen({
    super.key,
    required this.tour,
    required this.uid,
  });

  @override
  State<JoinRequestWaitingScreen> createState() => _JoinRequestWaitingScreenState();
}

class _JoinRequestWaitingScreenState extends State<JoinRequestWaitingScreen> {
  StreamSubscription<DocumentSnapshot>? _subscription;
  String _requestStatus = 'pending';
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _listenToRequestStatus();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _listenToRequestStatus() {
    final docRef = FirebaseFirestore.instance
        .collection('shared_tours')
        .doc(widget.tour.id)
        .collection('join_requests')
        .doc(widget.uid);

    _subscription = docRef.snapshots().listen((snapshot) async {
      if (!snapshot.exists || _isTransitioning) return;

      final data = snapshot.data();
      if (data == null) return;

      final status = data['status'] as String? ?? 'pending';

      if (mounted) {
        setState(() {
          _requestStatus = status;
        });
      }

      if (status == 'approved') {
        _isTransitioning = true;
        _subscription?.cancel();
        _handleApproved();
      }
    }, onError: (error) {
      debugPrint('JoinRequestWaitingScreen stream error: $error');
    });
  }

  Future<void> _handleApproved() async {
    final provider = context.read<TourProvider>();
    await provider.completeJoinAfterApproval(widget.tour);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('join_approved_snackbar', namedArgs: {'name': widget.tour.name})),
          backgroundColor: AppColors.activeGreen,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TourDashboardScreen(tourId: widget.tour.id),
        ),
      );
    }
  }

  Future<void> _cancelRequest() async {
    try {
      _subscription?.cancel();
      await FirebaseFirestore.instance
          .collection('shared_tours')
          .doc(widget.tour.id)
          .collection('join_requests')
          .doc(widget.uid)
          .delete();
    } catch (e) {
      debugPrint('Error deleting join request: $e');
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: _requestStatus == 'rejected',
      child: Scaffold(
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p24,
              vertical: AppSpacing.p16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated Visual Icon Indicator
                if (_requestStatus == 'pending') ...[
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : AppColors.containerColorGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        LucideIcons.compass,
                        size: 64,
                        color: theme.primaryColor,
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .rotate(duration: 3.seconds)
                          .scaleXY(
                            begin: 0.95,
                            end: 1.05,
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          ),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .shimmer(duration: 2.seconds, color: Colors.white24),
                ] else if (_requestStatus == 'rejected') ...[
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : AppColors.containerColorGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        LucideIcons.shieldAlert,
                        size: 64,
                        color: AppColors.activeRed,
                      )
                          .animate()
                          .scale(duration: 800.ms, curve: Curves.bounceOut)
                          .shake(duration: 500.ms, curve: Curves.easeInOut),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.h32),

                // Request Status Title
                Text(
                  _requestStatus == 'pending'
                      ? context.translate('waiting_for_host_approval_title')
                      : (_requestStatus == 'approved' ? context.translate('join_request_approved_title') : context.translate('declined_title')),
                  style: AppTextStyles.h1.copyWith(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.h12),

                // Request Details text
                Text(
                  _requestStatus == 'pending'
                      ? context.translate('pending_approval_desc')
                      : (_requestStatus == 'approved' ? context.translate('approved_desc') : context.translate('declined_desc')),
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.h24),

                // Tour Target Info Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p16,
                    vertical: AppSpacing.p12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.containerColorGrey,
                    borderRadius: BorderRadius.circular(AppSpacing.br10),
                    border: Border.all(
                      color: isDark ? Colors.white10 : AppColors.dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.translate('tour_name_label_in_dialog'),
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.h4),
                      Text(
                        widget.tour.name,
                        style: AppTextStyles.bodyBold.copyWith(
                          color: isDark ? theme.colorScheme.primary : theme.primaryColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Action Buttons
                if (_requestStatus == 'pending') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _cancelRequest,
                      icon: const Icon(LucideIcons.x, size: 16),
                      label: Text(
                        context.translate('cancel_request'),
                        style: AppTextStyles.bodyBold.copyWith(
                          fontSize: 14,
                          color: AppColors.activeRed,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.activeRed,
                        side: const BorderSide(color: AppColors.activeRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ] else if (_requestStatus == 'rejected') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        context.translate('close'),
                        style: AppTextStyles.reportTileTitle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
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
