import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ImagePickerSheet extends StatelessWidget {
  const ImagePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Option', style: AppTextStyles.h2.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(LucideIcons.image, color: isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1), size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text('Gallery', style: AppTextStyles.label.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(LucideIcons.camera, color: isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1), size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text('Camera', style: AppTextStyles.label.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
