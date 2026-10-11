// ignore_for_file: avoid_print
// Latihan Mandiri - Minggu 1
// Praktikum Pemrograman Mobile - JTI Polinema
//
// 1. Fungsi hitungLuasPersegiPanjang(double panjang, double lebar)
// 2. Kelas Profil dengan properti nama, nim, email (boleh null/empty)
// 3. Panggil keduanya dari main() dan tangani email kosong dengan aman.

/// Menghitung luas persegi panjang dari [panjang] dan [lebar].
double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

/// Profil mahasiswa. [email] boleh kosong (null).
class Profil {
  Profil({required this.nama, required this.nim, this.email});

  final String nama;
  final String nim;
  final String? email;

  /// Mengembalikan email, atau pesan aman bila email kosong/null.
  String emailAtauDefault() {
    final emailBersih = email?.trim() ?? '';
    if (emailBersih.isEmpty) {
      return 'Email belum diisi';
    }
    return emailBersih;
  }
}

void main() {
  const double panjang = 8.5;
  const double lebar = 4.0;
  final luas = hitungLuasPersegiPanjang(panjang, lebar);

  print('=== Latihan Mandiri Minggu 1 ===');
  print('Luas persegi panjang ($panjang x $lebar) = $luas');

  final profilLengkap = Profil(
    nama: 'Adytria Bayu Ramadani',
    nim: '254107023004',
    email: 'adytria.bayu@student.polinema.ac.id',
  );

  final profilTanpaEmail = Profil(
    nama: 'Adytria Bayu Ramadani',
    nim: '254107023004',
  );

  print('');
  print('Profil 1 (email terisi):');
  print('  Nama  : ${profilLengkap.nama}');
  print('  NIM   : ${profilLengkap.nim}');
  print('  Email : ${profilLengkap.emailAtauDefault()}');

  print('');
  print('Profil 2 (email kosong, ditangani aman):');
  print('  Nama  : ${profilTanpaEmail.nama}');
  print('  NIM   : ${profilTanpaEmail.nim}');
  print('  Email : ${profilTanpaEmail.emailAtauDefault()}');
}
