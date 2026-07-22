import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// How a stored tour-image string should be interpreted.
enum TourImageSourceKind {
  none,
  network,
  base64,
  file,
}

/// Compresses tour images and encodes/decodes them for SQLite TEXT storage.
///
/// Stored format for new local images: `b64:<base64-jpeg-bytes>`.
/// Network URLs (`http`/`https`) and legacy filesystem paths are also recognized.
///
/// If [flutter_image_compress] is unavailable (e.g. MissingPluginException after
/// a hot reload of a newly added plugin), falls back to encoding the already
/// resized bytes from `image_picker` without a second native compress pass.
class TourImageCodec {
  TourImageCodec._();

  /// Prefix written in front of Base64 payloads stored in SQLite.
  static const String base64Prefix = 'b64:';

  static const int _coverMaxWidth = 1200;
  static const int _coverQuality = 72;
  static const int _receiptMaxWidth = 1100;
  static const int _receiptQuality = 68;

  // ─── Type detection ───────────────────────────────────────────────

  static TourImageSourceKind detect(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TourImageSourceKind.none;
    }
    if (isNetwork(value)) return TourImageSourceKind.network;
    if (isBase64(value)) return TourImageSourceKind.base64;
    if (isLegacyFilePath(value)) return TourImageSourceKind.file;
    return TourImageSourceKind.none;
  }

  static bool isNetwork(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.startsWith('http://') || value.startsWith('https://');
  }

  static bool isBase64(String? value) {
    if (value == null || value.isEmpty) return false;
    if (value.startsWith(base64Prefix)) return true;
    if (value.startsWith('data:image/')) return true;
    return false;
  }

  /// True when [value] looks like a local filesystem path (legacy storage).
  static bool isLegacyFilePath(String? value) {
    if (value == null || value.isEmpty) return false;
    if (isNetwork(value) || isBase64(value)) return false;
    // Absolute Unix / Android / iOS paths, or known tour filename patterns.
    if (value.startsWith('/')) return true;
    if (value.contains('tour_cover_') ||
        value.contains('${Platform.pathSeparator}receipts${Platform.pathSeparator}')) {
      return true;
    }
    // Windows-style absolute path (unlikely on device, but safe).
    if (value.length >= 3 &&
        value[1] == ':' &&
        (value[2] == '\\' || value[2] == '/')) {
      return true;
    }
    return false;
  }

  // ─── Encode (compress → Base64) ───────────────────────────────────

  static String _wrapBase64(Uint8List bytes) =>
      '$base64Prefix${base64Encode(bytes)}';

  /// Compress [bytes] and return a `b64:`-prefixed string for SQLite.
  /// Falls back to raw Base64 if native compression is unavailable.
  static Future<String?> encodeBytes(
    Uint8List bytes, {
    bool isCover = false,
  }) async {
    if (bytes.isEmpty) return null;

    try {
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: isCover ? _coverMaxWidth : _receiptMaxWidth,
        minHeight: isCover ? _coverMaxWidth : _receiptMaxWidth,
        quality: isCover ? _coverQuality : _receiptQuality,
        format: CompressFormat.jpeg,
      );
      if (compressed.isNotEmpty) {
        return _wrapBase64(compressed);
      }
    } catch (e) {
      debugPrint(
        'TourImageCodec: compressWithList unavailable, using raw bytes: $e',
      );
    }

    return _wrapBase64(bytes);
  }

  /// Read a local file, compress, and encode for SQLite.
  /// Falls back to raw file bytes if native compression is unavailable.
  static Future<String?> encodeFile(
    String path, {
    bool isCover = false,
  }) async {
    if (kIsWeb) return null;
    final file = File(path);
    if (!await file.exists()) return null;

    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        path,
        minWidth: isCover ? _coverMaxWidth : _receiptMaxWidth,
        minHeight: isCover ? _coverMaxWidth : _receiptMaxWidth,
        quality: isCover ? _coverQuality : _receiptQuality,
        format: CompressFormat.jpeg,
      );
      if (compressed != null && compressed.isNotEmpty) {
        return _wrapBase64(compressed);
      }
    } catch (e) {
      debugPrint(
        'TourImageCodec: compressWithFile unavailable, using raw bytes ($path): $e',
      );
    }

    try {
      final raw = await file.readAsBytes();
      if (raw.isEmpty) return null;
      // encodeBytes will try list-compress once more, then raw-encode.
      return encodeBytes(raw, isCover: isCover);
    } catch (e) {
      debugPrint('TourImageCodec.encodeFile read failed ($path): $e');
      return null;
    }
  }

  // ─── Decode ───────────────────────────────────────────────────────

  /// Decode a stored Base64 / data-URI value to image bytes.
  /// Returns null for network URLs, file paths, or invalid input.
  static Uint8List? decode(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      var payload = value;
      if (payload.startsWith(base64Prefix)) {
        payload = payload.substring(base64Prefix.length);
      } else if (payload.startsWith('data:image/')) {
        final comma = payload.indexOf(',');
        if (comma < 0) return null;
        payload = payload.substring(comma + 1);
      } else {
        return null;
      }
      if (payload.isEmpty) return null;
      return base64Decode(payload);
    } catch (e) {
      debugPrint('TourImageCodec.decode failed: $e');
      return null;
    }
  }

  // ─── Migration helper ─────────────────────────────────────────────

  /// Convert a legacy stored value to the new format when possible.
  ///
  /// - Network URLs: unchanged
  /// - Already Base64: unchanged
  /// - Local path with existing file: compress + encode; optionally delete file
  /// - Missing file path: cleared to null (unrecoverable)
  /// - Empty / unknown: unchanged / null
  static Future<String?> migrateStoredValue(
    String? value, {
    bool isCover = false,
    bool deleteSourceFile = true,
  }) async {
    if (value == null || value.trim().isEmpty) return null;

    final kind = detect(value);
    switch (kind) {
      case TourImageSourceKind.network:
      case TourImageSourceKind.base64:
        return value;
      case TourImageSourceKind.none:
        return value;
      case TourImageSourceKind.file:
        if (kIsWeb) return value;
        final file = File(value);
        if (!await file.exists()) {
          // Path survived Auto Backup but bytes did not — drop dead reference.
          return null;
        }
        final encoded = await encodeFile(value, isCover: isCover);
        if (encoded != null && deleteSourceFile) {
          try {
            await file.delete();
          } catch (e) {
            debugPrint('TourImageCodec: could not delete migrated file: $e');
          }
        }
        // If encode failed, keep the path so UI can still try Image.file.
        return encoded ?? value;
    }
  }
}
