import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/auth/presentation/screens/register_screen.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/features/home/presentation/screens/main_screen.dart';
import 'dart:ui';
import 'package:studyflow/l10n/app_localizations.dart';
import 'package:studyflow/core/providers/language_provider.dart';

/// `LoginScreen` is the login interface of the application.
/// This screen is designed independently and does not use the general `AppTheme` 
/// to maintain its Glassmorphism effect and signature Gradient background 
/// regardless of whether the user is in Light or Dark mode.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillFields)),
      );
      return;
    }

    final authViewModel = context.read<AuthViewmodel>();
    final error = await authViewModel.login(identifier, password);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      // Use addPostFrameCallback to ensure navigation happens AFTER
      // all widget rebuilds triggered by notifyListeners() have fully settled.
      // This prevents the mouse_tracker assertion failure that occurs when
      // Navigator.pop runs while the framework is still processing layout changes.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      });
    }
  }

  void _handleGoogleLogin() async {
    final authViewModel = context.read<AuthViewmodel>();
    final error = await authViewModel.loginWithGoogle();

    if (!mounted) return;

    if (error != null) {
      if (error != "Google sign-in cancelled") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      });
    }
  }

  static Widget _fallbackGoogleIcon(BuildContext context, Object error, StackTrace? stackTrace) {
    return const Text(
      'G',
      style: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final isLoading = context.watch<AuthViewmodel>().isLoading;
    final isLoading = context.select<AuthViewmodel, bool>((vm) => vm.isLoading);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDFBFB), Color(0xFFEBEDEE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Decorative Blurred Circles
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.tealAccent.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Glassmorphism effect overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Language switcher at the top right
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: _buildLanguageSelector(context),
            ),
          ),
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF203A43).withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.welcomeBack,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF203A43),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.welcomeSubtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Glassmorphism Card for Inputs
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _identifierController,
                            icon: Icons.person_outline,
                            hintText: 'example@gamil.com',
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            icon: Icons.lock_outline,
                            hintText: AppLocalizations.of(context)!.password,
                            isPassword: true,
                            isPasswordVisible: _isPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF203A43),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.login,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                           Row(
                            children: [
                              const Expanded(child: Divider(color: Colors.black12)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  AppLocalizations.of(context)!.or,
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Colors.black12)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : _handleGoogleLogin,
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Image(
                                  image: NetworkImage('https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png'),
                                  width: 20,
                                  height: 20,
                                  errorBuilder: _fallbackGoogleIcon,
                                ),
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.continueWithGoogle,
                                style: const TextStyle(
                                  color: Color(0xFF203A43),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.black26, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dontHaveAccount,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.signUp,
                            style: const TextStyle(
                              color: Color(0xFF203A43),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final currentLocale = languageProvider.locale;
    
    String currentFlag = '🇬🇧';
    if (currentLocale.languageCode == 'vi') {
      currentFlag = '🇻🇳';
    } else if (currentLocale.languageCode == 'de') {
      currentFlag = '🇩🇪';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: PopupMenuButton<Locale>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentFlag, style: const TextStyle(fontSize: 20)),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF203A43)),
              ],
            ),
            offset: const Offset(0, 45),
            color: Colors.white.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (Locale locale) {
              languageProvider.setLocale(locale);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Locale('vi'),
                child: Row(
                  children: [
                    Text('🇻🇳', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('Tiếng Việt', style: TextStyle(color: Color(0xFF203A43), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: Locale('en'),
                child: Row(
                  children: [
                    Text('🇬🇧', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('English', style: TextStyle(color: Color(0xFF203A43), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: Locale('de'),
                child: Row(
                  children: [
                    Text('🇩🇪', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('Deutsch', style: TextStyle(color: Color(0xFF203A43), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.black54),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black54,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF203A43)),
        ),
      ),
    );
  }
}
