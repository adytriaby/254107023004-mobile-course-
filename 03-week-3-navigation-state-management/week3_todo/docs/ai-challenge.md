# AI Challenge — Minggu 3 (Navigation & State Management)

## Prompt yang Digunakan

```
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```

## Hasil AI (Ringkas)

AI menghasilkan `AsyncNotifier` dengan `build()` yang menunda 2 detik dan
melempar exception acak 30%, `AsyncValue.when` untuk tiga state, serta
tombol retry memakai `ref.invalidate`.

## Verifikasi (Checklist)

| Butir | Temuan | Tindakan |
|---|---|---|
| State diubah immutable (tidak `state.add()`) | AI sudah memakai list baru pada notifier ToDo | OK |
| `ref.watch` hanya di `build`, `ref.read` di callback | OK | OK |
| Ketiga state `AsyncValue` ditangani | OK, loading/error/data | OK |
| Provider bertipe eksplisit, tidak duplikat | OK | OK |
| Tidak memakai API Riverpod lama (`StateProvider`, `StateNotifierProvider`) | OK, memakai `AsyncNotifier` | OK |
| `flutter analyze` & `flutter test` lolos | Awalnya `retry` Riverpod 3 membuat test menggantung | Ditambahkan `retry: (_, _) => null` pada provider + helper test |
| Pesan error mentah ke pengguna | AI menampilkan `$err` mentah | Diganti pesan ramah "Gagal memuat data statistik. Periksa koneksi lalu coba lagi." |

## Perbaikan Manual yang Dilakukan

1. Menambahkan `retry: (retryCount, error) => null` agar error bersifat final
   dan test tidak menunggu retry otomatis Riverpod 3.
2. Mengganti pesan error teknis (`Exception: ...`) menjadi pesan ramah pengguna.
3. Menambahkan `forceError`/`forceSuccess` via `dart-define` agar demo dan
   screenshot state error/success deterministik (tidak bergantung `Random`).
4. Menambahkan override provider palsu (`FakeStatsNotifier`,
   `FailingStatsNotifier`) untuk menguji state success dan error tanpa delay 2 detik.

## Keputusan Teknis

- **Immutable state**: `TodoListNotifier` selalu mengganti list dengan salinan
  baru (`[...state]`) agar Riverpod mendeteksi perubahan.
- **Provider turunan**: filter dan statistik dihitung lewat `Provider` yang
  membaca `todoListProvider`, bukan disimpan sebagai state terpisah (single
  source of truth).
- **GoRouter + StatefulShellRoute**: `NavigationBar` berpindah antar branch
  tanpa kehilangan state halaman ToDo.
