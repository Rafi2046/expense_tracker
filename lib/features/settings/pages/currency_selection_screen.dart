import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/features/settings/widgets/currency_search_bar.dart';
import 'package:expense_tracker/features/settings/widgets/currency_list_tile.dart';
import 'package:expense_tracker/features/settings/widgets/currency_list_header.dart';
import 'package:expense_tracker/features/settings/widgets/currency_empty_state.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
          icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface, size: 20),
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
            ? CurrencySearchBar(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : Text(
                context.translate('select_currency'),
                style: AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? LucideIcons.x : LucideIcons.search, color: theme.colorScheme.onSurface, size: 20),
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
              CurrencyListHeader(
                title: context.translate('current_currency'),
                letterSpacing: 1.2,
                padding: const EdgeInsets.only(bottom: 10),
              ),
              CurrencyListTile(
                currency: selectedCurrency,
                isSelected: true,
                isCard: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 14),
            ],

            // Grouped Region List
            if (regions.isEmpty)
              const CurrencyEmptyState()
            else
              for (var region in regions) ...[
                CurrencyListHeader(title: region),
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

                    return CurrencyListTile(
                      currency: currency,
                      isSelected: isCurrent,
                      onTap: () {
                        provider.selectCurrency(currency.code);
                        Navigator.pop(context);
                      },
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
