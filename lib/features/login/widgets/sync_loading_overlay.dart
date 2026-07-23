import 'dart:async';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/profile_manager_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/services/sync_service.dart';
import 'package:expense_tracker/core/models/sync_progress.dart';
import 'package:expense_tracker/features/bottom_navigation/pages/bottom_nav_screen.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class SyncLoadingOverlay extends StatefulWidget {
  final SyncService syncService;
  final String uid;

  const SyncLoadingOverlay({
    super.key,
    required this.syncService,
    required this.uid,
  });

  @override
  State<SyncLoadingOverlay> createState() => _SyncLoadingOverlayState();
}

class _SyncLoadingOverlayState extends State<SyncLoadingOverlay> {
  String _statusText = '';
  bool _hasError = false;
  String? _errorMessage;
  StreamSubscription<SyncProgress>? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  void _listenToProgress() {
    _progressSubscription?.cancel();
    _progressSubscription = widget.syncService.progress.listen((progress) {
      if (!mounted) return;
      setState(() {
        if (progress.error != null) {
          _hasError = true;
          _errorMessage = progress.error;
        } else if (progress.currentTable.isNotEmpty) {
          _statusText = progress.currentTable;
        }
      });
    });
  }

  Future<void> _startSync() async {
    _listenToProgress();

    await widget.syncService.sync(widget.uid);

    if (!mounted || _hasError) return;

    await context.read<ProfileProvider>().reload();
    if (!mounted) return;
    final pm = context.read<ProfileManagerProvider>();
    await pm.switchProfile(pm.activeProfileId);

    // Save sync success status for the user
    await SharedPrefsHelper.setBool('has_synced_for_user_${widget.uid}', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _statusText = '';
    });
    _startSync();
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomNavScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: _hasError,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_hasError)
                  Icon(LucideIcons.cloud, size: 80, color: Colors.greenAccent)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: Colors.white)
                    .scaleXY(end: 1.1, duration: 600.ms)
                    .then()
                    .scaleXY(end: 1.0 / 1.1)
                else
                  Icon(
                    LucideIcons.cloudOff,
                    size: 64,
                    color: const Color(0xFFE53935),
                  ),
                const SizedBox(height: AppSpacing.s24),
                 Text(
                  _hasError ? context.translate('sync_failed') : context.translate('sync_restoring_data'),
                  style: AppTextStyles.h1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  _hasError
                      ? _errorMessage ?? context.translate('unexpected_sync_error')
                      : (_statusText.isEmpty ? context.translate('restoring_data_status') : _statusText),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    fontFamily: GoogleFonts.workSans().fontFamily,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),
                if (_hasError) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _skip,
                          child: Text(context.translate('skip')),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _retry,
                          child: Text(context.translate('retry')),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _progressSubscription = null;
    widget.syncService.dispose();
    super.dispose();
  }
}
