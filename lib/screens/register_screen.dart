import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _konfirmasi = TextEditingController();

  XFile? _foto;
  Uint8List? _fotoBytes;
  bool _loading = false;
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    _password.dispose();
    _konfirmasi.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1000,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _foto = picked;
        _fotoBytes = bytes;
      });
    }
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final result = await ApiService.register(
      nama: _nama.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      foto: _foto,
      fotoBytes: _fotoBytes,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );

    if (result.success) Navigator.pop(context);
  }

  InputDecoration _decoration(
      String label,
      IconData icon, {
        Widget? suffix,
      }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF155EEF)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.blue.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF155EEF),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF155EEF), Color(0xFF063BCE)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 5, 8, 0),
                    child: Text(
                      'Lengkapi data dan unggah foto profil',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF155EEF),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 58,
                              backgroundColor: const Color(0xFFE9EFFF),
                              backgroundImage: _fotoBytes != null
                                  ? MemoryImage(_fotoBytes!)
                                  : null,
                              child: _fotoBytes == null
                                  ? const Icon(
                                Icons.person,
                                size: 70,
                                color: Color(0xFF7294E8),
                              )
                                  : null,
                            ),
                          ),
                          Material(
                            color: const Color(0xFF155EEF),
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: _pilihFoto,
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Foto Profil',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const Text(
                        'JPG, PNG, WEBP maksimal 2 MB',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: _nama,
                        decoration: _decoration(
                          'Nama lengkap',
                          Icons.person_outline,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Nama wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _decoration(
                          'Email',
                          Icons.email_outlined,
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Email wajib diisi';
                          if (!value.contains('@')) return 'Email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: !_passwordVisible,
                        decoration: _decoration(
                          'Password',
                          Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () => setState(
                                  () => _passwordVisible = !_passwordVisible,
                            ),
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password wajib diisi';
                          }
                          if (v.length < 6) return 'Minimal 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _konfirmasi,
                        obscureText: !_confirmVisible,
                        decoration: _decoration(
                          'Konfirmasi password',
                          Icons.verified_user_outlined,
                          suffix: IconButton(
                            onPressed: () => setState(
                                  () => _confirmVisible = !_confirmVisible,
                            ),
                            icon: Icon(
                              _confirmVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (v) => v != _password.text
                            ? 'Konfirmasi password tidak sama'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: _loading ? null : _register,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF155EEF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                              : const Text(
                            'REGISTER',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
