import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final double maxHeight = (MediaQuery.of(context).size.height - viewInsets) * 0.65;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create New Tour',
                        style: GoogleFonts.workSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                        child: TextField(
                          controller: nameController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Tour Name',
                            hintText: 'e.g. Bali Trip 2026',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          style: GoogleFonts.workSans(
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCurrency,
                          decoration: InputDecoration(
                            labelText: 'Currency',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                          if (v != null) setState(() => selectedCurrency = v);
                        },
                        style: GoogleFonts.workSans(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      ),
                      const SizedBox(height: 14),

                      InkWell(
                        onTap: () async {
                          final source = await showModalBottomSheet<ImageSource>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (sCtx) {
                              final sTheme = Theme.of(sCtx);
                              final sDark = sTheme.brightness == Brightness.dark;
                              return Container(
                                decoration: BoxDecoration(
                                  color: sTheme.colorScheme.surface,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + MediaQuery.of(sCtx).padding.bottom),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 36, height: 4,
                                      decoration: BoxDecoration(
                                        color: sDark ? Colors.grey.shade700 : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text('Cover Photo',
                                      style: GoogleFonts.workSans(fontSize: 17, fontWeight: FontWeight.w600, color: sTheme.colorScheme.onSurface),
                                    ),
                                    const SizedBox(height: 20),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt_rounded),
                                      title: Text('Take Photo', style: GoogleFonts.workSans(fontSize: 15)),
                                      onTap: () => Navigator.pop(sCtx, ImageSource.camera),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library_rounded),
                                      title: Text('Choose from Gallery', style: GoogleFonts.workSans(fontSize: 15)),
                                      onTap: () => Navigator.pop(sCtx, ImageSource.gallery),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
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
                          height: 150,
                          decoration: BoxDecoration(
                            color: coverPhotoPath != null
                                ? null
                                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                            ),
                            image: coverPhotoPath != null
                                ? DecorationImage(image: FileImage(File(coverPhotoPath!)), fit: BoxFit.cover)
                                : null,
                          ),
                          child: coverPhotoPath == null
                              ? Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.35), size: 22),
                                      const SizedBox(width: 8),
                                      Text('Add cover photo',
                                        style: GoogleFonts.workSans(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a tour name'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
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
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Create Tour',
                          style: GoogleFonts.workSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
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
