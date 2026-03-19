import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String selectedRole = 'Customer';
  final List<String> roles = ['Customer', 'Supplier'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light mint background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // --- STOXY BRANDING SECTION ---
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.inventory_2_rounded,
                      size: 50,
                      color: Color(0xFF1B5E20),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Stoxy',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- FORM FIELDS ---
              _buildLabel("Full Name"),
              _buildTextField(icon: Icons.person_outline),

              _buildLabel("Email Address"),
              _buildTextField(icon: Icons.email_outlined),

              _buildLabel("Password"),
              _buildTextField(icon: Icons.lock_outline, isPassword: true),

              _buildLabel("Confirm Password"),
              _buildTextField(icon: Icons.lock_outline, isPassword: true),

              _buildLabel("Role"),
              _buildRoleDropdown(),

              const SizedBox(height: 40),

              // --- ACTION BUTTON ---
              _buildActionButton("Register", () {
                // Add your sign-up logic here
              }),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFF2E4D3E),
        ),
      ),
    );
  }

  Widget _buildTextField({required IconData icon, bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFC8E6C9), // Slightly darker mint for contrast
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
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFC8E6C9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRole,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1B5E20)),
          items: roles
              .map(
                (role) => DropdownMenuItem(
                  value: role,
                  child: Text(
                    role,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              )
              .toList(),
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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
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
