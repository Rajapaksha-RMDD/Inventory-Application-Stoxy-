import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'low_stock_screen.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  // --- FETCH CUSTOMER NAME FROM FIRESTORE ---
  Future<String> _fetchUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) return userDoc['name'] ?? "Customer";
      }
    } catch (e) {
      debugPrint("Error fetching name: $e");
    }
    return "Customer";
  }

  // --- STYLED LOGOUT & DELETE ACCOUNT ALERT ---
  void _showLogoutOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE8F5E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(Icons.manage_accounts, color: Color(0xFF1B5E20)),
            const SizedBox(width: 10),
            const Text("Account Options",
                style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)
            ),
          ],
        ),
        content: const Text(
          "Choose an action. Deleting your account will remove all your data from the Stoxy system permanently.",
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
                  child: const Text("Keep Signed In", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
                      icon: const Icon(Icons.delete_forever, size: 18, color: Colors.white),
                      label: const Text("Delete", style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                          await user.delete();
                          if (context.mounted) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                            _showCustomSnackBar(context, "Account Permanently Deleted", Colors.red.shade900);
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

  void _showCustomSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.red.shade900 ? Icons.delete_sweep : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  int _parseQty(dynamic data) {
    if (data == null) return 0;
    if (data is int) return data;
    if (data is String) return int.tryParse(data) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B5E20), size: 20),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
        ),
        title: const Text('Dashboard Overview', style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1B5E20)),
            onPressed: () => _showLogoutOptions(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));

          final allDocs = snapshot.data?.docs ?? [];
          int lowStockCount = allDocs.where((doc) => _parseQty(doc['quantity']) < 10).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- WELCOME SECTION ---
                FutureBuilder<String>(
                  future: _fetchUserName(),
                  builder: (context, nameSnapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, ${nameSnapshot.data ?? '...'}!",
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20)
                          ),
                        ),
                        const Text(
                          "Welcome back to your Stoxy portal.",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 25),

                // --- SEARCH BAR ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: const TextField(
                    decoration: InputDecoration(icon: Icon(Icons.search, color: Colors.grey), hintText: 'Search products...', border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 25),

                // --- SUMMARY CARDS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard("Total Products", allDocs.length.toString(), Colors.orange.shade100, Icons.inventory_2),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LowStockScreen())),
                      child: _buildSummaryCard("Low Stock", lowStockCount.toString(), Colors.red.shade100, Icons.warning_amber_rounded),
                    ),
                    _buildSummaryCard("Requests", "Live", Colors.blue.shade100, Icons.send_rounded),
                  ],
                ),
                const SizedBox(height: 30),
                const Text("Suppliers & Catalogs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E4D3E))),
                const SizedBox(height: 15),

                // --- SUPPLIER LIST ---
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Supplier').snapshots(),
                  builder: (context, supplierSnapshot) {
                    if (!supplierSnapshot.hasData) return const SizedBox();
                    return Column(
                      children: supplierSnapshot.data!.docs.map((supplier) {
                        String sId = supplier['uid'];
                        final sItems = allDocs.where((d) {
                          var data = d.data() as Map<String, dynamic>;
                          return data.containsKey('supplierId') && data['supplierId'] == sId;
                        }).toList();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                          child: ExpansionTile(
                            leading: CircleAvatar(backgroundColor: const Color(0xFFE8F5E9), child: Text(supplier['name'][0], style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold))),
                            title: Text(supplier['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                            children: sItems.map((item) {
                              return RequestItemRow(name: item['name'], currentQty: _parseQty(item['quantity']), sId: sId);
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
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
      width: 100, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
      child: Column(children: [
        Icon(icon, color: Colors.black87),
        const SizedBox(height: 8),
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class RequestItemRow extends StatefulWidget {
  final String name;
  final int currentQty;
  final String sId;
  const RequestItemRow({super.key, required this.name, required this.currentQty, required this.sId});
  @override
  State<RequestItemRow> createState() => _RequestItemRowState();
}

class _RequestItemRowState extends State<RequestItemRow> {
  final TextEditingController qtyController = TextEditingController();
  bool isSending = false;

  @override
  void dispose() { qtyController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold))),
              Text("Stock: ${widget.currentQty}", style: TextStyle(color: widget.currentQty < 10 ? Colors.red : Colors.black54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Qty", filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                ),
              ),
              const SizedBox(width: 10),
              isSending
                  ? const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2))
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () async {
                  if (qtyController.text.trim().isEmpty) return;
                  setState(() => isSending = true);
                  try {
                    User? user = FirebaseAuth.instance.currentUser;
                    DocumentSnapshot uDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
                    await FirebaseFirestore.instance.collection('requests').add({
                      'productName': widget.name,
                      'requestQty': qtyController.text.trim(),
                      'supplierId': widget.sId,
                      'customerName': uDoc['name'],
                      'status': 'Pending',
                      'timestamp': FieldValue.serverTimestamp()
                    });
                    qtyController.clear();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Request Sent Successfully!",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                              Text("The supplier for ${widget.name} has been notified.",
                                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
                            ],
                          ),
                          backgroundColor: const Color(0xFF1B5E20),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          margin: const EdgeInsets.all(20),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red.shade800,
                            behavior: SnackBarBehavior.floating,
                          )
                      );
                    }
                  } finally {
                    if (mounted) setState(() => isSending = false);
                  }
                },
                child: const Text("Request", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}