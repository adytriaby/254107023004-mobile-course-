import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Statistik akademik yang dimuat secara asinkron.
class AcademicStat {
  const AcademicStat(this.label, this.value);

  final String label;
  final String value;
}

/// Simulasi pengambilan data statistik dari server.
///
/// `FORCE_ERROR=true` (dart-define) memaksa kegagalan agar UI error
/// dapat diuji dan di-screenshot secara deterministik.
class StatsNotifier extends AsyncNotifier<List<AcademicStat>> {
  static const bool forceError =
      bool.fromEnvironment('FORCE_ERROR', defaultValue: false);
  static const bool forceSuccess =
      bool.fromEnvironment('FORCE_SUCCESS', defaultValue: false);

  @override
  Future<List<AcademicStat>> build() async {
    await Future.delayed(const Duration(seconds: 2));
    final shouldFail =
        forceError || (!forceSuccess && Random().nextDouble() < 0.3);
    if (shouldFail) {
      throw Exception('Gagal terhubung ke server statistik');
    }
    return const [
      AcademicStat('Total Tugas', '8'),
      AcademicStat('Tugas Selesai', '3'),
      AcademicStat('Kehadiran', '92%'),
    ];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (forceError) {
        throw Exception('Gagal terhubung ke server statistik');
      }
      return const [
        AcademicStat('Total Tugas', '9'),
        AcademicStat('Tugas Selesai', '5'),
        AcademicStat('Kehadiran', '95%'),
      ];
    });
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<AcademicStat>>(
  StatsNotifier.new,
  retry: (retryCount, error) => null,
);
