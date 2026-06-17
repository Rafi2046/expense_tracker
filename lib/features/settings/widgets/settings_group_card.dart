import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroupCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final List<Widget> items = [];
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(Container(
          color: const Color(0xFFF1F1F1),
          height: 1.0,
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Header Title in Work Sans, colored purple
        Padding(
          padding: const EdgeInsets.only(left: 6.0, bottom: 10.0),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.workSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6A53A1), // Premium violet text accent
              letterSpacing: 1.0,
            ),
          ),
        ),

        // Group Card Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFF1F1F1),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: items,
            ),
          ),
        ),
      ],
    );
  }
}
