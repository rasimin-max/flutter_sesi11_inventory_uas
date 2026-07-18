import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _data = {};
  String _nama = 'Pengguna';
  String _foto = '';

  int _number(String key) => int.tryParse(_data[key].toString()) ?? 0;

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nama = prefs.getString('nama') ?? 'Pengguna';
      _foto = prefs.getString('foto') ?? '';
    });
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ApiService.getDashboard();
    if (!mounted) return;

    setState(() {
      _loading = false;
      if (result.success) {
        _data = result.data ?? {};
      } else {
        _error = result.message;
      }
    });
  }

  Future<void> _refresh() async {
    await _loadUser();
    await _loadDashboard();
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDashboard();
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF155EEF), Color(0xFF063BCE)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang,',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  _nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kelola inventaris dengan mudah',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: _foto.isNotEmpty
                  ? NetworkImage('${ApiConfig.profileUrl}$_foto')
                  : null,
              child: _foto.isEmpty
                  ? const Icon(Icons.person, size: 44)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
      String title,
      int value,
      IconData icon,
      Color accent,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: accent.withOpacity(0.18),
            child: Icon(icon, color: accent),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF667085)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Inventaris',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                if (_error != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.error_outline),
                      title: Text(_error!),
                      trailing: IconButton(
                        onPressed: _loadDashboard,
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  )
                else
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.15,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _card(
                        'Total Barang',
                        _number('total_barang'),
                        Icons.inventory_2,
                        const Color(0xFF155EEF),
                      ),
                      _card(
                        'Total Stok',
                        _number('total_stok'),
                        Icons.bar_chart,
                        const Color(0xFF7A5AF8),
                      ),
                      _card(
                        'Kondisi Baik',
                        _number('kondisi_baik'),
                        Icons.check_circle,
                        const Color(0xFF12B76A),
                      ),
                      _card(
                        'Perbaikan',
                        _number('kondisi_perbaikan'),
                        Icons.build_circle,
                        const Color(0xFFF79009),
                      ),
                    ],
                  ),
                if (_number('kondisi_rusak') > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE4E2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFD92D20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Barang Rusak',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          _number('kondisi_rusak').toString(),
                          style: const TextStyle(
                            color: Color(0xFFD92D20),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
