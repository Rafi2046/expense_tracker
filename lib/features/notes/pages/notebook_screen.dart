import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/note_provider.dart';
import 'package:expense_tracker/features/notes/pages/add_note_screen.dart';
import 'package:expense_tracker/features/notes/widgets/notebook_empty_state.dart';
import 'package:expense_tracker/features/notes/widgets/notebook_floating_action_button.dart';
import 'package:expense_tracker/features/notes/widgets/notebook_header.dart';
import 'package:expense_tracker/features/notes/widgets/notebook_note_card.dart';
import 'package:expense_tracker/features/notes/widgets/notebook_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(
          'Delete Note?',
          style: AppTextStyles.dialogTitle.copyWith(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete this note permanently?',
          style: AppTextStyles.body.copyWith(fontFamily: GoogleFonts.workSans().fontFamily, color: theme.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(fontFamily: GoogleFonts.workSans().fontFamily, color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTextStyles.body.copyWith(fontFamily: GoogleFonts.workSans().fontFamily, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final notesList = noteProvider.searchNotes(_searchQuery);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: NotebookHeader(
        onBack: () => Navigator.pop(context),
      ),
      floatingActionButton: NotebookFloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
        },
      ),
      body: Column(
        children: [
          NotebookSearchBar(
            controller: _searchController,
            searchQuery: _searchQuery,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            onClear: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
            isDark: isDark,
          ),

          // Notes List
          Expanded(
            child: noteProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.activeGreen),
                    ),
                  )
                : notesList.isEmpty
                    ? NotebookEmptyState(
                        isSearching: _searchQuery.isNotEmpty,
                        isDark: isDark,
                      )
                    : ListView.builder(
                    itemCount: notesList.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final note = notesList[index];
                      return NotebookNoteCard(
                        note: note,
                        index: index,
                        isDark: isDark,
                        cardColor: theme.cardColor,
                        onSurfaceColor: theme.colorScheme.onSurface,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddNoteScreen(note: note),
                            ),
                          );
                        },
                        onConfirmDelete: () => _showDeleteConfirmationDialog(context),
                        onDeleted: () {
                          noteProvider.deleteNote(note.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Note deleted'),
                              duration: const Duration(seconds: 3),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: Colors.yellow,
                                onPressed: () {
                                  noteProvider.insertNote(index, note);
                                },
                              ),
                            ),
                          );
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
