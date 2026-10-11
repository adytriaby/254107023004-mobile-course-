import 'package:sqflite/sqflite.dart';

import '../local/db.dart';

/// Repository cache post: cache-first read dari tabel `cached_posts`.
class PostCacheRepository {
  PostCacheRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  Future<List<Map<String, Object?>>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows;
  }

  Future<void> saveCachedPosts(List<Map<String, Object?>> posts) async {
    final db = await _openDb();
    final batch = db.batch();
    batch.delete('cached_posts');
    for (final post in posts) {
      batch.insert('cached_posts', post);
    }
    await batch.commit(noResult: true);
  }

  Future<DateTime?> lastCachedAt() async {
    final db = await _openDb();
    final rows = await db.query(
      'cached_posts',
      orderBy: 'cached_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DateTime.tryParse(rows.first['cached_at'] as String? ?? '');
  }
}
