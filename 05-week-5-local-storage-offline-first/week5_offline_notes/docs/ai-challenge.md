# AI Challenge — Minggu 5 (Local Storage & Offline-First)

## Prompt yang Digunakan

```
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

## Tabel Perbandingan Storage (Keputusan Final)

| Kriteria | SharedPreferences | Hive | SQLite (sqflite) | Drift |
|---|---|---|---|---|
| Kompleksitas query | Tidak ada (key-value) | Rendah | Tinggi (SQL) | Sedang (API type-safe) |
| Kebutuhan relasi | Tidak | Terbatas | Ya | Ya |
| Reaktivitas (stream) | Tidak | Ya (`watch`) | Manual | Ya (built-in) |
| Type-safety | Tidak | Sebagian | Tidak | Ya (generated) |
| Boilerplate | Sangat rendah | Rendah | Sedang | Tinggi (build_runner) |
| Kemudahan testing | Mudah (mock) | Mudah | Sedang (butuh in-memory) | Mudah |
| **Pilihan untuk** | **Preferensi** | Cache objek | **Catatan (CRUD relasional)** | Query kompleks |

**Keputusan:** `SharedPreferences` untuk preferensi (tema, waktu terakhir dibuka)
dan **SQLite (sqflite)** untuk catatan. Alasan: catatan adalah koleksi
terstruktur dengan urutan (`updated_at`), butuh query/update parsial dan
dirty flag untuk antrean sync — menyimpan koleksi di SharedPreferences
(sebagai satu string JSON) rapuh dan lambat.

## Skema Tabel untuk 1000+ Catatan

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,          -- ISO-8601, untuk urut & konflik
  dirty INTEGER NOT NULL DEFAULT 0   -- 1 = belum tersinkron
);
-- Index untuk urutan dan antrean sync:
CREATE INDEX idx_notes_updated ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);
```

## Verifikasi (Checklist)

| Butir | Temuan | Tindakan |
|---|---|---|
| AI menempatkan daftar catatan di SharedPreferences? | Tidak, AI setuju pakai SQLite | OK |
| Skema mendukung antrean sync (dirty/updated_at)? | Ya, dirty + updated_at | OK |
| Klaim "real-time" didukung stream? | Hive/Drift memang punya stream; sqflite tidak | Ditambahkan `ref.invalidate` setelah mutasi |
| Estimasi boilerplate masuk akal? | Drift butuh build_runner (benar) | OK |
| Keputusan final boleh beda dari AI | Setuju: SharedPreferences + SQLite | OK |

## Perbaikan Manual / Keputusan Teknis

1. **Injeksi `openDb`** pada `NoteRepository` agar test memakai
   `FakeNoteRepository` tanpa menyentuh SQLite sungguhan.
2. **Dirty flag + `markAllSynced`** hanya dipanggil setelah "server" sukses,
   sehingga badge dirty akurat.
3. **Web support**: sqflite tidak jalan di web secara default; ditambahkan
   `sqflite_common_ffi_web` + COOP/COEP header agar aplikasi dapat dijalankan
   dan di-screenshot di browser.
4. **Aturan konflik** ditetapkan: *last-write-wins* berdasarkan `updated_at`.
