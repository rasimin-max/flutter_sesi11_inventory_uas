import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nama = '';
  String email = '';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nama = prefs.getString('nama') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(
          radius: 48,
          child: Icon(Icons.person, size: 54),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            nama,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Center(child: Text(email)),
        const SizedBox(height: 28),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Tentang Aplikasi'),
            subtitle: Text(
              'Sistem Informasi Inventaris Barang\n'
              'UAS Mata Kuliah Aplikasi Nirkabel',
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('LOGOUT'),
        ),
      ],
    );
  }
}
