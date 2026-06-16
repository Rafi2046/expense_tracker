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
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
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
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.workSans(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search currency...',
                  hintStyle: GoogleFonts.workSans(color: Colors.grey.shade400, fontSize: 16),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
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
              icon: const Icon(Icons.search, color: Colors.black87, size: 20),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black87, size: 20),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Current Currency Pinned (Only show when not searching or if it matches search)
            if (!_isSearching || filtered.contains(selectedCurrency)) ...[
              Text(
                'CURRENT CURRENCY',
                style: GoogleFonts.workSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade400,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          selectedCurrency.flag,
                          style: const TextStyle(fontSize: 22, height: 1.1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${selectedCurrency.name} (${selectedCurrency.code})',
                          style: GoogleFonts.workSans(
                            fontSize: 15,
                            color: const Color(0xFF1F2937),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        selectedCurrency.symbol,
                        style: GoogleFonts.workSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.check,
                        color: Color(0xFF064E3B),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1),
              const SizedBox(height: 12),
            ],

            // Grouped Currency list
            if (regions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    'No currencies found',
                    style: GoogleFonts.workSans(color: Colors.grey.shade400, fontSize: 15),
                  ),
                ),
              )
            else
              for (var region in regions) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                  child: Text(
                    region,
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.0,
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
                        height: 60,
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade100,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                currency.flag,
                                style: const TextStyle(fontSize: 22, height: 1.1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${currency.name} (${currency.code})',
                                style: GoogleFonts.workSans(
                                  fontSize: 15,
                                  color: const Color(0xFF1F2937),
                                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                            Text(
                              currency.symbol,
                              style: GoogleFonts.workSans(
                                fontSize: 16,
                                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.check,
                                color: Color(0xFF064E3B),
                                size: 20,
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
