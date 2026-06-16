import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CurrencySelectionScreen extends StatefulWidget {
  const CurrencySelectionScreen({super.key});

  @override
  State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFlagIcon(String flagEmoji) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        flagEmoji,
        style: const TextStyle(
          fontSize: 22,
          height: 1.25,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();
    final selectedCurrency = provider.selectedCurrency;

    // Filter currencies based on search query
    final filtered = provider.currencies.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(query) ||
          c.code.toLowerCase().contains(query) ||
          c.region.toLowerCase().contains(query);
    }).toList();

    // Group filtered currencies by region
    final Map<String, List<CurrencyInfo>> grouped = {};
    for (var c in filtered) {
      grouped.putIfAbsent(c.region, () => []).add(c);
    }

    // Sort regions in specific order (ASIA, EUROPE, NORTH AMERICA)
    final regionOrder = ['ASIA', 'EUROPE', 'NORTH AMERICA'];
    final regions = grouped.keys.toList()
      ..sort((a, b) {
        final indexA = regionOrder.indexOf(a);
        final indexB = regionOrder.indexOf(b);
        if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
        if (indexA != -1) return -1;
        if (indexB != -1) return 1;
        return a.compareTo(b);
      });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937), size: 20),
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: _isSearching
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: GoogleFonts.workSans(
                          color: const Color(0xFF1F2937),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search currency...',
                          hintStyle: GoogleFonts.workSans(color: const Color(0xFF9CA3AF), fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                'Select Currency',
                style: GoogleFonts.workSans(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
        centerTitle: true,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF1F2937), size: 20),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF1F2937), size: 20),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // Current Currency Pinned flat card
            if (!_isSearching || filtered.contains(selectedCurrency)) ...[
              Text(
                'CURRENT CURRENCY',
                style: GoogleFonts.workSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF9CA3AF),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          _buildFlagIcon(selectedCurrency.flag),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedCurrency.name,
                                  style: GoogleFonts.workSans(
                                    fontSize: 15,
                                    color: const Color(0xFF1F2937),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedCurrency.code,
                                  style: GoogleFonts.workSans(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            selectedCurrency.symbol,
                            style: GoogleFonts.workSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF064E3B),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF064E3B),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Grouped Region List
            if (regions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    'No currencies found',
                    style: GoogleFonts.workSans(color: const Color(0xFF9CA3AF), fontSize: 15),
                  ),
                ),
              )
            else
              for (var region in regions) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 22.0, bottom: 8.0),
                  child: Text(
                    region,
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF9CA3AF),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: grouped[region]!.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Color(0xFFE5E7EB),
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final currency = grouped[region]![index];
                    final isCurrent = currency.code == selectedCurrency.code;

                    return InkWell(
                      onTap: () {
                        provider.selectCurrency(currency.code);
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        height: 68,
                        child: Row(
                          children: [
                            _buildFlagIcon(currency.flag),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currency.name,
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      color: const Color(0xFF1F2937),
                                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currency.code,
                                    style: GoogleFonts.workSans(
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              currency.symbol,
                              style: GoogleFonts.workSans(
                                fontSize: 16,
                                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                color: isCurrent ? const Color(0xFF064E3B) : const Color(0xFF6B7280),
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 14),
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF064E3B),
                                size: 22,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1),
              ],
          ],
        ),
      ),
    );
  }
}
