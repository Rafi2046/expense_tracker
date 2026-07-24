import 'dart:io';

import 'package:flutter/material.dart';
import 'package:expense_tracker/features/tours/utils/tour_image_codec.dart';

/// Resolves profile photo strings for [CircleAvatar] / [DecorationImage].
///
/// Supports:
/// - `https://…` network URLs
/// - `b64:…` / data-URI Base64 (Firestore-synced profile photos)
/// - local filesystem paths
class ProfilePhotoResolver {
  ProfilePhotoResolver._();

  static ImageProvider? provider(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    if (TourImageCodec.isNetwork(value)) {
      return NetworkImage(value);
    }

    if (TourImageCodec.isBase64(value)) {
      final bytes = TourImageCodec.decode(value);
      if (bytes != null && bytes.isNotEmpty) {
        return MemoryImage(bytes);
      }
      return null;
    }

    try {
      final file = File(value);
      if (file.existsSync()) return FileImage(file);
    } catch (_) {}

    return null;
  }

  /// True when [value] can be shown and/or synced across devices.
  static bool isCloudValue(String? value) {
    if (value == null || value.isEmpty) return false;
    return TourImageCodec.isNetwork(value) || TourImageCodec.isBase64(value);
  }
}
