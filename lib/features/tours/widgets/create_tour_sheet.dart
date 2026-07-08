import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class CreateTourSheet extends StatefulWidget {
  final Function(Tour tour) onTourCreated;

  const CreateTourSheet({super.key, required this.onTourCreated});

  static void show({
    required BuildContext context,
    required Function(Tour tour) onTourCreated,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTourSheet(onTourCreated: onTourCreated),
    );
  }

  @override
  State<CreateTourSheet> createState() => _CreateTourSheetState();
}

class _CreateTourSheetState extends State<CreateTourSheet> {
  final nameController = TextEditingController();
  String selectedCurrency = 'BDT';
  String? coverPhotoPath;
  bool _isHidden = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double maxHeight = 430;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: _isHidden ? Colors.transparent : theme.colorScheme.surface,
              borderRadius: _isHidden
                  ? BorderRadius.zero
                  : const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
            ),
            padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset + 70),
            child: _isHidden
                ? const SizedBox.shrink()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Container(
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: theme.dividerColor.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text('New Tour', style: AppTextStyles.dialogTitle),
                              const SizedBox(height: 12),
                              TextField(
                                controller: nameController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  labelText: 'Tour Name',
                                  hintText: 'e.g. Bali Trip 2026',
                                  filled: true,
                                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                style: AppTextStyles.partyFormInput.copyWith(color: theme.colorScheme.onSurface),
                                onSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                },
                              ),

                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  initialValue: selectedCurrency,
                                  decoration: InputDecoration(
                                    labelText: 'Currency',
                                    filled: true,
                                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  dropdownColor: theme.colorScheme.surface,
                                  items: const [
                                    DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
                                    DropdownMenuItem(value: 'BDT', child: Text('৳ BDT')),
                                    DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
                                    DropdownMenuItem(value: 'GBP', child: Text('£ GBP')),
                                    DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
                                    DropdownMenuItem(value: 'JPY', child: Text('¥ JPY')),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => selectedCurrency = v);
                                    }
                                  },
                                  style: AppTextStyles.partyFormInput.copyWith(color: theme.colorScheme.onSurface),
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () async {
                                    setState(() => _isHidden = true);
                                    final source = await showModalBottomSheet<ImageSource>(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (sCtx) => Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset + 20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: theme.dividerColor.withValues(alpha: 0.5),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            const Text('Cover Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 20),
                                            ListTile(
                                              leading: const Icon(Icons.camera_alt_rounded),
                                              title: const Text('Take Photo'),
                                              onTap: () => Navigator.pop(sCtx, ImageSource.camera),
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.photo_library_rounded),
                                              title: const Text('Choose from Gallery'),
                                              onTap: () => Navigator.pop(sCtx, ImageSource.gallery),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                    setState(() => _isHidden = false);
                                    if (source != null) {
                                      final picked = await ImagePicker().pickImage(
                                        source: source,
                                        maxWidth: 1200,
                                        imageQuality: 85,
                                      );
                                      if (picked != null) {
                                        setState(() => coverPhotoPath = picked.path);
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: coverPhotoPath != null
                                          ? null
                                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                                        style: BorderStyle.solid,
                                      ),
                                      image: coverPhotoPath != null
                                          ? DecorationImage(image: FileImage(File(coverPhotoPath!)), fit: BoxFit.cover)
                                          : null,
                                    ),
                                    child: coverPhotoPath == null
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_photo_alternate_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 22),
                                              const SizedBox(width: 8),
                                              Text('Add cover photo', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 14)),
                                            ],
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () {
                                    final name = nameController.text.trim();
                                    if (name.isEmpty) return;
                                    final tour = Tour(
                                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                                      name: name,
                                      coverPhoto: coverPhotoPath,
                                      currency: selectedCurrency,
                                      createdAt: DateTime.now(),
                                      profileId: context.read<TourProvider>().activeProfileId,
                                    );
                                    Navigator.pop(context);
                                    widget.onTourCreated(tour);
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.activeGreen,
                                    minimumSize: const Size(double.infinity, 54),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Create Tour', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white)),
                                ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
