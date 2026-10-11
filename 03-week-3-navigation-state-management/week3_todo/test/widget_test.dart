import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/main.dart';
import 'package:week3_todo/providers/stats_provider.dart';
import 'package:week3_todo/router.dart';

class FakeStatsNotifier extends StatsNotifier {
  @override
  Future<List<AcademicStat>> build() async => const [
        AcademicStat('Total Tugas', '8'),
        AcademicStat('Tugas Selesai', '3'),
        AcademicStat('Kehadiran', '92%'),
      ];
}

class FailingStatsNotifier extends StatsNotifier {
  @override
  Future<List<AcademicStat>> build() async {
    throw Exception('Gagal terhubung ke server statistik');
  }
}

void main() {
  setUp(() => router.go('/'));

  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Belum ada tugas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });

  testWidgets('filter Aktif menyembunyikan tugas selesai', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Tugas A');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aktif'));
    await tester.pumpAndSettle();
    expect(find.text('Tugas A'), findsNothing);

    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    expect(find.text('Tugas A'), findsOneWidget);
  });

  testWidgets('navigasi ke Statistik menampilkan data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(FakeStatsNotifier.new),
        ],
        child: const MyApp(),
      ),
    );

    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();

    expect(find.text('Total Tugas'), findsOneWidget);
    expect(find.text('Kehadiran'), findsOneWidget);
    expect(find.text('92%'), findsOneWidget);
  });

  testWidgets('Statistik menampilkan error + tombol Coba lagi',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(FailingStatsNotifier.new),
        ],
        child: const MyApp(),
      ),
    );

    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal memuat'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}
