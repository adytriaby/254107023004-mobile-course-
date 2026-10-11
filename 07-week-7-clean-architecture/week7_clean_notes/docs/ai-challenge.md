# AI Challenge — Minggu 7 (Clean Architecture)

## Prompt yang Digunakan

```
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

## Tabel Usulan AI vs Keputusan Final

| Aspek | Usulan AI | Keputusan Final | Alasan |
|---|---|---|---|
| Struktur | feature-first `features/<x>/{domain,data,presentation}` | Diadopsi | Satu fitur dapat dipahami/dihapus tanpa menyentuh fitur lain |
| Interface repository | di `domain`, impl di `data` | Diadopsi | Dependency rule: domain tidak tahu SQLite |
| Use case per CRUD | Buat use case untuk semua operasi | **Ditolak sebagian** | CRUD satu-baris cukup repository → notifier; use case hanya untuk operasi dengan aturan bisnis |
| Use case `AddNote` | (implisit) | Dibuat | Ada aturan bisnis: judul tidak boleh kosong & di-trim |
| Use case `SyncNotes` | (implisit) | Dibuat | Menggabungkan >1 operasi repository (countDirty + markAllSynced + upload) |
| Entity vs Model | entity murni, mapping di model | Diadopsi | Entity bebas `toMap/fromMap` |
| DI | provider Riverpod tanpa package DI | Diadopsi | Tidak perlu `get_it`, wiring di `presentation/providers` |

## Verifikasi (Checklist)

| Butir | Temuan | Tindakan |
|---|---|---|
| Interface di `domain`, impl di `data`? | Ya | OK |
| `domain` bebas import Flutter/Dio/SQLite/Firebase? | Ya | Dibuktikan grep = **0 baris** |
| Use case untuk tiap CRUD satu-baris? | AI mengusulkan; ditolak | Hanya `AddNote` & `SyncNotes` yang punya alasan bisnis |
| Entity bebas mapping? | Ya | Mapping hanya di `NoteModel` |
| DI terpusat di provider, widget tidak `new Repository()`? | Ya | OK |

## Hasil Tiga Grep Verifikasi

```
# 1. Presentation steril dari data mentah -> 0 baris
# 2. Domain + core steril dari framework -> 0 baris
# 3. flutter analyze -> No issues found! ; flutter test -> 8 test lulus
```

## Keputusan Teknis

- **Records Dart** (`({List<Note> notes, Failure? failure})`) agar sukses/gagal
  eksplisit tanpa exception bocor ke presentation.
- **`formatDate` di `lib/core/format.dart`** sebagai fungsi murni yang diuji
  tanpa widget.
- **Fitur kedua (auth)** juga dipecah domain/data/presentation agar tidak ada
  fitur bersih dan sisanya kotor.
- **Injeksi `openDb`** pada `NoteRepositoryImpl` untuk memudahkan test.
