import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String noteTitle;
  final VoidCallback onDeleteConfirmed;

  const DeleteConfirmationDialog({
    Key? key,
    required this.noteTitle,
    required this.onDeleteConfirmed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayTitle = noteTitle.trim().isEmpty ? 'Untitled Note' : noteTitle;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      ),
      icon: Icon(
        Icons.delete_outline_rounded,
        size: 32,
        color: theme.colorScheme.error,
      ),
      title: const Text(
        'Delete Note?',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Are you sure you want to delete "$displayTitle"? This action cannot be undone.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onDeleteConfirmed();
          },
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          icon: const Icon(Icons.delete_forever_rounded, size: 18),
          label: const Text('Delete'),
        ),
      ],
    );
  }
}
