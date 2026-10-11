# AI Challenge — Minggu 6 (Authentication, Security & FCM)

## Prompt yang Digunakan

```
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

## Verifikasi (Checklist)

| Butir | Temuan | Tindakan |
|---|---|---|
| Background handler top-level + `@pragma('vm:entry-point')`? | Ya | OK |
| `onTokenRefresh` mengirim token baru ke backend? | Ya (via callback `onToken`) | OK |
| Foreground memakai local notification manual? | Ya (Android/iOS) | OK |
| Klik dari 3 state masuk rute yang benar? | `routeFromMessage` murni + `go(route)` | Diuji + tabel matriks |
| Token/secret tidak di-hardcode / di-log penuh? | Token ditampilkan terpotong 12 karakter | OK |
| `flutter analyze` & `flutter test` lolos | Ya | OK |

## Perbedaan Android 13+ vs iOS

| Aspek | Android 13+ | iOS |
|---|---|---|
| Izin notifikasi | Runtime (`POST_NOTIFICATIONS`) via `requestPermission` | Dialog saat `requestPermission` / pertama tampil |
| Channel | Wajib `AndroidNotificationDetails(channel)` | Tidak ada konsep channel |
| APNs | Tidak perlu | Perlu APNs key + capability Push di Xcode |

## Bagian yang TIDAK BOLEH mengakses BuildContext

- `firebaseMessagingBackgroundHandler` (isolate terpisah).
- Di dalam `PushService` (layer messaging), navigasi dilakukan lewat
  callback `go(route)` yang disuntikkan, bukan memanggil `context` langsung.

## Perbaikan Manual / Keputusan Teknis

1. **`FirebaseMessaging.instance` diakses lazy** — sebelumnya dibuat di
   constructor `PushService` yang membuat aplikasi crash di web/tanpa Firebase.
   Sekarang hanya diakses saat `FIREBASE_ENABLED=true`.
2. **Guard router menunggu auth selesai loading** — agar deep link
   (`/pengumuman/3`) tidak salah dialihkan ke `/login` saat status auth
   belum terbaca.
3. **Mode simulasi** — `simulateForegroundMessage()` meniru pesan
   `notification + data` sehingga deep link dapat didemonstrasikan tanpa
   Firebase. `FIREBASE_ENABLED=true` mengaktifkan jalur Firebase nyata.
4. **Interceptor refresh sekali** — flag `retried_after_refresh` mencegah loop
   refresh tak berujung; bila refresh gagal, token dibersihkan (paksa login).

## Matriks Pengujian Tiga App State

| State | Yang diharapkan | Cara uji | Hasil |
|---|---|---|---|
| Foreground | Banner lokal muncul, klik → `/pengumuman/3` | Aplikasi terbuka, kirim dari console | Teralih ke `/pengumuman/3` |
| Background | Banner sistem, klik → rute benar | Home, kirim, klik banner | Rute benar |
| Terminated | Buka ke rute via `getInitialMessage` | Swipe-close, kirim, klik banner | Rute benar |
