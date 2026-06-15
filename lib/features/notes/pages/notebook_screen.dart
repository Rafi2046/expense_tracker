import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/note_provider.dart';
import 'package:expense_tracker/features/notes/pages/add_note_screen.dart';
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
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Note?',
          style: AppTextStyles.dialogTitle,
        ),
        content: const Text(
          'Are you sure you want to delete this note permanently?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
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

  Widget _buildCategoryBadge(String category) {
    Color bg = const Color(0xFFF1EFF5);
    Color fg = Colors.black87;

    if (category == 'Business') {
      bg = const Color(0xFFE8F8F5);
      fg = AppColors.activeGreen;
    } else if (category == 'Personal') {
      bg = const Color(0xFFEBF5FB);
      fg = Colors.blue.shade700;
    } else if (category == 'General') {
      bg = const Color(0xFFFEF9E7);
      fg = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          fontFamily: GoogleFonts.workSans().fontFamily,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final notesList = noteProvider.searchNotes(_searchQuery);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notebook',
          style: AppTextStyles.appbarTitle.copyWith(
            fontFamily: GoogleFonts.workSans().fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
        },
        backgroundColor: AppColors.activeGreen,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          // Search box container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: TextStyle(
                fontSize: 15,
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
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
                              Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty ? 'No notes yet' : 'No matching notes found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                  fontFamily: GoogleFonts.workSans().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchQuery.isEmpty 
                                    ? 'Tap the "+" button to add your business plans or general notes.'
                                    : 'Try searching for different keywords.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                  fontFamily: GoogleFonts.workSans().fontFamily,
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
                            color: const Color(0xFFFEE2E2), // soft light red (Tailwind red-100)
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFCA5A5)), // Tailwind red-300
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Swipe to delete',
                                style: TextStyle(
                                  color: const Color(0xFFB91C1C), // Tailwind red-700
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  fontFamily: GoogleFonts.workSans().fontFamily,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFFB91C1C), // Tailwind red-700
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF0F0F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(5),
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
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            fontFamily: GoogleFonts.workSans().fontFamily,
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
                                          Icons.delete_outline_rounded,
                                          color: Colors.grey.shade400,
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
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: Colors.grey.shade600,
                                      fontFamily: GoogleFonts.inter().fontFamily,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Footer row: Date and Category chip
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(note.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade400,
                                          fontFamily: GoogleFonts.workSans().fontFamily,
                                        ),
                                      ),
                                      _buildCategoryBadge(note.category),
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
