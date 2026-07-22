import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:expense_tracker/features/tours/utils/tour_image_codec.dart';

/// Resolves a stored tour-image string into an [ImageProvider].
///
/// Handles network URLs, `b64:` / data-URI Base64, and legacy file paths.
class TourImageResolver {
  TourImageResolver._();

  /// Returns an [ImageProvider] for [value], or null when nothing can be shown.
  static ImageProvider? provider(String? value) {
    switch (TourImageCodec.detect(value)) {
      case TourImageSourceKind.none:
        return null;
      case TourImageSourceKind.network:
        return NetworkImage(value!);
      case TourImageSourceKind.base64:
        final bytes = TourImageCodec.decode(value);
        if (bytes == null || bytes.isEmpty) return null;
        return MemoryImage(bytes);
      case TourImageSourceKind.file:
        final file = File(value!);
        if (!file.existsSync()) return null;
        return FileImage(file);
    }
  }

  /// Decode Base64 bytes for callers that need raw [Uint8List] (e.g. fullscreen).
  static Uint8List? bytes(String? value) => TourImageCodec.decode(value);
}

/// Displays a tour cover/receipt from a stored string (URL, Base64, or path).
class TourImage extends StatelessWidget {
  final String? source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final AlignmentGeometry alignment;
  final Widget? placeholder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final FilterQuality filterQuality;

  const TourImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorBuilder,
    this.filterQuality = FilterQuality.low,
  });

  @override
  Widget build(BuildContext context) {
    final kind = TourImageCodec.detect(source);

    if (kind == TourImageSourceKind.none) {
      return placeholder ?? const SizedBox.shrink();
    }

    if (kind == TourImageSourceKind.network) {
      return Image.network(
        source!,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        filterQuality: filterQuality,
        errorBuilder: errorBuilder ?? _defaultError,
      );
    }

    if (kind == TourImageSourceKind.base64) {
      final bytes = TourImageCodec.decode(source);
      if (bytes == null || bytes.isEmpty) {
        return placeholder ?? const SizedBox.shrink();
      }
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        filterQuality: filterQuality,
        gaplessPlayback: true,
        errorBuilder: errorBuilder ?? _defaultError,
      );
    }

    // Legacy filesystem path
    final file = File(source!);
    if (!file.existsSync()) {
      return placeholder ?? const SizedBox.shrink();
    }
    return Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      errorBuilder: errorBuilder ?? _defaultError,
    );
  }

  Widget _defaultError(BuildContext context, Object error, StackTrace? stackTrace) {
    return placeholder ?? const SizedBox.shrink();
  }
}
