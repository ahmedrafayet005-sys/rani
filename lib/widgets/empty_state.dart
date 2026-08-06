import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onCreateNotePressed;

  const EmptyStateWidget({
    Key? key,
    required this.isSearching,
    required this.onCreateNotePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.note_alt_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'No Matching Notes' : 'No Notes Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try searching with a different keyword.'
                  : 'Tap the "+" button below to capture your thoughts, ideas, and reminders.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onCreateNotePressed,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create First Note'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
