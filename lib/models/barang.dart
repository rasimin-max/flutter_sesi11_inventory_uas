class Barang {
  final int id;
  final String kodeBarang;
  final String namaBarang;
  final String kategori;
  final int stok;
  final String lokasi;
  final String kondisi;
  final String? gambar;

  const Barang({
    required this.id,
    required this.kodeBarang,
    required this.namaBarang,
    required this.kategori,
    required this.stok,
    required this.lokasi,
    required this.kondisi,
    this.gambar,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: int.tryParse(json['id'].toString()) ?? 0,
      kodeBarang: json['kode_barang']?.toString() ?? '',
      namaBarang: json['nama_barang']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      lokasi: json['lokasi']?.toString() ?? '',
      kondisi: json['kondisi']?.toString() ?? 'Baik',
      gambar: json['gambar']?.toString(),
    );
  }
}
