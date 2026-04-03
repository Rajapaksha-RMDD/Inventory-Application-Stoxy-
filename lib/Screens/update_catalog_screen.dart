import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateCatalogScreen extends StatefulWidget {
  const UpdateCatalogScreen({super.key});

  @override
  State<UpdateCatalogScreen> createState() => _UpdateCatalogScreenState();
}

class _UpdateCatalogScreenState extends State<UpdateCatalogScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentSupplierId = FirebaseAuth.instance.currentUser?.uid ?? "";
  final Map<String, TextEditingController> _controllers = {};

  // Helper to prevent the "String vs Int" crash
  int _parseQty(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // --- MODERN STYLED SNACKBAR ---
  void _showUpdateSuccess(BuildContext context, String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.published_with_changes, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Inventory Updated!",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("New stock levels saved for $productName.",
                      style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20), // Your Emerald Green
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        title: const Text("My Inventory",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('products')
            .where('supplierId', isEqualTo: currentSupplierId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No items found in your catalog.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String productName = data['name'] ?? "Unknown Item";

              int currentQty = _parseQty(data['quantity']);
              _controllers.putIfAbsent(doc.id, () => TextEditingController(text: currentQty.toString()));

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
                    ]
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.inventory_2, color: Color(0xFF1B5E20)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(productName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E4D3E))),
                    ),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _controllers[doc.id],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none
                            )
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.save_rounded, color: Color(0xFF1B5E20), size: 28),
                      onPressed: () async {
                        await _firestore.collection('products').doc(doc.id).update({
                          'quantity': int.parse(_controllers[doc.id]!.text),
                        });
                        if (mounted) {
                          _showUpdateSuccess(context, productName);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}