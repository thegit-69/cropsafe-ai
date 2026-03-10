import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dashboard_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D5C2F),
                  Color(0xFF14753D),
                  Color(0xFF1A8C4A),
                ],
              ),
            ),
          ),

          // Background overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.50,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0D5C2F).withValues(alpha: 0.9),
                    const Color(0xFF1A8C4A).withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // ── Top branding section ──────────────────────────────
                SizedBox(
                  height: size.height * 0.38,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF8BC34A,
                          ).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Color(0xFFA8D85B),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'CropSafe AI',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'SMART FARMING ASSISTANT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(
                            0xFF8BC34A,
                          ).withValues(alpha: 0.85),
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── White bottom card ─────────────────────────────────
                Expanded(
                  child: Container(
                    width: size.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 48),

                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue managing your crops',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Google Sign-In button (SVG asset)
                          GestureDetector(
                            onTap: _isLoading ? null : _handleGoogleSignIn,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 56,
                                    child: Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF14753D),
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    ),
                                  )
                                : SvgPicture.asset(
                                    'assets/images/android_light_rd_SU.svg',
                                    height: 56,
                                  ),
                          ),

                          const Spacer(),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Text(
                              'By signing in, you agree to our Terms & Privacy Policy',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
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
        ],
      ),
    );
  }
}
