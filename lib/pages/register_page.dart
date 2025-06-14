import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final namaLengkapController = TextEditingController();
  final nomorHPController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false; // Tambahkan ini
  String error = '';

  Future<void> register() async {
    setState(() {
      error = '';
      isLoading = true;
    });

    if (namaLengkapController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      setState(() {
        error = 'Semua field * wajib diisi';
        isLoading = false;
      });
      return;
    }

    final result = await ApiService.register(
      namaLengkapController.text,
      emailController.text,
      passwordController.text,
      nomorHPController.text,
    );

    if (result['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['data']['token']);
      await prefs.setInt('user_id', result['data']['id']);

      final profileResult = await ApiService.getUserDetail();
      if (profileResult['success']) {
        final user = profileResult['data'];
        await prefs.setString('name', user['name'] ?? '');
        await prefs.setString('email', user['email'] ?? '');
      }

      if (!mounted) return;
      setState(() => isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      setState(() {
        error = result['error'] ?? 'Terjadi kesalahan, silakan coba lagi';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book, color: Colors.green, size: 80),
              const SizedBox(height: 12),
              const Text(
                "HobiBaca",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Registrasi",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: namaLengkapController,
                enabled: !isLoading,
                decoration: _inputDecoration("Nama Lengkap*"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                enabled: !isLoading,
                decoration: _inputDecoration("Email *"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                enabled: !isLoading,
                decoration: _inputDecoration("Password *").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nomorHPController,
                enabled: !isLoading,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Nomor HP"),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "REGISTRASI",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun klik "),
                  GestureDetector(
                    onTap: () {
                      if (!isLoading) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}