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
          Image.file(
            File(coverPhoto!),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildGradientFallback(),
          )
        else
          _buildGradientFallback(),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 160,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
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
