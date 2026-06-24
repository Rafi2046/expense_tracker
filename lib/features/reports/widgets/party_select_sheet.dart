import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PartySelectSheet extends StatefulWidget {
  final String? selectedPartyName;

  const PartySelectSheet({
    super.key,
    this.selectedPartyName,
  });

  static Future<String?> show(
    BuildContext context, {
    String? selectedPartyName,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PartySelectSheet(
        selectedPartyName: selectedPartyName,
      ),
    );
  }

  @override
  State<PartySelectSheet> createState() => _PartySelectSheetState();
}

class _PartySelectSheetState extends State<PartySelectSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final debtProvider = context.watch<DebtProvider>();
    final mediaQuery = MediaQuery.of(context);

    // Group items by name to get unique parties
    final Map<String, DebtItem> uniqueParties = {};
    for (var item in debtProvider.items) {
      // Keep the item with the phone number if available
      if (!uniqueParties.containsKey(item.name) ||
          (uniqueParties[item.name]?.phone == null && item.phone != null)) {
        uniqueParties[item.name] = item;
      }
    }

    // Filter by search query
    final filteredParties = uniqueParties.values.where((party) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final hasNameMatch = party.name.toLowerCase().contains(q);
      final hasPhoneMatch = party.phone?.toLowerCase().contains(q) ?? false;
      return hasNameMatch || hasPhoneMatch;
    }).toList();

    return Container(
      height: mediaQuery.size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header row
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Select Party to View Report',
                    style: GoogleFonts.workSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'clear_selection'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'CLEAR',
                    style: GoogleFonts.workSans(
                      color: AppColors.activeRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1F1F1), height: 1),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: TextFormField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: GoogleFonts.workSans(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search parties...',
                hintStyle: GoogleFonts.workSans(fontSize: 14, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.activeGreen, width: 1.5),
                ),
              ),
            ),
          ),

          // Parties list
          Expanded(
            child: filteredParties.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, color: Colors.grey.shade300, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No parties found',
                          style: GoogleFonts.workSans(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filteredParties.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Color(0xFFF8FAFC),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final party = filteredParties[index];
                      final isSelected = widget.selectedPartyName == party.name;

                      return ListTile(
                        onTap: () => Navigator.pop(context, party.name),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F2F4),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: AppColors.activeGreen, width: 1.5)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(party.name),
                              style: GoogleFonts.workSans(
                                color: const Color(0xFF31394D),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          party.name,
                          style: GoogleFonts.workSans(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          party.phone ?? 'No phone number',
                          style: GoogleFonts.workSans(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.activeGreen,
                                size: 18,
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
