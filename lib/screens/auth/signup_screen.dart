import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  bool _obscurePassword     = true;
  final authController = Get.find<AuthController>();

  @override
  void dispose() {
    _nameController.dispose();
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
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: dark ? Colors.white70 : const Color(0xFF111827)),
          onPressed: () => Get.back(),
        ),
        title: Text('Create Account', style: TextStyle(color: title)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Join TaskFlow',
                style: TextStyle(color: title, fontSize: 24, fontWeight: FontWeight.w800))
                .animate().fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: 4),
            Text('Organize your tasks, your way.',
                style: TextStyle(color: sub, fontSize: 14))
                .animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 28),
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
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: title, fontSize: 14),
                      decoration: const InputDecoration(hintText: 'Full name'),
                      validator: (v) =>
                      (v == null || v.isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
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
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 20),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    authController.register(
                      name: _nameController.text,
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
                    : const Text('Create Account',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            )).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ', style: TextStyle(color: sub, fontSize: 14)),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Sign in',
                      style: TextStyle(color: kAccent, fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}