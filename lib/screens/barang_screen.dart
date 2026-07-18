import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/barang.dart';
import '../services/api_service.dart';
import 'form_barang_screen.dart';

class BarangScreen extends StatefulWidget {
  const BarangScreen({super.key});

  @override
  State<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends State<BarangScreen> {
  final _search = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Barang> _items = [];

  Future<void> _load([String keyword = '']) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService.getBarang(keyword: keyword);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _items = result.data ?? [];
      } else {
        _error = result.message;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openForm([Barang? barang]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormBarangScreen(barang: barang),
      ),
    );
    if (changed == true) _load(_search.text);
  }

  Future<void> _hapus(Barang item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus barang?'),
        content: Text('${item.kodeBarang} - ${item.namaBarang}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final result = await ApiService.hapusBarang(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    if (result.success) _load(_search.text);
  }

  Widget _image(Barang item) {
    if (item.gambar == null || item.gambar!.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.inventory_2));
    }
    return CircleAvatar(
      backgroundImage: NetworkImage('${ApiConfig.uploadUrl}${item.gambar}'),
      onBackgroundImageError: (_, __) {},
      child: const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Cari kode, nama, kategori, atau lokasi',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    _search.clear();
                    _load();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
              onSubmitted: _load,
              onChanged: (value) {
                if (value.isEmpty) _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _items.isEmpty
                        ? const Center(child: Text('Data tidak ditemukan'))
                        : RefreshIndicator(
                            onRefresh: () => _load(_search.text),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                              itemCount: _items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return Card(
                                  child: ListTile(
                                    leading: _image(item),
                                    title: Text(
                                      '${item.kodeBarang} - ${item.namaBarang}',
                                    ),
                                    subtitle: Text(
                                      '${item.kategori} | Stok: ${item.stok}\n'
                                      '${item.lokasi} | ${item.kondisi}',
                                    ),
                                    isThreeLine: true,
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') _openForm(item);
                                        if (value == 'hapus') _hapus(item);
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem(
                                          value: 'hapus',
                                          child: Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _openForm(item),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
