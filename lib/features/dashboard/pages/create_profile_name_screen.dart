import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_selection_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_name_input_field.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
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

  void _showCategoryBottomSheet(
    BuildContext context,
    ProfileProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CategorySelectionSheetContent(
          onCategorySelected: (cat) {
            Navigator.pop(context); // Close bottom sheet
            final newProfile = provider.finalizeProfileCreation();
            Navigator.pop(context, newProfile); // Return from name screen
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProfileProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create an Account', style: AppTextStyles.profileTitle),
              const SizedBox(height: 6),
              Text(
                'Please enter the following details to get started',
                style: AppTextStyles.profileSubtitle,
              ),
              const SizedBox(height: 24),

              // Your Name text field matching screenshot
              ProfileNameInputField(controller: _nameController),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Continue',
                backgroundColor: AppColors.activeGreen,
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
