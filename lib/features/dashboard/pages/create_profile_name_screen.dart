import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/profile_manager_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_selection_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/premium_upgrade_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_name_input_field.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class CreateProfileNameScreen extends StatefulWidget {
  final bool isBusiness;

  const CreateProfileNameScreen({super.key, required this.isBusiness});

  @override
  State<CreateProfileNameScreen> createState() =>
      _CreateProfileNameScreenState();
}

class _CreateProfileNameScreenState extends State<CreateProfileNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showPremiumUpgrade(BuildContext context) {
    _isCreating = false;
    if (mounted) setState(() {});
    PremiumUpgradeSheet.show(context);
  }

  void _showCategoryBottomSheet(
    BuildContext context,
    ProfileProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return CategorySelectionSheetContent(
          onCategorySelected: (cat) async {
            Navigator.pop(ctx);
            final newProfile = await provider.finalizeProfileCreation();
            if (!context.mounted) return;
            if (newProfile == null) {
              _showPremiumUpgrade(context);
              return;
            }
            _isCreating = false;
            context.read<ProfileManagerProvider>().switchProfile(newProfile.id);
            Navigator.pop(context, newProfile);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProfileProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate('create_account'),
                style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w800, color: theme.textTheme.titleLarge?.color),
              ),
              const SizedBox(height: 6),
              Text(
                context.translate('enter_details_to_start'),
                style: AppTextStyles.bodySmall.copyWith(color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 24),

              ProfileNameInputField(controller: _nameController),

              const SizedBox(height: 24),

              CustomButton(
                text: _isCreating ? context.translate('creating') : context.translate('continue'),
                backgroundColor: const Color(0xFF2EBD85),
                onPressed: _isCreating
                    ? () {}
                    : () async {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.translate('please_enter_name'))),
                    );
                    return;
                  }

                  setState(() => _isCreating = true);
                  provider.setCreationName(name);

                  if (widget.isBusiness) {
                    _showCategoryBottomSheet(context, provider);
                  } else {
                    final newProfile = await provider.finalizeProfileCreation();
                    if (!context.mounted) return;
                    if (newProfile == null) {
                      _showPremiumUpgrade(context);
                      return;
                    }
                    _isCreating = false;
                    context.read<ProfileManagerProvider>().switchProfile(newProfile.id);
                    Navigator.pop(context, newProfile);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
