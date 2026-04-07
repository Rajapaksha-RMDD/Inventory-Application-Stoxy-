import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController     = TextEditingController();
  final _qtyController      = TextEditingController();
  bool _isSaving = false;

  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _invRef => FirebaseFirestore.instance
      .collection('customer_inventory')
      .doc(_uid)
      .collection('items');

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a product name."),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    setState(() => _isSaving = true);

    try {
      await _invRef.doc(name).set(
        {'productName': name, 'quantity': qty, 'isCustom': true},
        SetOptions(merge: true),
      );
      _nameController.clear();
      _qtyController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text("\"$name\" saved!",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
            backgroundColor: const Color(0xFF2D4F1E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteProduct(String name) async {
    await _invRef.doc(name).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("\"$name\" deleted."),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
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
          "Add New Product",
          style: TextStyle(
            color: Color(0xFF2D4F1E),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── Form ──
            SingleChildScrollView(
              child: Column(
                children: [
                  buildTextField("Product Name", _nameController),
                  buildTextField("Current Quantity", _qtyController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 20),

                  // Save Product Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D4F1E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : const Text("Save Product",
                          style:
                          TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Added Products List ──
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Added Products",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D4F1E),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: _uid == null
                  ? const Center(child: Text("Not signed in"))
                  : StreamBuilder<QuerySnapshot>(
                stream: _invRef
                    .where('isCustom', isEqualTo: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF2D4F1E)));
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text("No products added yet.",
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                      docs[index].data() as Map<String, dynamic>;
                      final name =
                          data['productName'] as String? ?? docs[index].id;
                      final qty = data['quantity'];
                      final qtyInt = qty is int
                          ? qty
                          : int.tryParse(qty.toString()) ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F8E9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.inventory_2_rounded,
                                  color: Color(0xFF2D4F1E), size: 20),
                            ),
                            const SizedBox(width: 14),
                            // Name + qty
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1B2E1B))),
                                  const SizedBox(height: 2),
                                  Text("Qty: $qtyInt",
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            // Qty pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: qtyInt < 5
                                    ? Colors.red.shade100
                                    : const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                qtyInt < 5 ? "Low" : "In Stock",
                                style: TextStyle(
                                    color: qtyInt < 5
                                        ? Colors.red.shade700
                                        : const Color(0xFF2D4F1E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Delete
                            GestureDetector(
                              onTap: () => _deleteProduct(name),
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.delete_outline_rounded,
                                    color: Colors.red.shade400, size: 17),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
        ),
      ),
    );
  }
}