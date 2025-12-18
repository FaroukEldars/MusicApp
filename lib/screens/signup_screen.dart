import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  late final AnimationController _animController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }
  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirm_controllerDispose();
    super.dispose();
  }
  void _confirm_controllerDispose() {
    _confirmController.dispose();
  }


  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<Auth>(context, listen: false);

    try {
      await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully ✅')),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Sign up failed';
      if (e.code == 'email-already-in-use') {
        msg = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        msg = 'The password is too weak.';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address.';
      } else {
        msg = e.message ?? msg;
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unexpected: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter a password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurpleAccent.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_add, size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to start listening',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 22),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email
                          _buildField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'you@mail.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter your email';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                            borderRadius: radius,
                          ),
                          const SizedBox(height: 12),

                          // Password
                          _buildField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'At least 6 characters',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: _validatePassword,
                            borderRadius: radius,
                          ),
                          const SizedBox(height: 12),

                          // Confirm
                          _buildField(
                            controller: _confirmController,
                            label: 'Confirm Password',
                            hint: 'Re-type your password',
                            icon: Icons.lock_clock,
                            isPassword: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Confirm your password';
                              if (v != _passwordController.text) return 'Passwords don\'t match';
                              return null;
                            },
                            borderRadius: radius,
                          ),
                          const SizedBox(height: 18),

                          // Sign up button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: radius),
                                elevation: 6,
                                backgroundColor: Colors.transparent,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                                  ),
                                  borderRadius: radius,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurpleAccent.withOpacity(0.28),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                      : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account? ",
                                  style: TextStyle(color: Colors.grey[400])),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Sign In',
                                    style: TextStyle(
                                        color: Color(0xFFB39DDB),
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required BorderRadius borderRadius,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: borderRadius,
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.18), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey[400],
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
