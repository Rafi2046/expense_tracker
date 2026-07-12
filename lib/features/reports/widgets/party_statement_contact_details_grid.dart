import 'package:flutter/material.dart';
import 'party_statement_contact_chip.dart';
import 'party_statement_contact_chip_data.dart';

class ContactDetailsGrid extends StatelessWidget {
  final List<ContactChipData> contactDetails;

  const ContactDetailsGrid({super.key, required this.contactDetails});

  @override
  Widget build(BuildContext context) {
    if (contactDetails.isEmpty) return const SizedBox(height: 8);

    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.colorScheme.onSurface.withValues(alpha: 0.07),
                  theme.colorScheme.onSurface.withValues(alpha: 0.07),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth > 300;

              if (useTwoColumns) {
                final List<Widget> rows = [];
                for (int i = 0; i < contactDetails.length; i += 2) {
                  rows.add(
                    Row(
                      children: [
                        Expanded(
                          child: ContactChip(data: contactDetails[i]),
                        ),
                        if (i + 1 < contactDetails.length) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ContactChip(data: contactDetails[i + 1]),
                          ),
                        ] else
                          const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                  );
                  if (i + 2 < contactDetails.length) {
                    rows.add(const SizedBox(height: 10));
                  }
                }
                return Column(children: rows);
              } else {
                return Column(
                  children: contactDetails
                      .map((data) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ContactChip(data: data),
                          ))
                      .toList(),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
