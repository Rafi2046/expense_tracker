import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:expense_tracker/features/dashboard/utils/profile_sheet_handler.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class EditProfileSheet extends StatefulWidget {
  final UserProfile profile;

  const EditProfileSheet({super.key, required this.profile});

  static Future<void> show(BuildContext context, UserProfile profile) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(profile: profile),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> with ProfileSheetHandler<EditProfileSheet> {
  late TextEditingController _nameController;

  @override
  TextEditingController get nameController => _nameController;

  @override
  String get profileId => widget.profile.id;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDefault = widget.profile.id == 'default_profile';
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.r24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.r24)),
        child: Container(
          color: theme.colorScheme.surface,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.p24, AppSpacing.p12, AppSpacing.p24, AppSpacing.p24 + bottom),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppSpacing.r8),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        context.translate('edit_profile'),
                        style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w800,
                          color: theme.textTheme.titleLarge?.color),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    TextField(
                      controller: _nameController,
                      style: AppTextStyles.body.copyWith(color: theme.textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        labelText: context.translate('profile_name'),
                        labelStyle: AppTextStyles.bodySmall.copyWith(color: theme.textTheme.bodySmall?.color),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.r12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.r12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.r12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2EBD85),
                            width: 2,
                          ),
                        ),
                        fillColor: theme.cardColor,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: saveName,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2EBD85),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.r12),
                          ),
                        ),
                        child: Text(
                          context.translate('save'),
                          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700,
                            color: Colors.white),
                        ),
                      ),
                    ),
                    if (!isDefault) ...[
                      const SizedBox(height: AppSpacing.s32),
                      const Divider(),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.alertTriangle,
                            color: const Color(0xFFDC3545),
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Text(
                            context.translate('danger_zone'),
                            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w800,
                              color: const Color(0xFFDC3545),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        context.translate('delete_profile_warning'),
                        style: AppTextStyles.label.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: confirmDelete,
                          icon: Icon(LucideIcons.trash, color: Color(0xFFDC3545)),
                          label: Text(
                            context.translate('delete_profile'),
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600,
                              color: const Color(0xFFDC3545),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFDC3545)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.r12),
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
        ),
      ),
    );
  }
}
