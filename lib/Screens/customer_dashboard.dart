import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  // Function to handle the silent delete and logout logic
  Future<void> _handleLogout(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        // 1. Delete user record from Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
        // 2. Delete the Firebase Auth account
        await user.delete();
      }
    } catch (e) {
      // Fallback: If delete fails (re-auth required), just sign out
      await FirebaseAuth.instance.signOut();
    }

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dashboard Overview',
          style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Use the logout button to trigger the delete logic
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1B5E20)),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search products...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Summary Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard("Total Products", "148", Colors.orange.shade100, Icons.inventory_2),
                _buildSummaryCard("Low Stock", "21", Colors.red.shade100, Icons.warning_amber_rounded),
                _buildSummaryCard("Requests", "5", Colors.blue.shade100, Icons.send_rounded),
              ],
            ),
            const SizedBox(height: 25),

            // View All Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("View All Products", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Recent Stock Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E4D3E)),
            ),
            const SizedBox(height: 15),

            // Activity List
            _buildActivityItem("Customer Acme updated stock", "1h ago"),
            _buildActivityItem("New Order #456 created", "4h ago"),
            _buildActivityItem("Product A threshold met", "5h ago"),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.cached), label: 'Restock'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 10, color: Colors.green),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}