import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'update_catalog_screen.dart';

class SupplierDashboard extends StatefulWidget {
  const SupplierDashboard({super.key});

  @override
  State<SupplierDashboard> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboard> {
  // --- UPDATED STYLED SNACKBAR ---
  void _showCustomSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
                color == Colors.red.shade900 ? Icons.delete_sweep : Icons.check_circle,
                color: Colors.white,
                size: 20
            ),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- STYLED LOGOUT & DELETE ACCOUNT ALERT ---
  void _showLogoutOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF1F8E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: Color(0xFF1B5E20)),
            const SizedBox(width: 10),
            const Text("Supplier Settings",
                style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)
            ),
          ],
        ),
        content: const Text(
          "Do you want to exit the portal or permanently remove your supplier catalog and account data?",
          style: TextStyle(color: Color(0xFF2E4D3E)),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Return to Dashboard", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.logout, size: 18, color: Colors.white),
                      label: const Text("Sign Out", style: TextStyle(color: Colors.white)),
                      onPressed: () => FirebaseAuth.instance.signOut().then((_) =>
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()))),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.no_accounts, size: 18, color: Colors.white),
                      label: const Text("Delete", style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                          await user.delete();
                          if (context.mounted) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                            _showCustomSnackBar(context, "Supplier Profile Erased", Colors.red.shade900);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final String currentSupplierId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B5E20), size: 20),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
        ),
        title: const Text('Supplier Portal', style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1B5E20)),
            onPressed: () => _showLogoutOptions(context),
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello, ${snapshot.data ?? '...'}!",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                    const Text("Manage your incoming customer stock requests.", style: TextStyle(color: Colors.grey)),
                  ],
                );
              },
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Clients", "Active", Colors.blue.shade50, Icons.people_alt_rounded),
                _buildStatCard("Catalog", "Items", Colors.orange.shade50, Icons.inventory_2_rounded),
                _buildStatCard("Requests", "Live", Colors.green.shade50, Icons.bolt_rounded),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Incoming Customer Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D4F1E))),
            const SizedBox(height: 15),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('requests').where('supplierId', isEqualTo: currentSupplierId).orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text("Error: ${snapshot.error}");
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Text("No pending requests.", style: TextStyle(color: Colors.grey))));
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return _buildLiveRequestCard(
                        context: context,
                        docId: doc.id,
                        customer: data['customerName'] ?? "Unknown",
                        product: data['productName'] ?? "Product",
                        qty: data['requestQty']?.toString() ?? "0"
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdateCatalogScreen())),
                icon: const Icon(Icons.edit_note, color: Colors.white),
                label: const Text("UPDATE MY CATALOG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
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

  Widget _buildLiveRequestCard({required BuildContext context, required String docId, required String customer, required String product, required String qty}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFF1F8E9), child: Icon(Icons.person_pin, color: Color(0xFF1B5E20))),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text("Needs $qty unit(s) of $product", style: const TextStyle(color: Colors.black54, fontSize: 13))
                  ]
              )
          ),
          IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('requests').doc(docId).delete();
                if (mounted) {
                  _showCustomSnackBar(context, "Stock Request Completed", const Color(0xFF1B5E20));
                }
              }
          ),
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
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey))
          ]
      ),
    );
  }
}