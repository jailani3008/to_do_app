import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final authController = Get.find<AuthController>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0D1117) : const Color(0xFFF7F8FF);
    final card = dark ? const Color(0xFF161B27) : Colors.white;
    final border = dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E7EB);
    final title = dark ? Colors.white : const Color(0xFF111827);
    final sub = dark ? Colors.white38 : const Color(0xFF6B7280);
    final accentColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(backgroundColor: bg, elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: title),
            onPressed: () => Get.back(),
          )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account', style: TextStyle(color: title, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: title),
                      decoration: const InputDecoration(hintText: 'Full name'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                    ),
                    //EMAIL
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Email address'),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 12),
                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Must be at least 6 characters' : null,
                    ),
                    const SizedBox(height: 12),
                    // CONFIRM PASSWORD
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscurePassword,
                      decoration: const InputDecoration(hintText: 'Confirm Password'),
                      validator: (v) => (v != _passwordController.text) ? 'Passwords do not match' : null,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authController.isLoading.value ? null : () {
                    if (_formKey.currentState!.validate()) {
                      authController.register(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                    }
                  },
                  child: authController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign Up'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}