import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/utils/personal_info_handler.dart';
import 'package:expense_tracker/features/settings/widgets/personal_info_view.dart';
import 'package:expense_tracker/features/settings/widgets/personal_info_edit.dart';
import 'package:expense_tracker/features/settings/widgets/profile_app_bar.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen>
    with PersonalInfoHandler<PersonalInfoScreen> {
  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayName = user.displayName ?? 'Guest User';
    final occupation = occupationController.text.trim();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ProfileAppBar(
        isEditing: isEditing,
        isDark: isDark,
        onBack: () => Navigator.pop(context),
        onEdit: () => setState(() => isEditing = true),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: isEditing
                ? PersonalInfoEdit(
                    firstNameController: firstNameController,
                    lastNameController: lastNameController,
                    phoneController: phoneController,
                    dobController: dobController,
                    occupationController: occupationController,
                    selectedGender: selectedGender,
                    onGenderChanged: (gender) =>
                        setState(() => selectedGender = gender),
                    localImageFile: localImageFile,
                    photoUrl: photoUrl,
                    isLoading: isLoading,
                    providerName: providerName,
                    userEmail: user.email ?? '',
                    onPickImage: () => pickImage(context),
                    onSelectDate: () => selectDate(context),
                    onSave: saveChanges,
                    onCancel: cancelEditing,
                  )
                : PersonalInfoView(
                    user: user,
                    photoUrl: photoUrl,
                    localImageFile: localImageFile,
                    displayName: displayName,
                    phone: phoneController.text,
                    dob: dobController.text,
                    gender: selectedGender,
                    occupation: occupation,
                    providerName: providerName,
                    onEditTap: () => setState(() => isEditing = true),
                  ),
          ),
        ),
      ),
    );
  }
}
