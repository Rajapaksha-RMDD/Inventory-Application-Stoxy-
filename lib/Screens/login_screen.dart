import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'supplier_dashboard.dart';
import 'customer_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Please enter email and password");
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc['role'] ?? 'Customer';

        if (mounted) {
          if (role == 'Supplier') {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SupplierDashboard())
            );
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CustomerDashboard())
            );
          }
        }
      } else {
        _showSnackBar("User record not found in database.");
      }
    } catch (e) {
      _showSnackBar("Login Failed: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // 1. Logo Animation (Fade & Scale)
              _animatedEntrance(
                delay: 0,
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.inventory_2_rounded, size: 70, color: Color(0xFF1B5E20)),
                      const SizedBox(height: 10),
                      const Text(
                        'Stoxy',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
                      ),
                      const Text('Manage your inventory easily', style: TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // 2. Email Section Animation
              _animatedEntrance(
                delay: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Email Address"),
                    _buildTextField(
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      hint: "example@mail.com",
                    ),
                  ],
                ),
              ),

              // 3. Password Section Animation
              _animatedEntrance(
                delay: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Password"),
                    _buildTextField(
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      hint: "••••••••",
                      isPassword: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 4. Button Animation
              _animatedEntrance(
                delay: 600,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
                    : _buildActionButton("Login", _login),
              ),

              const SizedBox(height: 20),

              // 5. Footer Animation
              _animatedEntrance(
                delay: 800,
                child: Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen())
                    ),
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ANIMATION HELPER ---
  Widget _animatedEntrance({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // --- UI HELPER METHODS ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E4D3E)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFC8E6C9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF1B5E20)),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B5E20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 2,
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}