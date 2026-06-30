import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/profile_manager_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_selection_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/premium_upgrade_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_name_input_field.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateProfileNameScreen extends StatefulWidget {
  final bool isBusiness;

  const CreateProfileNameScreen({super.key, required this.isBusiness});

  @override
  State<CreateProfileNameScreen> createState() =>
      _CreateProfileNameScreenState();
}

class _CreateProfileNameScreenState extends State<CreateProfileNameScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showPremiumUpgrade(BuildContext context) {
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
          onCategorySelected: (cat) {
            Navigator.pop(ctx);
            final newProfile = provider.finalizeProfileCreation();
            if (newProfile == null) {
              _showPremiumUpgrade(context);
              return;
            }
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
          icon: Icon(Symbols.arrow_back, color: theme.iconTheme.color),
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
                'Create an Account',
                style: GoogleFonts.workSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please enter the following details to get started',
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 24),

              ProfileNameInputField(controller: _nameController),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Continue',
                backgroundColor: const Color(0xFF2EBD85),
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your name')),
                    );
                    return;
                  }

                  provider.setCreationName(name);

                  if (widget.isBusiness) {
                    _showCategoryBottomSheet(context, provider);
                  } else {
                    final newProfile = provider.finalizeProfileCreation();
                    if (newProfile == null) {
                      _showPremiumUpgrade(context);
                      return;
                    }
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
