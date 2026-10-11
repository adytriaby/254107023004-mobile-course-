/// Konstanta rute terpusat agar deep link FCM dan GoRouter memakai nilai sama.
class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const debug = '/debug';
  static const announcementPattern = '/pengumuman/:id';

  static String announcement(String id) => '/pengumuman/$id';
}

/// Mengubah data payload FCM menjadi rute yang valid (fungsi murni, mudah diuji).
String routeFromMessage(Map<String, dynamic> data) {
  final raw = (data['route'] ?? '/').toString().trim();
  if (raw.isEmpty) return AppRoutes.home;
  return raw.startsWith('/') ? raw : '/$raw';
}
