import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/providers/app_lock_provider.dart';
import 'package:expense_tracker/core/widgets/lock_screen_overlay.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppLockManager extends StatefulWidget {
  final Widget child;

  const AppLockManager({super.key, required this.child});

  @override
  State<AppLockManager> createState() => _AppLockManagerState();
}

class _AppLockManagerState extends State<AppLockManager> with WidgetsBindingObserver {
  bool _showBlur = false;
  bool _isPushingLockScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (FirebaseAuth.instance.currentUser == null) return;

    final provider = context.read<AppLockProvider>();

    switch (state) {
      case AppLifecycleState.inactive:
        setState(() => _showBlur = true);
      case AppLifecycleState.paused:
        provider.lock();
      case AppLifecycleState.resumed:
        setState(() => _showBlur = false);
        if (provider.isLocked) {
          _pushLockScreen();
        }
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _pushLockScreen() {
    if (_isPushingLockScreen) return;
    _isPushingLockScreen = true;

    Navigator.of(context, rootNavigator: true)
        .push<void>(
          MaterialPageRoute(
            builder: (_) => const LockScreenOverlay(),
            fullscreenDialog: true,
          ),
        )
        .whenComplete(() {
      _isPushingLockScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
      children: [
        widget.child,
        if (_showBlur)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.lock, color: Colors.white, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'App Locked',
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
    );
  }
}
