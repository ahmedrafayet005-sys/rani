import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import '../widgets/delete_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar_widget.dart';
import 'note_editor_screen.dart';

enum SortOption { newest, oldest, alphabetical }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _searchController = TextEditingController();

  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;
  bool _isSearchActive = false;
  SortOption _currentSort = SortOption.newest;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await _storageService.getNotes();
    if (mounted) {
      setState(() {
        _allNotes = notes;
        _isLoading = false;
        _applyFiltersAndSort();
      });
    }
  }

  void _applyFiltersAndSort() {
    final query = _searchController.text.trim().toLowerCase();

    List<Note> results = _allNotes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(query);
      final contentMatch = note.content.toLowerCase().contains(query);
      return titleMatch || contentMatch;
    }).toList();

    results.sort((a, b) {
      switch (_currentSort) {
        case SortOption.newest:
          return b.updatedAt.compareTo(a.updatedAt);
        case SortOption.oldest:
          return a.updatedAt.compareTo(b.updatedAt);
        case SortOption.alphabetical:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    setState(() {
      _filteredNotes = results;
    });
  }

  Future<void> _openNoteEditor([Note? note]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(initialNote: note),
      ),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  Future<void> _togglePin(Note note) async {
    final updatedNote = note.copyWith(isPinned: !note.isPinned);
    await _storageService.saveSingleNote(updatedNote);
    _loadNotes();
  }

  Future<void> _confirmAndDelete(Note note) async {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        noteTitle: note.title,
        onDeleteConfirmed: () async {
          await _storageService.deleteNote(note.id);
          _loadNotes();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final pinnedNotes = _filteredNotes.where((n) => n.isPinned).toList();
    final unpinnedNotes = _filteredNotes.where((n) => !n.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.search_off_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                  _applyFiltersAndSort();
                }
              });
            },
            tooltip: _isSearchActive ? 'Close Search' : 'Search Notes',
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort Notes',
            onSelected: (option) {
              setState(() {
                _currentSort = option;
                _applyFiltersAndSort();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortOption.newest,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 18,
                      color: _currentSort == SortOption.newest ? theme.colorScheme.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text('Sort by Newest'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.oldest,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 18,
                      color: _currentSort == SortOption.oldest ? theme.colorScheme.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text('Sort by Oldest'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.alphabetical,
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha_rounded,
                      size: 18,
                      color: _currentSort == SortOption.alphabetical ? theme.colorScheme.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text('Sort Alphabetically'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
            tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isSearchActive)
              SearchBarWidget(
                controller: _searchController,
                onChanged: (_) => _applyFiltersAndSort(),
                onClear: () {
                  _searchController.clear();
                  _applyFiltersAndSort();
                },
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredNotes.isEmpty
                      ? EmptyStateWidget(
                          isSearching: _searchController.text.isNotEmpty,
                          onCreateNotePressed: () => _openNoteEditor(),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadNotes,
                          child: CustomScrollView(
                            slivers: [
                              if (pinnedNotes.isNotEmpty) ...[
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.push_pin_rounded,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'PINNED NOTES (${pinnedNotes.length})',
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.1,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final note = pinnedNotes[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: NoteCard(
                                            note: note,
                                            onTap: () => _openNoteEditor(note),
                                            onPinToggle: () => _togglePin(note),
                                            onDelete: () => _confirmAndDelete(note),
                                          ),
                                        );
                                      },
                                      childCount: pinnedNotes.length,
                                    ),
                                  ),
                                ),
                              ],
                              if (unpinnedNotes.isNotEmpty) ...[
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                    child: Text(
                                      pinnedNotes.isNotEmpty
                                          ? 'OTHER NOTES (${unpinnedNotes.length})'
                                          : 'ALL NOTES (${unpinnedNotes.length})',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final note = unpinnedNotes[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: NoteCard(
                                            note: note,
                                            onTap: () => _openNoteEditor(note),
                                            onPinToggle: () => _togglePin(note),
                                            onDelete: () => _confirmAndDelete(note),
                                          ),
                                        );
                                      },
                                      childCount: unpinnedNotes.length,
                                    ),
                                  ),
                                ),
                              ],
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 80),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNoteEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Note'),
      ),
    );
  }
}
