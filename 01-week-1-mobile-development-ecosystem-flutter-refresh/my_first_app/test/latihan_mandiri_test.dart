import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/latihan_mandiri.dart';

void main() {
  group('hitungLuasPersegiPanjang', () {
    test('menghitung luas dengan nilai desimal', () {
      expect(hitungLuasPersegiPanjang(8.5, 4.0), 34.0);
    });

    test('mengembalikan 0 bila salah satu sisi 0', () {
      expect(hitungLuasPersegiPanjang(0, 10), 0);
    });

    test('menghitung luas bilangan bulat', () {
      expect(hitungLuasPersegiPanjang(5, 3), 15);
    });
  });

  group('Profil', () {
    test('mengembalikan email saat terisi', () {
      final profil = Profil(
        nama: 'Adytria Bayu Ramadani',
        nim: '254107023004',
        email: 'adytria.bayu@student.polinema.ac.id',
      );
      expect(profil.emailAtauDefault(),
          'adytria.bayu@student.polinema.ac.id');
    });

    test('menangani email null dengan aman', () {
      final profil = Profil(
        nama: 'Adytria Bayu Ramadani',
        nim: '254107023004',
      );
      expect(profil.emailAtauDefault(), 'Email belum diisi');
    });

    test('menangani email kosong/spasi dengan aman', () {
      final profil = Profil(
        nama: 'Adytria Bayu Ramadani',
        nim: '254107023004',
        email: '   ',
      );
      expect(profil.emailAtauDefault(), 'Email belum diisi');
    });
  });
}
