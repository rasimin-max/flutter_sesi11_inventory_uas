# InventoryKu - Flutter

## Penting
Folder ini berisi source utama Flutter. Cara paling aman:

1. Buka terminal pada folder induk.
2. Buat project Flutter standar:
   `flutter create inventory_uas`
3. Salin/replace folder `lib`, file `pubspec.yaml`, dan
   `android/app/src/main/AndroidManifest.xml` dari paket ini.
4. Jalankan:
   `flutter pub get`
5. Ubah IP pada `lib/config/api_config.dart`.
6. Jalankan aplikasi:
   `flutter run`

## URL berdasarkan perangkat
- HP fisik pada Wi-Fi yang sama:
  `http://IP_LAPTOP:8080/uas_inventory_api`
- Emulator Android:
  `http://10.0.2.2:8080/uas_inventory_api`
- Jika Apache memakai port 80, hapus `:8080`.

## Build APK
`flutter clean`
`flutter pub get`
`flutter build apk --release`

Hasil:
`build/app/outputs/flutter-apk/app-release.apk`
