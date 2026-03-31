import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class SupplierDashboard extends StatelessWidget {
  const SupplierDashboard({super.key});

  // 1. Fetch User Name
  Future<String> _fetchUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) return userDoc['name'] ?? "Supplier";
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return "Supplier";
  }

  // 2. SILENT DELETE & REDIRECT
  Future<void> _silentDeleteAndLogout(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        // Delete Firestore record
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

        // Delete Auth account
        await user.delete();
      }
    } catch (e) {
      debugPrint("Silent delete failed, signing out: $e");
      await FirebaseAuth.instance.signOut();
    }

    // Always navigate to login screen immediately after the attempt
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Supplier Portal',
          style: TextStyle(color: Color(0xFF2D4F1E), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF2D4F1E)),
            onPressed: () => _silentDeleteAndLogout(context), // Deletes immediately
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _fetchUserName(),
              builder: (context, snapshot) {
                String name = snapshot.data ?? "...";
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, $name!",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                    ),
                    const Text("You have 3 new restock requests today.", style: TextStyle(color: Colors.grey)),
                  ],
                );
              },
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Active Clients", "12", Colors.blue.shade50, Icons.people_alt_rounded),
                _buildStatCard("New Requests", "03", Colors.orange.shade50, Icons.assignment_late_rounded),
                _buildStatCard("Shipped", "85", Colors.green.shade50, Icons.local_shipping_rounded),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Incoming Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D4F1E))),
            const SizedBox(height: 10),
            _buildRequestItem("Store #102 - Colombo", "25 Units of Item A", "Priority: High", Colors.red),
            _buildRequestItem("Main Street Mart", "50 Units of Item B", "Priority: Med", Colors.orange),
            _buildRequestItem("Village Grocer", "10 Units of Item C", "Priority: Low", Colors.green),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_box_outlined, color: Colors.white),
                label: const Text("Update Catalog", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D4F1E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Panel'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color bgColor, IconData icon) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          CircleAvatar(backgroundColor: bgColor, child: Icon(icon, color: Colors.black87, size: 20)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRequestItem(String store, String detail, String priority, Color pColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(store, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(detail, style: const TextStyle(color: Colors.black54)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: pColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(priority, style: TextStyle(color: pColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}