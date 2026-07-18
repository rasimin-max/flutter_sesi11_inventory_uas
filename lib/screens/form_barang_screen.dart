import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../models/barang.dart';
import '../services/api_service.dart';

class FormBarangScreen extends StatefulWidget {
  final Barang? barang;

  const FormBarangScreen({super.key, this.barang});

  @override
  State<FormBarangScreen> createState() => _FormBarangScreenState();
}

class _FormBarangScreenState extends State<FormBarangScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _kode;
  late final TextEditingController _nama;
  late final TextEditingController _kategori;
  late final TextEditingController _stok;
  late final TextEditingController _lokasi;

  String _kondisi = 'Baik';
  XFile? _gambar;
  Uint8List? _gambarBytes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final b = widget.barang;
    _kode = TextEditingController(text: b?.kodeBarang ?? '');
    _nama = TextEditingController(text: b?.namaBarang ?? '');
    _kategori = TextEditingController(text: b?.kategori ?? '');
    _stok = TextEditingController(text: b?.stok.toString() ?? '');
    _lokasi = TextEditingController(text: b?.lokasi ?? '');
    _kondisi = b?.kondisi ?? 'Baik';
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    _kategori.dispose();
    _stok.dispose();
    _lokasi.dispose();
    super.dispose();
  }

  Future<void> _pilihGambar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1200,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _gambar = picked;
        _gambarBytes = bytes;
      });
    }
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final result = await ApiService.simpanBarang(
      id: widget.barang?.id,
      kode: _kode.text.trim(),
      nama: _nama.text.trim(),
      kategori: _kategori.text.trim(),
      stok: _stok.text.trim(),
      lokasi: _lokasi.text.trim(),
      kondisi: _kondisi,
      gambar: _gambar,
      gambarBytes: _gambarBytes,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );

    if (result.success) Navigator.pop(context, true);
  }

  String? _required(String? value, String label) {
    return value == null || value.trim().isEmpty
        ? '$label wajib diisi'
        : null;
  }

  Widget _preview() {
    if (_gambarBytes != null) {
      return Image.memory(
        _gambarBytes!,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
      );
    }

    final old = widget.barang?.gambar;
    if (old != null && old.isNotEmpty) {
      return Image.network(
        '${ApiConfig.uploadUrl}$old',
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _EmptyImage(),
      );
    }

    return const _EmptyImage();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.barang != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Barang' : 'Tambah Barang'),
        backgroundColor: const Color(0xFF155EEF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InkWell(
                onTap: _pilihGambar,
                borderRadius: BorderRadius.circular(18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      _preview(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        color: Colors.black54,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Pilih gambar barang',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _kode,
                decoration: const InputDecoration(labelText: 'Kode barang'),
                validator: (v) => _required(v, 'Kode barang'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(labelText: 'Nama barang'),
                validator: (v) => _required(v, 'Nama barang'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kategori,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (v) => _required(v, 'Kategori'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stok,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah stok'),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null) return 'Stok harus angka';
                  if (n < 0) return 'Stok tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lokasi,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: (v) => _required(v, 'Lokasi'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _kondisi,
                decoration: const InputDecoration(labelText: 'Kondisi'),
                items: const [
                  DropdownMenuItem(value: 'Baik', child: Text('Baik')),
                  DropdownMenuItem(value: 'Rusak', child: Text('Rusak')),
                  DropdownMenuItem(
                    value: 'Perbaikan',
                    child: Text('Perbaikan'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _kondisi = value ?? 'Baik');
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _simpan,
                  icon: _loading
                      ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.save),
                  label: Text(_loading ? 'MENYIMPAN...' : 'SIMPAN'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF155EEF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyImage extends StatelessWidget {
  const _EmptyImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      color: const Color(0xFFE8EEFC),
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 70,
        color: Color(0xFF7294E8),
      ),
    );
  }
}
