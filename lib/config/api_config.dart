class ApiConfig {
  // ===========================
  // BASE URL
  // ===========================

  /// HP Android (Samsung S25)
  static const String baseUrl =
      'http://10.138.119.36:8080/uas_inventory_api';

  /*
  Jika memakai Android Emulator gunakan:

  static const String baseUrl =
      'http://10.0.2.2:8080/uas_inventory_api';

  Jika memakai Flutter Web (Chrome) gunakan:

  static const String baseUrl =
      'http://localhost:8080/uas_inventory_api';
  */

  // ===========================
  // AUTH
  // ===========================

  static const String login =
      '$baseUrl/auth/login.php';

  static const String register =
      '$baseUrl/auth/register.php';

  // ===========================
  // DASHBOARD
  // ===========================

  static const String dashboard =
      '$baseUrl/dashboard.php';

  // ===========================
  // BARANG
  // ===========================

  static const String getBarang =
      '$baseUrl/barang/get_barang.php';

  static const String detailBarang =
      '$baseUrl/barang/detail_barang.php';

  static const String cariBarang =
      '$baseUrl/barang/cari_barang.php';

  static const String tambahBarang =
      '$baseUrl/barang/tambah_barang.php';

  static const String editBarang =
      '$baseUrl/barang/edit_barang.php';

  static const String hapusBarang =
      '$baseUrl/barang/hapus_barang.php';

  // ===========================
  // IMAGE
  // ===========================

  /// Upload gambar barang
  static const String uploadUrl =
      '$baseUrl/uploads/';

  /// Foto profil user
  static const String profileUrl =
      '$baseUrl/uploads/profile/';

  // ===========================
  // TIMEOUT
  // ===========================

  static const Duration timeout =
  Duration(seconds: 30);
}