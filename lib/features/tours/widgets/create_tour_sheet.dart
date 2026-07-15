import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'tour_name_field.dart';
import 'tour_date_range_picker.dart';
import 'tour_currency_selector.dart';
import 'tour_description_field.dart';
import 'create_tour_submit_button.dart';

class CreateTourSheet extends StatefulWidget {
  final Function(Tour tour) onTourCreated;
  final Tour? tourToEdit;

  const CreateTourSheet({
    super.key,
    required this.onTourCreated,
    this.tourToEdit,
  });

  static void show({
    required BuildContext context,
    required Function(Tour tour) onTourCreated,
    Tour? tour,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTourSheet(
        onTourCreated: onTourCreated,
        tourToEdit: tour,
      ),
    );
  }

  @override
  State<CreateTourSheet> createState() => _CreateTourSheetState();
}

class _CreateTourSheetState extends State<CreateTourSheet> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedCurrency = 'BDT';
  DateTime? startDate;
  DateTime? endDate;
  String? coverPhotoPath;

  @override
  void initState() {
    super.initState();
    final tour = widget.tourToEdit;
    if (tour != null) {
      nameController.text = tour.name;
      selectedCurrency = tour.currency;
      coverPhotoPath = tour.coverPhoto;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (startDate ?? now)
          : (endDate ?? startDate ?? now),
      firstDate: isStart ? now.subtract(const Duration(days: 365)) : (startDate ?? now),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(picked)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _handleSubmit() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('please_enter_tour_name')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final editTour = widget.tourToEdit;
    if (editTour != null) {
      final updated = editTour.copyWith(
        name: name,
        coverPhoto: coverPhotoPath,
        currency: selectedCurrency,
      );
      Navigator.pop(context);
      context.read<TourProvider>().updateTour(updated);
    } else {
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
    }
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
                        widget.tourToEdit != null ? context.translate('edit_tour_title') : context.translate('create_tour_title'),
                        style: AppTextStyles.h3.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TourNameField(
                        theme: theme,
                        controller: nameController,
                      ),
                      const SizedBox(height: 14),

                      TourDateRangePicker(
                        theme: theme,
                        startDate: startDate,
                        endDate: endDate,
                        onPickStartDate: () => _pickDate(isStart: true),
                        onPickEndDate: () => _pickDate(isStart: false),
                      ),
                      const SizedBox(height: 14),

                      TourCurrencySelector(
                        theme: theme,
                        value: selectedCurrency,
                        onChanged: (v) => setState(() => selectedCurrency = v),
                      ),
                      const SizedBox(height: 14),

                      TourDescriptionField(
                        theme: theme,
                        controller: descriptionController,
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
                                    Text(context.translate('cover_photo_label'),
                                      style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w600, color: sTheme.colorScheme.onSurface),
                                    ),
                                    const SizedBox(height: 20),
                                     ListTile(
                                       leading: Icon(LucideIcons.camera, color: sTheme.colorScheme.onSurface),
                                       title: Text(context.translate('take_photo'), style: AppTextStyles.reportTileTitle.copyWith(
                                         fontWeight: FontWeight.w400,
                                         color: sTheme.colorScheme.onSurface,
                                       )),
                                       onTap: () => Navigator.pop(sCtx, ImageSource.camera),
                                     ),
                                     ListTile(
                                       leading: Icon(LucideIcons.image, color: sTheme.colorScheme.onSurface),
                                       title: Text(context.translate('choose_from_gallery'), style: AppTextStyles.reportTileTitle.copyWith(
                                         fontWeight: FontWeight.w400,
                                         color: sTheme.colorScheme.onSurface,
                                       )),
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
                                ? (coverPhotoPath!.startsWith('http')
                                    ? DecorationImage(image: NetworkImage(coverPhotoPath!), fit: BoxFit.cover)
                                    : DecorationImage(image: FileImage(File(coverPhotoPath!)), fit: BoxFit.cover))
                                : null,
                          ),
                          child: coverPhotoPath == null
                              ? Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.imagePlus,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.35), size: 22),
                                      const SizedBox(width: 8),
                                      Text(context.translate('add_cover_photo'),
                                        style: AppTextStyles.bodyBold.copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      CreateTourSubmitButton(
                        onPressed: _handleSubmit,
                        label: widget.tourToEdit != null ? context.translate('save_changes') : null,
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
