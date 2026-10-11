import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../messaging/push_service.dart';

/// Pengumuman kampus (mock lokal; ganti dengan API kampus di produksi).
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  final String id;
  final String title;
  final String body;
  final String date;
}

class AnnouncementRepository {
  const AnnouncementRepository();

  static const _items = <String, Announcement>{
    '1': Announcement(
      id: '1',
      title: 'Jadwal UTS Semester Ganjil',
      body:
          'Ujian Tengah Semester dilaksanakan 20-24 Oktober 2026. '
          'Pastikan tidak ada tunggakan administrasi sebelum ujian.',
      date: '2026-10-01',
    ),
    '2': Announcement(
      id: '2',
      title: 'Pendaftaran Beasiswa PPA',
      body:
          'Pendaftaran Beasiswa Peningkatan Prestasi Akademik dibuka '
          'hingga 15 November 2026 melalui portal akademik.',
      date: '2026-10-05',
    ),
    '3': Announcement(
      id: '3',
      title: 'Jadwal kuliah berubah',
      body:
          'Kelas Pemrograman Mobile pindah ke Ruang A2, pukul 13.00 WIB, '
          'mulai pekan depan.',
      date: '2026-10-10',
    ),
  };

  List<Announcement> all() => _items.values.toList();

  Announcement? byId(String id) => _items[id];
}

final announcementRepositoryProvider =
    Provider<AnnouncementRepository>((ref) => const AnnouncementRepository());

final announcementProvider =
    FutureProvider.family<Announcement?, String>((ref, id) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return ref.watch(announcementRepositoryProvider).byId(id);
});

final pushServiceProvider = Provider<PushService>((ref) => PushService());
