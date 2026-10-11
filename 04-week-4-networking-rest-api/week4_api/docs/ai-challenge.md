# AI Challenge — Minggu 4 (Networking & REST API)

## Prompt yang Digunakan

```
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

## Hasil AI (Ringkas)

AI menghasilkan model `Comment` dengan `fromJson`, method `fetchComments` pada
repository, dan pemetaan `DioExceptionType` ke pesan pengguna. Skema sudah
mengikuti pola repository + provider.

## Verifikasi (Checklist)

| Butir | Temuan | Tindakan |
|---|---|---|
| UI tidak memanggil Dio langsung | OK, semua lewat repository + provider | OK |
| `fromJson` aman null | Pakai `(json['id'] as num?)?.toInt() ?? 0` | Diperkuat: tipe angka bisa `String` di API nyata, ditambahkan helper `_asInt` |
| Semua `DioExceptionType` dipetakan | Hanya sebagian | Ditambahkan mapping timeout, connectionError, badResponse (401/403/404/500) |
| `baseUrl`/timeout terpusat | OK di `api_client.dart` | OK |
| Test menguji edge case (field hilang) | AI hanya happy path | Ditambahkan test field hilang + tipe angka campuran (`'3'` sebagai String) |
| `flutter analyze` & `flutter test` lolos | Awalnya tidak | Diperbaiki hingga bersih |

## Perbaikan Manual yang Dilakukan

1. **Cast angka defensif**: AI memakai `as num?` yang tetap crash bila API
   mengirim angka sebagai String (`"id": "3"`). Diganti helper `_asInt` yang
   menerima `num` maupun `String`.
2. **Pemetaan error lengkap**: menambahkan pemisahan 401/403 vs 404 vs 5xx.
3. **`retry` Riverpod 3 dinonaktifkan** pada provider agar error final dan
   test tidak menggantung menunggu retry otomatis.
4. **Helper test** (`readPostsOnce`, `readPostsErrorOnce`) memakai listener +
   completer agar test tidak menunggu retry.
5. **Guard pagination**: `if (state.isLoadingMore || !state.hasMore) return;`
   mencegah request ganda saat scroll listener terpanggil berkali-kali.

## Keputusan Teknis

- **Repository pattern**: `PostRepository` adalah satu-satunya pintu ke API;
  exception dibiarkan naik agar provider mengubahnya menjadi `AsyncError`.
- **Dio terpusat**: base URL, timeout, dan interceptor logging hanya di
  `api_client.dart`, tidak tersebar di tiap method.
- **Pagination server-side** (`_page`/`_limit`) dengan data lama dipertahankan
  saat memuat halaman berikutnya atau saat error.
