import 'dart:io';
import 'package:flutter/material.dart';

class TourCardBackground extends StatelessWidget {
  final String? coverPhoto;
  final List<Color> gradient;

  const TourCardBackground({
    super.key,
    this.coverPhoto,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (coverPhoto != null && coverPhoto!.isNotEmpty)
          coverPhoto!.startsWith('http')
              ? Image.network(
                  coverPhoto!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildGradientFallback(),
                )
              : Image.file(
                  File(coverPhoto!),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildGradientFallback(),
                )
        else
          _buildGradientFallback(),
        if (coverPhoto != null && coverPhoto!.isNotEmpty)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  stops: const [0.0, 0.3, 0.65, 1.0],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGradientFallback() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
