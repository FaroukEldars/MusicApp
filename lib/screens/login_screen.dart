import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late final AnimationController _animationController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<Auth>(context, listen: false);

    try {
      await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful")),
        );

      }
    } on FirebaseAuthException catch (e) {
      String msg = "Login failed";

      if (e.code == "invalid-email") msg = "Invalid email address";
      else if (e.code == "wrong-password") msg = "Incorrect password";
      else if (e.code == "user-not-found") msg = "User not found";

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                children: [
                  _logo(),
                  const SizedBox(height: 40),
                  _form(radius),
                  const SizedBox(height: 25),
                  _forgotPassword(),
                  const SizedBox(height: 30),
                  _loginButton(radius),
                  const SizedBox(height: 25),
                  _divider(),
                  const SizedBox(height: 25),
                  _signup(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurpleAccent,
                blurRadius: 25,
                spreadRadius: 3,
              )
            ],
          ),
          child: const Icon(Icons.music_note, size: 55, color: Colors.white),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) =>
              const LinearGradient(colors: [Colors.white, Color(0xFFB39DDB)])
                  .createShader(bounds),
          child: const Text(
            "Welcome Back",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Login to continue",
          style: TextStyle(color: Colors.grey[400]),
        )
      ],
    );
  }

  Widget _form(BorderRadius radius) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _input(
            controller: _emailController,
            label: "Email",
            icon: Icons.email_outlined,
            validator: (v) =>
            v == null || !v.contains("@") ? "Enter valid email" : null,
            radius: radius,
          ),
          const SizedBox(height: 16),
          _input(
            controller: _passwordController,
            label: "Password",
            icon: Icons.lock_outline,
            isPassword: true,
            validator: (v) =>
            v == null || v.length < 6 ? "Min 6 characters" : null,
            radius: radius,
          ),
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    required String? Function(String?) validator,
    required BorderRadius radius,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: radius,
        border: Border.all(
          color: Colors.deepPurpleAccent,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey[400],
            ),
            onPressed: () =>
                setState(() => _isPasswordVisible = !_isPasswordVisible),
          )
              : null,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _forgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () async {
          final email = _emailController.text.trim();

          if (email.isEmpty || !email.contains("@")) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Enter valid email"),
            ));
            return;
          }

          final auth = Provider.of<Auth>(context, listen: false);
          await auth.sendPasswordResetEmail(email: email);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Password reset link sent"),
            ));
          }
        },
        child: Text(
          "Forgot password?",
          style: TextStyle(color: Colors.deepPurpleAccent[100]),
        ),
      ),
    );
  }

  Widget _loginButton(BorderRadius radius) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient:
            const LinearGradient(colors: [Color(0xFF673AB7), Color(0xFF9C27B0)]),
            borderRadius: radius,
          ),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              "Sign In",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[800])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text("OR", style: TextStyle(color: Colors.grey[500])),
        ),
        Expanded(child: Divider(color: Colors.grey[800])),
      ],
    );
  }

  Widget _signup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?",
            style: TextStyle(color: Colors.grey[400])),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignUpScreen()),
            );
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
