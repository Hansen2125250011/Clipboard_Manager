import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clipboard_history_manager/services/firebase_service.dart';
import 'package:clipboard_history_manager/screens/history_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;

  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _handleEmailAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Silakan isi email dan password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isRegistering) {
        await _firebaseService.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _firebaseService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _firebaseService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        );
      }
    } catch (e) {
      _showError('Gagal masuk dengan Google.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? theme.colorScheme.primary : const Color(0xFF0056D2);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background Design Element
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // App Icon/Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.security_rounded, size: 48, color: primaryColor),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _isRegistering ? 'Daftar Akun Baru' : 'Masuk & Sinkronisasi',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Amankan riwayat clipboard Anda dan akses dari perangkat mana pun.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: isDark ? Colors.white54 : const Color(0xFF424654),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Alamat Email',
                    hint: 'nama@email.com',
                    icon: Icons.alternate_email_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Kata Sandi',
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    isDark: isDark,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),

                  // Main Auth Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : Text(
                              _isRegistering ? 'Daftar Sekarang' : 'Masuk',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: isDark ? Colors.white12 : const Color(0xFFECEEF0))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'atau masuk dengan',
                          style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white38 : const Color(0xFFC3C6D6)),
                        ),
                      ),
                      Expanded(child: Divider(color: isDark ? Colors.white12 : const Color(0xFFECEEF0))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_"G"_logo.svg/1200px-Google_"G"_logo.svg.png',
                        height: 24,
                      ),
                      label: Text(
                        'Lanjutkan dengan Google',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFECEEF0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Toggle Register/Login
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _isRegistering = !_isRegistering),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(fontSize: 15, color: isDark ? Colors.white70 : const Color(0xFF424654)),
                          children: [
                            TextSpan(text: _isRegistering ? 'Sudah punya akun? ' : 'Belum punya akun? '),
                            TextSpan(
                              text: _isRegistering ? 'Masuk' : 'Daftar',
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white54 : const Color(0xFF737785),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: GoogleFonts.inter(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white24 : const Color(0xFFC3C6D6)),
            prefixIcon: Icon(icon, color: isDark ? theme.colorScheme.primary : const Color(0xFF0056D2), size: 20),
            filled: true,
            fillColor: isDark ? theme.colorScheme.surfaceContainer : const Color(0xFFF7F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFECEEF0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFECEEF0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? theme.colorScheme.primary : const Color(0xFF0056D2), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
