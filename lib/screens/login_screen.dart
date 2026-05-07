import 'package:flutter/material.dart';
import 'package:clipboard_history_manager/services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    final user = await FirebaseService().signInWithGoogle();
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      // Success
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal masuk. Pastikan SHA-1 sudah terdaftar di Firebase.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // Tambahkan scroll agar tidak overflow
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                // App Logo
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0056D2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.assignment_turned_in_rounded, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Clipboard Manager',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF191C1E),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Simpan riwayat clipboard Anda secara aman di cloud.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Color(0xFF424654),
                  ),
                ),
                const SizedBox(height: 64),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF191C1E),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFECEEF0)),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Menggunakan URL alternatif yang lebih stabil
                        Image.network(
                          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                          height: 24,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.login),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Masuk dengan Google',
                          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
