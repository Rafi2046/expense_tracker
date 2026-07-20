import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class FullScreenImageViewer extends StatelessWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  static void show(BuildContext context, List<String> paths, {int index = 0}) {
    if (paths.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          imagePaths: paths,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${initialIndex + 1} / ${imagePaths.length}',
          style: const TextStyle(fontSize: AppFontSizes.size16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: imagePaths.length,
        itemBuilder: (ctx, i) {
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            child: Center(
              child: Image.file(
                File(imagePaths[i]),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 64,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
