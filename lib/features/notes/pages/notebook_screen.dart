import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/note_provider.dart';
import 'package:expense_tracker/features/notes/pages/add_note_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Widget _buildCategoryBadge(BuildContext context, String category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1EFF5);
    Color fg = isDark ? Colors.white70 : Colors.black87;

    if (category == 'Business') {
      bg = isDark ? const Color(0xFF10B981).withValues(alpha: 0.15) : const Color(0xFFE8F8F5);
      fg = isDark ? const Color(0xFF10B981) : AppColors.activeGreen;
    } else if (category == 'Personal') {
      bg = isDark ? Colors.blue.withValues(alpha: 0.15) : const Color(0xFFEBF5FB);
      fg = isDark ? Colors.blue.shade400 : Colors.blue.shade700;
    } else if (category == 'General') {
      bg = isDark ? Colors.orange.withValues(alpha: 0.15) : const Color(0xFFFEF9E7);
      fg = isDark ? Colors.orange.shade400 : Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: fg,
        ),
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
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notebook',
          style: AppTextStyles.appbarTitle.copyWith(
            fontFamily: GoogleFonts.workSans().fontFamily,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddNoteScreen()),
            );
          },
          backgroundColor: AppColors.activeGreen,
          elevation: 2,
          child: Icon(LucideIcons.plus, color: Colors.white, size: 28),
        ),
      ),
      body: Column(
        children: [
          // Search box container
          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: AppTextStyles.body.copyWith(
                fontSize: AppFontSizes.size15,
                color: theme.colorScheme.onSurface,
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
                  fontSize: AppFontSizes.size15,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
                prefixIcon: Icon(LucideIcons.search, color: isDark ? Colors.grey.shade400 : Colors.grey.shade400, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
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
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.stickyNote, size: 64, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty ? 'No notes yet' : 'No matching notes found',
                                style: AppTextStyles.h3.copyWith(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchQuery.isEmpty 
                                    ? 'Tap the "+" button to add your business plans or general notes.'
                                    : 'Try searching for different keywords.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                    itemCount: notesList.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final note = notesList[index];
                      return Dismissible(
                        key: ValueKey(note.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.red.withValues(alpha: 0.1) : const Color(0xFFFEE2E2), // soft light red (Tailwind red-100)
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFCA5A5)), // Tailwind red-300
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Swipe to delete',
                                style: AppTextStyles.bodyBold.copyWith(
                                  color: isDark ? Colors.red.shade400 : const Color(0xFFB91C1C),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                LucideIcons.trash,
                                color: isDark ? Colors.red.shade400 : const Color(0xFFB91C1C), // Tailwind red-700
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await _showDeleteConfirmationDialog(context);
                        },
                        onDismissed: (direction) {
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
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF0F0F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddNoteScreen(note: note),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row: Title and Delete Button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note.title,
                                          style: AppTextStyles.h3.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Delete Button
                                      GestureDetector(
                                        onTap: () async {
                                          final confirm = await _showDeleteConfirmationDialog(context);
                                          if (confirm == true) {
                                            noteProvider.deleteNote(note.id);
                                            if (context.mounted) {
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
                                            }
                                          }
                                        },
                                        child: Icon(
                                          LucideIcons.trash,
                                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Content snippet
                                  Text(
                                    note.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body.copyWith(
                                      height: 1.4,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Footer row: Date and Category chip
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(note.createdAt),
                                        style: AppTextStyles.label.copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                        ),
                                      ),
                                      _buildCategoryBadge(context, note.category),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
