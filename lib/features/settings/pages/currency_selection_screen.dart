import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

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

  Widget _buildFlagIcon(BuildContext context, String flagEmoji) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Theme.of(context).cardColor : const Color(0xFFF9FAFB),
        border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        flagEmoji,
        style: const TextStyle(
          fontSize: AppFontSizes.size22,
          height: 1.25,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();
    final selectedCurrency = provider.selectedCurrency;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeGreenColor = isDark ? const Color(0xFF10B981) : const Color(0xFF064E3B);
    final borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB);

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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: theme.colorScheme.onSurface, size: 20),
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
                  color: isDark ? theme.cardColor : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Symbols.search, color: isDark ? Colors.grey.shade500 : const Color(0xFF9CA3AF), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: AppTextStyles.partyFormLabel.copyWith(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search currency...',
                          hintStyle: AppTextStyles.body.copyWith(fontFamily: GoogleFonts.workSans().fontFamily, color: isDark ? Colors.grey.shade600 : const Color(0xFF9CA3AF)),
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
                style: AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Symbols.close : Symbols.search, color: theme.colorScheme.onSurface, size: 20),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: borderColor, height: 1, thickness: 1),
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
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.grey.shade500 : const Color(0xFF9CA3AF),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
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
                          _buildFlagIcon(context, selectedCurrency.flag),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedCurrency.name,
                                  style: AppTextStyles.reportTileTitle.copyWith(color: theme.colorScheme.onSurface),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedCurrency.code,
                                  style: AppTextStyles.label.copyWith(color: isDark ? Colors.grey.shade400 : const Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            selectedCurrency.symbol,
                            style: AppTextStyles.h3.copyWith(
                              fontWeight: FontWeight.w700,
                              color: activeGreenColor,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Icon(
                            Symbols.check_circle_rounded,
                            color: activeGreenColor,
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
                    style: AppTextStyles.reportTileTitle.copyWith(color: isDark ? Colors.grey.shade500 : const Color(0xFF9CA3AF)),
                  ),
                ),
              )
            else
              for (var region in regions) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 22.0, bottom: 8.0),
                  child: Text(
                    region,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.grey.shade500 : const Color(0xFF9CA3AF),
                  letterSpacing: 1.5,
                ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: grouped[region]!.length,
                  separatorBuilder: (context, index) => Divider(
                    color: borderColor,
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
                            _buildFlagIcon(context, currency.flag),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currency.name,
                                    style: AppTextStyles.reportTileTitle.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currency.code,
                                    style: AppTextStyles.label.copyWith(color: isDark ? Colors.grey.shade400 : const Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              currency.symbol,
                            style: AppTextStyles.h3.copyWith(
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent ? activeGreenColor : (isDark ? Colors.grey.shade400 : const Color(0xFF6B7280)),
                            ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 14),
                              Icon(
                                Symbols.check_circle_rounded,
                                color: activeGreenColor,
                                size: 22,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Divider(color: borderColor, height: 1, thickness: 1),
              ],
          ],
        ),
      ),
    );
  }
}
