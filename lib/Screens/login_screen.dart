import 'package:flutter/material.dart';
import 'package:stoxy/Screens/register_screen.dart';
import 'package:stoxy/Screens/supplier_dashboard.dart'; // 1. Added this import

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // --- STOXY LOGO SECTION ---
              const Icon(
                Icons.inventory_2_outlined,
                size: 60,
                color: Color(0xFF1B5E20),
              ),
              const SizedBox(height: 10),
              const Text(
                'Stoxy',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const Text(
                'Smart Inventory Solutions',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 60),

              // Login Form
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Login to Your Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              _buildInputField("Email", Icons.email_outlined),
              _buildInputField(
                "Password",
                Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 30),

              // 2. Updated this button to navigate to the Supplier Dashboard
              _buildButton("Log In", () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupplierDashboard(),
                  ),
                );
              }),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Don't have an account? Register Now",
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label,
      IconData icon, {
        bool isPassword = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFC8E6C9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              obscureText: isPassword,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.black54),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B5E20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}