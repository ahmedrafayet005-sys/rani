import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../widgets/delete_dialog.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? initialNote;

  const NoteEditorScreen({Key? key, this.initialNote}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _isPinned;
  late int _selectedColor;
  late String _noteId;
  late DateTime _createdAt;
  late StorageService _storageService;

  bool _isSaving = false;
  Timer? _autoSaveDebouncer;

  final List<int> _colorOptions = const [
    0xFFFFFFFF,
    0xFFF87171,
    0xFFFBBF24,
    0xFF34D399,
    0xFF60A5FA,
    0xFFA78BFA,
    0xFFF472B6,
  ];

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();

    final note = widget.initialNote;
    _noteId = note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _createdAt = note?.createdAt ?? DateTime.now();
    _isPinned = note?.isPinned ?? false;
    _selectedColor = note?.colorValue ?? 0xFFFFFFFF;

    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _autoSaveDebouncer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    _triggerAutoSave();
  }

  void _triggerAutoSave() {
    if (_autoSaveDebouncer?.isActive ?? false) _autoSaveDebouncer!.cancel();
    _autoSaveDebouncer = Timer(const Duration(milliseconds: 600), () {
      _saveNote();
    });
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty && widget.initialNote == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final noteToSave = Note(
      id: _noteId,
      title: _titleController.text,
      content: _contentController.text,
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
      isPinned: _isPinned,
      colorValue: _selectedColor,
    );

    await _storageService.saveSingleNote(noteToSave);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
    });
    _saveNote();
  }

  void _changeColor(int color) {
    setState(() {
      _selectedColor = color;
    });
    _saveNote();
  }

  Future<void> _deleteNote() async {
    await _storageService.deleteNote(_noteId);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        noteTitle: _titleController.text,
        onDeleteConfirmed: _deleteNote,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final charCount = _contentController.text.length;
    final wordCount = _contentController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;

    Color editorBgColor;
    if (_selectedColor != 0xFFFFFFFF) {
      final baseColor = Color(_selectedColor);
      editorBgColor = isDark
          ? Color.alphaBlend(Colors.black.withOpacity(0.75), baseColor)
          : Color.alphaBlend(Colors.white.withOpacity(0.8), baseColor);
    } else {
      editorBgColor = theme.colorScheme.background;
    }

    return Scaffold(
      backgroundColor: editorBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            await _saveNote();
            if (mounted) Navigator.of(context).pop(true);
          },
        ),
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isSaving ? 1.0 : 0.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Saving...',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: _togglePin,
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: _showColorPickerBottomSheet,
          ),
          if (widget.initialNote != null)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
              ),
              onPressed: _showDeleteConfirmation,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(_createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withOpacity(0.15),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: 'Start writing your note here...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$charCount chars',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  $wordCount words',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_done_outlined,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Saved locally',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPickerBottomSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Note Color',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _colorOptions.map((colorVal) {
                  final isSelected = _selectedColor == colorVal;
                  final color = Color(colorVal);
                  return GestureDetector(
                    onTap: () {
                      _changeColor(colorVal);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colorVal == 0xFFFFFFFF ? theme.colorScheme.surface : color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withOpacity(0.3),
                          width: isSelected ? 3.0 : 1.0,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: colorVal == 0xFFFFFFFF ? theme.colorScheme.primary : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
