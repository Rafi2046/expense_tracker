import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/app_lock_provider.dart';

class AppLockManager extends StatefulWidget {
  final Widget child;

  const AppLockManager({super.key, required this.child});

  @override
  State<AppLockManager> createState() => _AppLockManagerState();
}

class _AppLockManagerState extends State<AppLockManager> with WidgetsBindingObserver {
  bool _showBlur = false;

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
    final provider = context.read<AppLockProvider>();

    switch (state) {
      case AppLifecycleState.inactive:
        setState(() => _showBlur = true);
      case AppLifecycleState.paused:
        provider.lock();
      case AppLifecycleState.resumed:
        setState(() => _showBlur = false);
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
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
                        Icon(Icons.lock_outline_rounded, color: Colors.white, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'App Locked',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
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
