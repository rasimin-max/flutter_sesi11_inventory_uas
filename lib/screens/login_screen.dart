import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: result.success
            ? Colors.green
            : Colors.red.shade700,
      ),
    );

    if (!result.success || result.data == null) {
      return;
    }

    final userData = result.data!;

    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'is_logged_in',
      _rememberMe,
    );

    await prefs.setString(
      'nama',
      userData['nama']?.toString() ?? '',
    );

    await prefs.setString(
      'email',
      userData['email']?.toString() ?? '',
    );

    await prefs.setString(
      'foto',
      userData['foto']?.toString() ?? '',
    );

    await prefs.setString(
      'token',
      userData['token']?.toString() ?? '',
    );

    await prefs.setString(
      'user_id',
      userData['id']?.toString() ?? '',
    );

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
          (route) => false,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF155EEF),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.blue.shade100,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF155EEF),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
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
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 330,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF155EEF),
                    Color(0xFF063BCE),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(42),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                36,
                20,
                28,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      size: 52,
                      color: Color(0xFF155EEF),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'InventoryKu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Kelola inventaris dengan mudah',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat Datang',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Silakan masuk untuk melanjutkan',
                            style: TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 26),
                          TextFormField(
                            controller: _emailController,
                            keyboardType:
                            TextInputType.emailAddress,
                            textInputAction:
                            TextInputAction.next,
                            decoration: _inputDecoration(
                              label: 'Email',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              final email =
                                  value?.trim() ?? '';

                              if (email.isEmpty) {
                                return 'Email wajib diisi';
                              }

                              if (!email.contains('@') ||
                                  !email.contains('.')) {
                                return 'Format email tidak valid';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            textInputAction:
                            TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!_isLoading) {
                                _login();
                              }
                            },
                            decoration: _inputDecoration(
                              label: 'Password',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible =
                                    !_passwordVisible;
                                  });
                                },
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Password wajib diisi';
                              }

                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                activeColor:
                                const Color(0xFF155EEF),
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe =
                                        value ?? true;
                                  });
                                },
                              ),
                              const Expanded(
                                child: Text(
                                  'Ingat saya',
                                  style: TextStyle(
                                    color:
                                    Color(0xFF475467),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Fitur lupa password dapat dikembangkan sebagai fitur tambahan.',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Lupa password?',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed:
                              _isLoading ? null : _login,
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF155EEF),
                                disabledBackgroundColor:
                                Colors.blue.shade200,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    16,
                                  ),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : const Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                                children: [
                                  Icon(Icons.login),
                                  SizedBox(width: 10),
                                  Text(
                                    'MASUK',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Belum punya akun?',
                                style: TextStyle(
                                  color: Color(0xFF667085),
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sistem Informasi Inventaris Barang',
                    style: TextStyle(
                      color: Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Flutter • PHP REST API • MySQL',
                    style: TextStyle(
                      color: Color(0xFF98A2B3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}