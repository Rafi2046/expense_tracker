import 'dart:io';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/features/settings/widgets/personal_info_view.dart';
import 'package:expense_tracker/features/settings/widgets/personal_info_edit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _occupationController = TextEditingController();

  File? _localImageFile;
  String _photoUrl = '';
  bool _isLoading = false;
  bool _isEditing = false;
  late User _user;
  String _providerName = 'Email';
  String _selectedGender = 'Male';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user = currentUser;
      
      final displayName = _user.displayName ?? '';
      final nameParts = displayName.split(' ');
      if (nameParts.isNotEmpty) {
        _firstNameController.text = nameParts.first;
        if (nameParts.length > 1) {
          _lastNameController.text = nameParts.sublist(1).join(' ');
        } else {
          _lastNameController.clear();
        }
      }

      _photoUrl = _user.photoURL ?? '';
      
      _phoneController.text = SharedPrefsHelper.getString('local_phone_number_${_user.uid}') ?? '';
      _selectedGender = SharedPrefsHelper.getString('local_gender_${_user.uid}') ?? 'Male';
      _dobController.text = SharedPrefsHelper.getString('local_dob_${_user.uid}') ?? '';
      _occupationController.text = SharedPrefsHelper.getString('local_occupation_${_user.uid}') ?? '';

      final providers = _user.providerData.map((info) => info.providerId).toList();
      if (providers.contains('google.com')) {
        _providerName = 'Google';
      }

      if (_photoUrl.isNotEmpty && !_photoUrl.startsWith('http') && File(_photoUrl).existsSync()) {
        _localImageFile = File(_photoUrl);
      } else {
        _localImageFile = null;
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final localFile = await File(image.path).copy('${directory.path}/profile_${_user.uid}.jpg');

        setState(() {
          _localImageFile = localFile;
          _photoUrl = localFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF8E75C8),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF6A53A1),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _saveChanges() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final combinedName = "$firstName $lastName".trim();

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('First Name cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().updatePersonalInfo(displayName: combinedName);

      if (_photoUrl != _user.photoURL) {
        await _user.updatePhotoURL(_photoUrl);
        await _user.reload();
        await SharedPrefsHelper.setString('local_profile_photo_${_user.uid}', _photoUrl);
      }

      await SharedPrefsHelper.setString('local_phone_number_${_user.uid}', _phoneController.text.trim());
      await SharedPrefsHelper.setString('local_gender_${_user.uid}', _selectedGender);
      await SharedPrefsHelper.setString('local_dob_${_user.uid}', _dobController.text.trim());
      await SharedPrefsHelper.setString('local_occupation_${_user.uid}', _occupationController.text.trim());

      _loadUserInfo();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF6A53A1),
          ),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayName = _user.displayName ?? 'Guest User';
    final occupation = _occupationController.text.trim();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Profile' : 'Profile Details',
          style: GoogleFonts.workSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: Icon(Icons.edit_rounded, size: 16, color: isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1)),
              label: Text(
                'Edit',
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1),
                ),
              ),
            )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: _isEditing
                ? PersonalInfoEdit(
                    firstNameController: _firstNameController,
                    lastNameController: _lastNameController,
                    phoneController: _phoneController,
                    dobController: _dobController,
                    occupationController: _occupationController,
                    selectedGender: _selectedGender,
                    onGenderChanged: (gender) {
                      setState(() {
                        _selectedGender = gender;
                      });
                    },
                    localImageFile: _localImageFile,
                    photoUrl: _photoUrl,
                    isLoading: _isLoading,
                    providerName: _providerName,
                    userEmail: _user.email ?? '',
                    onPickImage: _pickImage,
                    onSelectDate: () => _selectDate(context),
                    onSave: _saveChanges,
                    onCancel: () {
                      _loadUserInfo();
                      setState(() {
                        _isEditing = false;
                      });
                    },
                  )
                : PersonalInfoView(
                    user: _user,
                    photoUrl: _photoUrl,
                    localImageFile: _localImageFile,
                    displayName: displayName,
                    phone: _phoneController.text,
                    dob: _dobController.text,
                    gender: _selectedGender,
                    occupation: occupation,
                    providerName: _providerName,
                    onEditTap: () => setState(() => _isEditing = true),
                  ),
          ),
        ),
      ),
    );
  }
}
