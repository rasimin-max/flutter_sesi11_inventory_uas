import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../models/barang.dart';

class ApiResult<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  static Map<String, dynamic> _decodeResponse(
      http.Response response,
      ) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Format respons server tidak valid',
      };
    } catch (_) {
      return {
        'status': false,
        'message':
        'Respons server tidak valid. Isi respons: ${response.body}',
      };
    }
  }

  static String _friendlyError(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('no route to host')) {
      return 'Tidak dapat terhubung ke server. Periksa Wi-Fi, alamat IP, Apache, dan firewall.';
    }

    if (text.contains('timeoutexception')) {
      return 'Koneksi ke server terlalu lama. Silakan coba lagi.';
    }

    if (text.contains('connection refused')) {
      return 'Server menolak koneksi. Pastikan Apache aktif.';
    }

    return 'Terjadi kesalahan: $error';
  }

  // =========================================================
  // LOGIN
  // =========================================================

  static Future<ApiResult<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(ApiConfig.login),
        body: {
          'email': email.trim(),
          'password': password,
        },
      )
          .timeout(_timeout);

      final json = _decodeResponse(response);

      return ApiResult<Map<String, dynamic>>(
        success: json['status'] == true,
        message: json['message']?.toString() ?? 'Login gagal',
        data: json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : null,
      );
    } catch (error) {
      return ApiResult<Map<String, dynamic>>(
        success: false,
        message: _friendlyError(error),
      );
    }
  }

  // =========================================================
  // REGISTER + FOTO PROFIL
  // =========================================================

  static Future<ApiResult<Map<String, dynamic>>> register({
    required String nama,
    required String email,
    required String password,
    XFile? foto,
    Uint8List? fotoBytes,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.register),
      );

      request.fields.addAll({
        'nama': nama.trim(),
        'email': email.trim(),
        'password': password,
      });

      if (foto != null) {
        final bytes = fotoBytes ?? await foto.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            bytes,
            filename: foto.name,
          ),
        );
      }

      final streamedResponse =
      await request.send().timeout(_timeout);

      final response =
      await http.Response.fromStream(streamedResponse);

      final json = _decodeResponse(response);

      return ApiResult<Map<String, dynamic>>(
        success: json['status'] == true,
        message:
        json['message']?.toString() ?? 'Registrasi gagal',
        data: json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : null,
      );
    } catch (error) {
      return ApiResult<Map<String, dynamic>>(
        success: false,
        message: _friendlyError(error),
      );
    }
  }

  // =========================================================
  // DASHBOARD
  // =========================================================

  static Future<ApiResult<Map<String, dynamic>>>
  getDashboard() async {
    try {
      final response = await http
          .get(
        Uri.parse(ApiConfig.dashboard),
      )
          .timeout(_timeout);

      final json = _decodeResponse(response);

      return ApiResult<Map<String, dynamic>>(
        success: json['status'] == true,
        message: json['message']?.toString() ??
            'Gagal mengambil data dashboard',
        data: json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : null,
      );
    } catch (error) {
      return ApiResult<Map<String, dynamic>>(
        success: false,
        message: _friendlyError(error),
      );
    }
  }

  // =========================================================
  // AMBIL DATA BARANG / PENCARIAN
  // =========================================================

  static Future<ApiResult<List<Barang>>> getBarang({
    String keyword = '',
  }) async {
    try {
      final Uri uri;

      if (keyword.trim().isEmpty) {
        uri = Uri.parse(ApiConfig.getBarang);
      } else {
        uri = Uri.parse(ApiConfig.cariBarang).replace(
          queryParameters: {
            'keyword': keyword.trim(),
          },
        );
      }

      final response = await http
          .get(uri)
          .timeout(_timeout);

      final json = _decodeResponse(response);

      final rawData = json['data'];

      final List<Barang> barangList = [];

      if (rawData is List) {
        for (final item in rawData) {
          if (item is Map<String, dynamic>) {
            barangList.add(
              Barang.fromJson(item),
            );
          } else if (item is Map) {
            barangList.add(
              Barang.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          }
        }
      }

      return ApiResult<List<Barang>>(
        success: json['status'] == true,
        message: json['message']?.toString() ??
            'Gagal mengambil data barang',
        data: barangList,
      );
    } catch (error) {
      return ApiResult<List<Barang>>(
        success: false,
        message: _friendlyError(error),
        data: const [],
      );
    }
  }

  // =========================================================
  // DETAIL BARANG
  // =========================================================

  static Future<ApiResult<Barang>> getDetailBarang(
      int id,
      ) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.detailBarang}?id=$id',
      );

      final response = await http
          .get(uri)
          .timeout(_timeout);

      final json = _decodeResponse(response);

      Barang? barang;

      if (json['data'] is Map<String, dynamic>) {
        barang = Barang.fromJson(
          json['data'] as Map<String, dynamic>,
        );
      } else if (json['data'] is Map) {
        barang = Barang.fromJson(
          Map<String, dynamic>.from(
            json['data'] as Map,
          ),
        );
      }

      return ApiResult<Barang>(
        success: json['status'] == true,
        message: json['message']?.toString() ??
            'Gagal mengambil detail barang',
        data: barang,
      );
    } catch (error) {
      return ApiResult<Barang>(
        success: false,
        message: _friendlyError(error),
      );
    }
  }

  // =========================================================
  // TAMBAH / EDIT BARANG
  // =========================================================

  static Future<ApiResult<void>> simpanBarang({
    int? id,
    required String kode,
    required String nama,
    required String kategori,
    required String stok,
    required String lokasi,
    required String kondisi,
    XFile? gambar,
    Uint8List? gambarBytes,
  }) async {
    try {
      final url = id == null
          ? ApiConfig.tambahBarang
          : ApiConfig.editBarang;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      if (id != null) {
        request.fields['id'] = id.toString();
      }

      request.fields.addAll({
        'kode_barang': kode.trim(),
        'nama_barang': nama.trim(),
        'kategori': kategori.trim(),
        'stok': stok.trim(),
        'lokasi': lokasi.trim(),
        'kondisi': kondisi.trim(),
      });

      if (gambar != null) {
        final bytes =
            gambarBytes ?? await gambar.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'gambar',
            bytes,
            filename: gambar.name,
          ),
        );
      }

      final streamedResponse =
      await request.send().timeout(_timeout);

      final response =
      await http.Response.fromStream(streamedResponse);

      final json = _decodeResponse(response);

      return ApiResult<void>(
        success: json['status'] == true,
        message: json['message']?.toString() ??
            'Gagal menyimpan barang',
      );
    } catch (error) {
      return ApiResult<void>(
        success: false,
        message: _friendlyError(error),
      );
    }
  }

  // =========================================================
  // HAPUS BARANG
  // =========================================================

  static Future<ApiResult<void>> hapusBarang(
      int id,
      ) async {
    try {
      final response = await http
          .post(
        Uri.parse(ApiConfig.hapusBarang),
        body: {
          'id': id.toString(),
        },
      )
          .timeout(_timeout);

      final json = _decodeResponse(response);

      return ApiResult<void>(
        success: json['status'] == true,
        message: json['message']?.toString() ??
            'Gagal menghapus barang',
      );
    } catch (error) {
      return ApiResult<void>(
        success: false,
        message: _friendlyError(error),
      );
    }
  }
}