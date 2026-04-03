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

  // Simplified controllers - only name and quantity
  late TextEditingController nameController;
  late TextEditingController quantityController;

  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    quantityController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  // Helper to prevent the "String vs Int" crash
  int _parseQty(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Widget buildTextFieldWithController(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF2D4F1E)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1B5E20)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter product name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _firestore.collection('products').add({
        'name': nameController.text.trim(),
        'quantity': int.tryParse(quantityController.text) ?? 0,
        'supplierId': currentSupplierId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      nameController.clear();
      quantityController.clear();

      setState(() {
        _showAddForm = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Text("Product Saved Successfully"),
            ],
          ),
          backgroundColor: const Color(0xFF2D4F1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text("Error: $e"),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
          "My Inventory",
          style: TextStyle(
            color: Color(0xFF2D4F1E),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => setState(() => _showAddForm = !_showAddForm),
            icon: const Icon(Icons.add, color: Color(0xFF2D4F1E)),
            tooltip: "Add Product",
          ),
        ],
      ),
      body: _showAddForm
          ? Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2D4F1E),
                    const Color(0xFF4CAF50),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_box_rounded, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Add New Product",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Product Name
            buildTextFieldWithController("Product Name *", nameController),

            const SizedBox(height: 20),

            // Current Quantity
            buildTextFieldWithController("Current Quantity", quantityController, keyboardType: TextInputType.number),

            const SizedBox(height: 50),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D4F1E),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: const Color(0xFF2D4F1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      "Save Product",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => setState(() => _showAddForm = false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2D4F1E), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Color(0xFF2D4F1E), fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('products')
            .where('supplierId', isEqualTo: currentSupplierId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No items found."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;

              int currentQty = _parseQty(data['quantity']);

              _controllers.putIfAbsent(doc.id, () => TextEditingController(text: currentQty.toString()));

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2, color: Color(0xFF1B5E20)),
                    const SizedBox(width: 15),
                    Expanded(child: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _controllers[doc.id],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.green),
                      onPressed: () async {
                        await _firestore.collection('products').doc(doc.id).update({
                          'quantity': int.parse(_controllers[doc.id]!.text),
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 12),
                                const Text("Stock Updated Successfully"),
                              ],
                            ),
                            backgroundColor: const Color(0xFF2D4F1E),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
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