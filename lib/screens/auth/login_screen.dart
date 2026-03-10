import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  bool _obscurePassword     = true;
  final authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark   = Theme.of(context).brightness == Brightness.dark;
    final bg     = dark ? const Color(0xFF0D1117) : const Color(0xFFF7F8FF);
    final card   = dark ? const Color(0xFF161B27) : Colors.white;
    final border = dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E7EB);
    final title  = dark ? Colors.white : const Color(0xFF111827);
    final sub    = dark ? Colors.white38 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 52),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.check_rounded, color: kAccent, size: 26),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 24),

              Text('Welcome back',
                  style: TextStyle(color: title, fontSize: 26, fontWeight: FontWeight.w800))
                  .animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 4),
              Text('Sign in to continue', style: TextStyle(color: sub, fontSize: 14))
                  .animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: title, fontSize: 14),
                        decoration: const InputDecoration(hintText: 'Email address'),
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Email is required';
                          if (!v!.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: title, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18, color: sub,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Password is required';
                          return null;
                        },
                      ),

                      // forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                          child: const Text('Forgot password?',
                              style: TextStyle(color: kAccent, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

              const SizedBox(height: 20),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      authController.login(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                    }
                  },
                  child: authController.isLoading.value
                      ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text('Sign In',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              )).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: sub, fontSize: 14)),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.signup),
                    child: const Text('Sign up',
                        style: TextStyle(color: kAccent, fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}