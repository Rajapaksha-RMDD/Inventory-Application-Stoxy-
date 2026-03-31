import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Controllers
  final TextEditingController _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String selectedRole = 'Customer';
  final List<String> roles = ['Customer', 'Supplier'];
  bool _isLoading = false;

  // 2. Logic to Register & Save to Firestore
  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create Auth User
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save additional data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSnackBar("Registration Successful!");
        Navigator.pop(context); // Go back to login
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light Mint Background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 40),

              _buildLabel("Full Name"),
              _buildTextField(icon: Icons.person_outline, controller: _nameController, hint: "Your Name"),

              _buildLabel("Email Address"),
              _buildTextField(icon: Icons.email_outlined, controller: _emailController, hint: "exsistname@mail.com"),

              _buildLabel("Password"),
              _buildTextField(icon: Icons.lock_outline, isPassword: true, controller: _passwordController, hint: "••••••••"),

              _buildLabel("Confirm Password"),
              _buildTextField(icon: Icons.lock_outline, isPassword: true, controller: _confirmPasswordController, hint: "••••••••"),

              _buildLabel("Role"),
              _buildRoleDropdown(),

              const SizedBox(height: 40),

              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
                  : _buildActionButton("Register", _handleRegister),

              const SizedBox(height: 20),
              _buildLoginLink(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.inventory_2_rounded, size: 50, color: Color(0xFF1B5E20)),
          const SizedBox(height: 10),
          const Text('Stoxy', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20))),
          const Text('Create Your Account', style: TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E4D3E))),
    );
  }

  Widget _buildTextField({required IconData icon, required TextEditingController controller, required String hint, bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(15)),
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

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRole,
          isExpanded: true,
          items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (val) => setState(() => selectedRole = val!),
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
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Already have an account? Login", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
      ),
    );
  }
}