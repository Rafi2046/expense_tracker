import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySelectionSheetContent extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const CategorySelectionSheetContent({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelectionSheetContent> createState() =>
      _CategorySelectionSheetContentState();
}

class _CategorySelectionSheetContentState
    extends State<CategorySelectionSheetContent> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filteredCategories = widget.categories
        .where((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Select Business Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: GoogleFonts.workSans().fontFamily,
            ),
          ),
          const SizedBox(height: 16),
          
          // Search Bar
          TextField(
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: GoogleFonts.workSans().fontFamily,
            ),
            decoration: InputDecoration(
              hintText: 'Search Category',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.activeGreen, width: 2),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 16),

          // Scrollable Category List
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final cat = filteredCategories[index];
                final isSelected = cat == _selectedCategory;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  trailing: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? AppColors.activeGreen : Colors.grey.shade300,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                    
                    // Delayed selection notification to let the user see selection
                    Future.delayed(const Duration(milliseconds: 200), () {
                      widget.onCategorySelected(cat);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
