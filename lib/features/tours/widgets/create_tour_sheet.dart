import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/tours/utils/tour_image_codec.dart';
import 'package:expense_tracker/features/tours/widgets/tour_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'tour_name_field.dart';
import 'tour_date_range_picker.dart';
import 'tour_currency_selector.dart';
import 'tour_description_field.dart';
import 'create_tour_submit_button.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class CreateTourSheet extends StatefulWidget {
  final Function(Tour tour) onTourCreated;
  final Tour? tourToEdit;

  const CreateTourSheet({
    super.key,
    required this.onTourCreated,
    this.tourToEdit,
  });

  static Future<void> show({
    required BuildContext context,
    required Function(Tour tour) onTourCreated,
    Tour? tour,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateTourSheet(
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

    final tourProvider = context.read<TourProvider>();
    final editTour = widget.tourToEdit;
    if (editTour != null) {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final isOwner = (editTour.ownerUid == null && editTour.inviteCode == null) ||
          (currentUid != null && editTour.ownerUid != null && editTour.ownerUid == currentUid);
      final updated = editTour.copyWith(
        name: isOwner ? name : editTour.name,
        coverPhoto: coverPhotoPath,
        currency: isOwner ? selectedCurrency : editTour.currency,
      );
      Navigator.pop(context);
      tourProvider.updateTour(updated);
    } else {
      final tour = Tour(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        coverPhoto: coverPhotoPath,
        currency: selectedCurrency,
        createdAt: DateTime.now(),
        profileId: tourProvider.activeProfileId,
      );
      Navigator.pop(context);
      widget.onTourCreated(tour);
    }
  }

  Future<void> _pickCoverImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (sCtx) {
        final sTheme = Theme.of(sCtx);
        return AlertDialog(
          backgroundColor: sTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r24)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.s16),
              Text(context.translate('cover_photo_label'),
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600, color: sTheme.colorScheme.onSurface),
              ),
              const SizedBox(height: AppSpacing.s16),
              ListTile(
                leading: Icon(LucideIcons.camera, color: sTheme.colorScheme.onSurface),
                title: Text(context.translate('take_photo'), style: AppTextStyles.reportTileTitle.copyWith(
                  fontWeight: FontWeight.w400,
                  color: sTheme.colorScheme.onSurface)),
                onTap: () => Navigator.pop(sCtx, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(LucideIcons.image, color: sTheme.colorScheme.onSurface),
                title: Text(context.translate('choose_from_gallery'), style: AppTextStyles.reportTileTitle.copyWith(
                  fontWeight: FontWeight.w400,
                  color: sTheme.colorScheme.onSurface)),
                onTap: () => Navigator.pop(sCtx, ImageSource.gallery),
              ),
              const SizedBox(height: AppSpacing.s8),
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
      if (picked != null && mounted) {
        final encoded = await TourImageCodec.encodeFile(
          picked.path,
          isCover: true,
        );
        if (encoded != null && mounted) {
          setState(() => coverPhotoPath = encoded);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate('something_went_wrong')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  bool get _hasValidCoverPhoto =>
      TourImageCodec.detect(coverPhotoPath) != TourImageSourceKind.none;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final double maxHeight = (MediaQuery.of(context).size.height - viewInsets) * 0.80;
    
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = widget.tourToEdit == null ||
        (widget.tourToEdit!.ownerUid == null && widget.tourToEdit!.inviteCode == null) ||
        (currentUid != null && widget.tourToEdit!.ownerUid != null && widget.tourToEdit!.ownerUid == currentUid);
    final coverProvider = TourImageResolver.provider(coverPhotoPath);
    final hasCover = _hasValidCoverPhoto && coverProvider != null;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.r24),
            topRight: Radius.circular(AppSpacing.r24),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.p24, AppSpacing.p12, AppSpacing.p24, AppSpacing.p16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.p8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppSpacing.r8),
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
                          color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: AppSpacing.s24),

                      if (!isOwner) ...[
                        const SizedBox(height: AppSpacing.s8),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.p12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.r8),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.info, size: 16, color: Colors.amber),
                              const SizedBox(width: AppSpacing.s8),
                              Expanded(
                                child: Text(
                                  'Only the creator can edit tour details. You can only change the cover photo.',
                                  style: AppTextStyles.label.copyWith(color: isDark ? Colors.amber.shade200 : Colors.amber.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                      ],

                      if (isOwner) ...[
                        TourNameField(
                          theme: theme,
                          controller: nameController,
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        TourDateRangePicker(
                          theme: theme,
                          startDate: startDate,
                          endDate: endDate,
                          onPickStartDate: () => _pickDate(isStart: true),
                          onPickEndDate: () => _pickDate(isStart: false),
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        TourCurrencySelector(
                          theme: theme,
                          value: selectedCurrency,
                          onChanged: (v) => setState(() => selectedCurrency = v),
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        TourDescriptionField(
                          theme: theme,
                          controller: descriptionController,
                        ),
                        const SizedBox(height: AppSpacing.s12),
                      ],

                      InkWell(
                        onTap: _pickCoverImage,
                        child: Container(
                          height: 210,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: hasCover
                                ? null
                                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50),
                            borderRadius: BorderRadius.circular(AppSpacing.r12),
                            border: hasCover
                                ? null
                                : Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                            image: hasCover
                                ? DecorationImage(
                                    image: coverProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: !hasCover
                              ? Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.imagePlus,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.35), size: 22),
                                      const SizedBox(width: AppSpacing.s8),
                                      Text(context.translate('add_cover_photo'),
                                        style: AppTextStyles.bodyBold.copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.6),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(LucideIcons.imagePlus,
                                          color: Colors.white, size: 22),
                                        const SizedBox(width: AppSpacing.s8),
                                        Text(context.translate('change_cover_photo'),
                                          style: AppTextStyles.bodyBold.copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),

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
