import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      // Success - Handled by AuthWrapper
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal masuk. Silakan coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              // App Branding
              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0056D2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Clipboard',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Sinkronisasi cloud tingkat lanjut untuk produktivitas tanpa hambatan. Akses riwayat clipboard Anda di mana saja dengan enkripsi end-to-end.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF424654),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 64),
              
              // Login Section
              Text(
                'Masuk untuk Sinkronisasi',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191C1E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kelola data clipboard Anda dengan aman.',
                style: TextStyle(color: Color(0xFF737785)),
              ),
              const SizedBox(height: 32),
              
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
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
                      Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        height: 24,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.login),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Masuk dengan Google',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lupa Kata Sandi?',
                    style: TextStyle(color: const Color(0xFF0056D2), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              const Divider(color: Color(0xFFECEEF0)),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? '),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Daftar Akun Baru',
                      style: TextStyle(color: const Color(0xFF0056D2), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFooterLink('Syarat Layanan'),
                  const Text(' • '),
                  _buildFooterLink('Kebijakan Privasi'),
                  const Text(' • '),
                  _buildFooterLink('Pusat Bantuan'),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String label) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF737785)),
      ),
    );
  }
}
