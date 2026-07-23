import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/tours/pages/join_request_waiting_screen.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

class JoinTourSheet extends StatefulWidget {
  const JoinTourSheet({super.key});

  @override
  State<JoinTourSheet> createState() => _JoinTourSheetState();
}

class _JoinTourSheetState extends State<JoinTourSheet> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim();
    if (code.length != 6) return;

    setState(() => _isLoading = true);

    try {
      final tour =
          await context.read<TourProvider>().requestToJoinTourByCode(code.toUpperCase());
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in.');
      
      if (!mounted) return;
      Navigator.pop(context);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JoinRequestWaitingScreen(
            tour: tour,
            uid: currentUser.uid,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.r16),
            topRight: Radius.circular(AppSpacing.r16),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.p24, AppSpacing.p24, AppSpacing.p24, bottomPadding + AppSpacing.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: AppSpacing.h4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.r8),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                context.translate('join_invite_code'),
                style: AppTextStyles.h2.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                context.translate('join_tour_subtitle'),
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              TextField(
                controller: _codeController,
                enabled: !_isLoading,
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  UpperCaseTextFormatter(),
                ],
                style: AppTextStyles.displayLarge.copyWith(
                  fontFamily: 'JetBrainsMono',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: context.translate('enter_code_hint'),
                  hintStyle: AppTextStyles.bodyBold.copyWith(
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.r16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.r16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.r16),
                    borderSide: const BorderSide(
                      color: AppColors.activeGreen,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p16,
                    vertical: AppSpacing.p16,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.s16),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.authFieldHeight,
                child: ElevatedButton(
                  onPressed:
                      _codeController.text.trim().length == 6 && !_isLoading
                          ? _handleJoin
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.activeGreen.withValues(alpha: 0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.r16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: AppSpacing.s24,
                          height: AppSpacing.s24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.translate('join_tour_btn'),
                          style: AppTextStyles.reportTileTitle.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
