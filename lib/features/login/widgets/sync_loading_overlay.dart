import 'dart:async';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/profile_manager_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/services/sync_service.dart';
import 'package:expense_tracker/features/bottom_navigation/pages/bottom_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

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
  String _statusText = 'Restoring your data…';
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  Future<void> _startSync() async {
    widget.syncService.progress.listen((progress) {
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

    await widget.syncService.sync(widget.uid);

    if (!mounted || _hasError) return;

    await context.read<ProfileProvider>().reload();
    if (!mounted) return;
    final pm = context.read<ProfileManagerProvider>();
    await pm.switchProfile(pm.activeProfileId);

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
      _statusText = 'Restoring your data…';
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
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_hasError)
                  Icon(Icons.cloud_sync, size: 80, color: Colors.greenAccent)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: Colors.white)
                    .scaleXY(end: 1.1, duration: 600.ms)
                    .then()
                    .scaleXY(end: 1.0 / 1.1)
                else
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 64,
                    color: const Color(0xFFE53935),
                  ),
                const SizedBox(height: 24),
                Text(
                  _hasError ? 'Sync Failed' : 'Restoring Your Data',
                  style: AppTextStyles.h1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _hasError
                      ? _errorMessage ?? 'An unexpected error occurred.'
                      : _statusText,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    fontFamily: GoogleFonts.workSans().fontFamily,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                if (_hasError) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _skip,
                          child: const Text('Skip'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _retry,
                          child: const Text('Retry'),
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
    widget.syncService.dispose();
    super.dispose();
  }
}
