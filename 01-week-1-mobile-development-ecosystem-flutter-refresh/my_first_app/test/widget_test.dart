import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';

void main() {
  testWidgets('Aplikasi menampilkan profil mahasiswa', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Profil Mahasiswa'), findsOneWidget);
    expect(find.text('Adytria Bayu Ramadani'), findsOneWidget);
    expect(find.text('254107023004'), findsOneWidget);
    expect(find.text('D4 Teknik Informatika'), findsOneWidget);
    expect(find.text('Politeknik Negeri Malang'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
  });
}
