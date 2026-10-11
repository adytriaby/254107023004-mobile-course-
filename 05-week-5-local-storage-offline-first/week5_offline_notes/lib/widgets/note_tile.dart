import 'package:flutter/material.dart';

import '../data/local/note.dart';

/// Baris catatan reusable dengan badge "belum tersinkron" bila dirty.
class NoteTile extends StatelessWidget {
  const NoteTile({
    required this.note,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: const Icon(Icons.sticky_note_2),
      ),
      title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        note.body.isEmpty ? 'Tanpa isi' : note.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.dirty)
            Tooltip(
              message: 'Belum tersinkron',
              child: Icon(Icons.cloud_upload,
                  size: 18, color: theme.colorScheme.error),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus catatan',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
