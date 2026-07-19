import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MemberTile extends StatelessWidget {
  final TourParticipant member;
  final List<Color> presetColors;
  final int index;
  final void Function(String memberId) onRemove;

  const MemberTile({
    super.key,
    required this.member,
    required this.presetColors,
    required this.index,
    required this.onRemove,
  });

  ImageProvider? _getAvatarImage() {
    String? url = member.photoUrl;
    final currentUser = FirebaseAuth.instance.currentUser;
    if ((url == null || url.isEmpty) && member.uid != null && currentUser != null && member.uid == currentUser.uid) {
      url = currentUser.photoURL ?? SharedPrefsHelper.getString('local_profile_photo_${currentUser.uid}');
    }
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http')) {
        return NetworkImage(url);
      } else if (File(url).existsSync()) {
        return FileImage(File(url));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarImage = _getAvatarImage();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m12),
      padding: const EdgeInsets.all(AppSpacing.p12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.br8),
        border: Border.all(
          color: AppColors.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: member.avatarColor != 0
                ? Color(member.avatarColor)
                : presetColors[index % presetColors.length],
            backgroundImage: avatarImage,
            child: avatarImage == null
                ? Text(
                    member.name.isNotEmpty
                        ? String.fromCharCode(member.name.runes.first).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.w16),
          Expanded(
            child: Text(
              member.name,
              style: AppTextStyles.cardTitle.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: AppFontSizes.size16,
                letterSpacing: 0,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onRemove(member.id),
              child: Icon(
                LucideIcons.minusCircle,
                color: AppColors.activeRed.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
