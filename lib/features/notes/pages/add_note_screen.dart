import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/note_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddNoteScreen extends StatefulWidget {
  final NoteItem? note;

  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;

  final List<String> _categories = ['Business', 'Personal', 'General'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedCategory = widget.note?.category ?? 'Business';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<NoteProvider>();
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (widget.note == null) {
      // Create Note
      final newNote = NoteItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
        category: _selectedCategory,
      );
      provider.addNote(newNote);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note added successfully'), duration: Duration(seconds: 1)),
      );
    } else {
      // Edit Note
      final updatedNote = widget.note!.copyWith(
        title: title,
        content: content,
        category: _selectedCategory,
        createdAt: DateTime.now(), // update edit time
      );
      provider.updateNote(updatedNote);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated successfully'), duration: Duration(seconds: 1)),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeGreenColor = isDark ? const Color(0xFF10B981) : AppColors.activeGreen;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.note == null ? 'Add Note' : 'Edit Note',
          style: AppTextStyles.appbarTitle.copyWith(
            fontFamily: GoogleFonts.workSans().fontFamily,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Symbols.check, color: activeGreenColor, size: 28),
            onPressed: _saveNote,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Selector label
                Text(
                  'CATEGORY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                    letterSpacing: 1.0,
                    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                // Chips
                Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    Color chipColor = isDark ? theme.cardColor : AppColors.chipBackground;
                    Color textColor = isDark ? Colors.grey.shade400 : Colors.black87;

                    if (isSelected) {
                      if (cat == 'Business') {
                        chipColor = isDark ? const Color(0xFF10B981).withValues(alpha: 0.15) : const Color(0xFFE8F8F5); // light green bg
                        textColor = isDark ? const Color(0xFF10B981) : AppColors.activeGreen;
                      } else if (cat == 'Personal') {
                        chipColor = isDark ? Colors.blue.withValues(alpha: 0.15) : const Color(0xFFEBF5FB); // light blue bg
                        textColor = isDark ? Colors.blue.shade400 : Colors.blue.shade700;
                      } else {
                        chipColor = isDark ? Colors.orange.withValues(alpha: 0.15) : const Color(0xFFFEF9E7); // light yellow/grey bg
                        textColor = isDark ? Colors.orange.shade400 : Colors.orange.shade800;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: textColor,
                            fontFamily: GoogleFonts.workSans().fontFamily,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          }
                        },
                        elevation: 0,
                        pressElevation: 0,
                        backgroundColor: isDark ? theme.cardColor : AppColors.chipBackground,
                        selectedColor: chipColor,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? textColor.withAlpha(76) : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                
                // Note Title field
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Note Title',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Divider
                Divider(color: isDark ? const Color(0xFF2D2D2D) : Colors.grey.shade100, height: 1),
                const SizedBox(height: 16),
                
                // Content text area
                Expanded(
                  child: TextFormField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                      fontFamily: GoogleFonts.inter().fontFamily,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing your note here...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter note content';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
