import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────
//  CUSTOMER DASHBOARD
// ─────────────────────────────────────────────
class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

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

  void showLogoutOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE8F5E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: const [
            Icon(Icons.manage_accounts, color: Color(0xFF1B5E20)),
            SizedBox(width: 10),
            Text("Account Options",
                style: TextStyle(
                    color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Choose an action. Deleting your account will remove all your data from the Stoxy system permanently.",
          style: TextStyle(color: Color(0xFF2E4D3E)),
        ),
        actionsPadding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Keep Signed In",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.logout, size: 18, color: Colors.white),
                      label: const Text("Sign Out",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () => FirebaseAuth.instance
                          .signOut()
                          .then((_) => Navigator.pushReplacement(context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()))),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.delete_forever,
                          size: 18, color: Colors.white),
                      label: const Text("Delete",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .delete();
                          await user.delete();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()));
                            _showCustomSnackBar(context,
                                "Account Permanently Deleted",
                                Colors.red.shade900);
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
              color == Colors.red.shade900
                  ? Icons.delete_sweep
                  : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(message,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildInventoryBanner(int uniqueProducts, int totalQuantity) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                "Inventory Overview From Suppliers",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Unique Products",
                          style: TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 6),
                      Text(uniqueProducts.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      const Text("product types",
                          style: TextStyle(
                              color: Colors.white60, fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Quantity",
                          style: TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 6),
                      Text(totalQuantity.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      const Text("units in stock",
                          style: TextStyle(
                              color: Colors.white60, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1B5E20), size: 20),
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const LoginScreen())),
        ),
        title: const Text('Dashboard Overview',
            style: TextStyle(
                color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1B5E20)),
            onPressed: () => showLogoutOptions(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
        FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
          }

          final allDocs = snapshot.data?.docs ?? [];
          int uniqueProducts = allDocs.length;
          int totalQuantity = allDocs.fold<int>(
              0, (sum, doc) => sum + _parseQty(doc['quantity']));

          // Low stock count from CUSTOMER inventory (qty < 5)
          return StreamBuilder<QuerySnapshot>(
            stream: uid == null
                ? const Stream.empty()
                : FirebaseFirestore.instance
                .collection('customer_inventory')
                .doc(uid)
                .collection('items')
                .snapshots(),
            builder: (context, invSnap) {
              final invDocs = invSnap.data?.docs ?? [];
              int lowStockCount = invDocs
                  .where((d) => _parseQty((d.data() as Map)['quantity']) < 5)
                  .length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── WELCOME ──
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
                                  color: Color(0xFF1B5E20)),
                            ),
                            const Text(
                              "Welcome back to your Stoxy portal.",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 25),

                    // ── MANAGE INVENTORY BUTTON ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.edit_note_rounded,
                            color: Colors.white, size: 22),
                        label: const Text(
                          "Manage Inventory",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const ManageInventoryScreen())),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ── HERO BANNER ──
                    _buildInventoryBanner(uniqueProducts, totalQuantity),
                    const SizedBox(height: 20),

                    // ── SUMMARY CARDS ──
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const CustomerLowStockScreen())),
                            child: _buildSummaryCard(
                                "Low Stock",
                                lowStockCount.toString(),
                                Colors.red.shade100,
                                Icons.warning_amber_rounded),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard("Requests", "Live",
                              Colors.blue.shade100, Icons.send_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    const Text("Suppliers & Catalogs",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E4D3E))),
                    const SizedBox(height: 15),

                    // ── SUPPLIER LIST ──
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('role', isEqualTo: 'Supplier')
                          .snapshots(),
                      builder: (context, supplierSnapshot) {
                        if (!supplierSnapshot.hasData) return const SizedBox();
                        return Column(
                          children:
                          supplierSnapshot.data!.docs.map((supplier) {
                            String sId = supplier['uid'];
                            final sItems = allDocs.where((d) {
                              var data = d.data() as Map<String, dynamic>;
                              return data.containsKey('supplierId') &&
                                  data['supplierId'] == sId;
                            }).toList();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFE8F5E9),
                                    child: Text(supplier['name'][0],
                                        style: const TextStyle(
                                            color: Color(0xFF1B5E20),
                                            fontWeight: FontWeight.bold))),
                                title: Text(supplier['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B5E20))),
                                children: sItems.map((item) {
                                  return RequestItemRow(
                                      name: item['name'],
                                      currentQty: _parseQty(item['quantity']),
                                      sId: sId);
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
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group), label: 'Customers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.cached), label: 'Restock'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(title,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MANAGE INVENTORY SCREEN
//  Names  → products (supplier DB, read-only)
//  Qty    → customer_inventory/{uid}/items/{productName}
//
//  Firestore rule needed:
//  match /customer_inventory/{userId}/items/{doc} {
//    allow read, write: if request.auth.uid == userId;
//  }
// ─────────────────────────────────────────────
class ManageInventoryScreen extends StatefulWidget {
  const ManageInventoryScreen({super.key});

  @override
  State<ManageInventoryScreen> createState() => _ManageInventoryScreenState();
}

class _ManageInventoryScreenState extends State<ManageInventoryScreen> {
  final Map<String, int> _pendingChanges = {};
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  int _parseQty(dynamic data) {
    if (data == null) return 0;
    if (data is int) return data;
    if (data is String) return int.tryParse(data) ?? 0;
    return 0;
  }

  CollectionReference get _invRef => FirebaseFirestore.instance
      .collection('customer_inventory')
      .doc(_uid)
      .collection('items');

  Future<void> _saveChanges() async {
    if (_pendingChanges.isEmpty || _uid == null) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final entry in _pendingChanges.entries) {
        final ref = _invRef.doc(entry.key);
        batch.set(
          ref,
          {'productName': entry.key, 'quantity': entry.value},
          SetOptions(merge: true),
        );
      }
      await batch.commit();
      if (mounted) {
        setState(() => _pendingChanges.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Inventory updated!",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: const Color(0xFF1B5E20),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving: $e"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1B5E20), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Inventory',
          style: TextStyle(
              color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_pendingChanges.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF1B5E20).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFF1B5E20), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "${_pendingChanges.length} unsaved change(s) — tap Save.",
                    style: const TextStyle(
                        color: Color(0xFF1B5E20), fontSize: 12),
                  ),
                ],
              ),
            ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, productSnap) {
                if (productSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1B5E20)));
                }
                final productDocs = productSnap.data?.docs ?? [];
                if (productDocs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 56, color: Colors.grey),
                        SizedBox(height: 12),
                        Text("No products found",
                            style: TextStyle(
                                color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: _invRef.snapshots(),
                  builder: (context, invSnap) {
                    final Map<String, int> customerQtyMap = {};
                    if (invSnap.hasData) {
                      for (final doc in invSnap.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        customerQtyMap[doc.id] = _parseQty(data['quantity']);
                      }
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                      itemCount: productDocs.length,
                      itemBuilder: (context, index) {
                        final pData = productDocs[index].data()
                        as Map<String, dynamic>;
                        final productName =
                            pData['name'] as String? ?? 'Unknown';
                        final supplierName =
                            pData['supplierName'] as String? ?? '';

                        final storedQty = customerQtyMap[productName] ?? 0;
                        final currentQty =
                        _pendingChanges.containsKey(productName)
                            ? _pendingChanges[productName]!
                            : storedQty;
                        final isLow = currentQty < 5;

                        return _InventoryProductCard(
                          docId: productName,
                          name: productName,
                          supplierName: supplierName,
                          currentQty: currentQty,
                          isLow: isLow,
                          hasChange: _pendingChanges.containsKey(productName),
                          onIncrement: () => setState(() =>
                          _pendingChanges[productName] = currentQty + 1),
                          onDecrement: () {
                            if (currentQty > 0) {
                              setState(() =>
                              _pendingChanges[productName] = currentQty - 1);
                            }
                          },
                          onSetQty: (newQty) => setState(
                                  () => _pendingChanges[productName] = newQty),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _pendingChanges.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _saveChanges,
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(
          "Save ${_pendingChanges.length} change(s)",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
          : null,
    );
  }
}

// ─────────────────────────────────────────────
//  CUSTOMER LOW STOCK SCREEN
//  Reads from customer_inventory/{uid}/items where quantity < 5
// ─────────────────────────────────────────────
class CustomerLowStockScreen extends StatelessWidget {
  const CustomerLowStockScreen({super.key});

  int _parseQty(dynamic data) {
    if (data == null) return 0;
    if (data is int) return data;
    if (data is String) return int.tryParse(data) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1B5E20), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Low Stock Items',
          style: TextStyle(
              color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(child: Text("Not signed in"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customer_inventory')
            .doc(uid)
            .collection('items')
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF1B5E20)));
          }

          final lowItems = (snap.data?.docs ?? [])
              .where((d) =>
          _parseQty((d.data() as Map)['quantity']) < 5)
              .toList();

          if (lowItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline,
                        size: 64, color: Color(0xFF1B5E20)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "All stocked up!",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "No items are below 5 units.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // ── Summary Banner ──
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.red.shade600, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${lowItems.length} item(s) running low",
                          style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        Text(
                          "Quantities below 5 units",
                          style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Low Stock List ──
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: lowItems.length,
                  itemBuilder: (context, index) {
                    final data =
                    lowItems[index].data() as Map<String, dynamic>;
                    final productName =
                        data['productName'] as String? ??
                            lowItems[index].id;
                    final qty = _parseQty(data['quantity']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.shade100),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(Icons.inventory_2_rounded,
                                color: Colors.red.shade400, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              productName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1B2E1B)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: qty == 0
                                  ? Colors.red.shade700
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              qty == 0 ? "Out of Stock" : "$qty left",
                              style: TextStyle(
                                  color: qty == 0
                                      ? Colors.white
                                      : Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  INVENTORY PRODUCT CARD  (+/- controls)
// ─────────────────────────────────────────────
class _InventoryProductCard extends StatefulWidget {
  final String docId;
  final String name;
  final String supplierName;
  final int currentQty;
  final bool isLow;
  final bool hasChange;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onSetQty;

  const _InventoryProductCard({
    required this.docId,
    required this.name,
    required this.supplierName,
    required this.currentQty,
    required this.isLow,
    required this.hasChange,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSetQty,
  });

  @override
  State<_InventoryProductCard> createState() => _InventoryProductCardState();
}

class _InventoryProductCardState extends State<_InventoryProductCard> {
  bool _editingQty = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentQty.toString());
  }

  @override
  void didUpdateWidget(covariant _InventoryProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editingQty) {
      _controller.text = widget.currentQty.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmEdit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed != null && parsed >= 0) {
      widget.onSetQty(parsed);
    } else {
      _controller.text = widget.currentQty.toString();
    }
    setState(() => _editingQty = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.hasChange
              ? const Color(0xFF1B5E20).withOpacity(0.6)
              : widget.isLow
              ? Colors.red.shade200
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: widget.isLow
                    ? Colors.red.shade50
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                color: widget.isLow
                    ? Colors.red.shade400
                    : const Color(0xFF388E3C),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1B2E1B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.isLow)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text("Low",
                              style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      if (widget.hasChange)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("Edited",
                              style: TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  if (widget.supplierName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(widget.supplierName,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                _CircleIconButton(
                  icon: Icons.remove,
                  color: Colors.grey.shade200,
                  iconColor: Colors.black87,
                  onTap: widget.onDecrement,
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _editingQty = true;
                      _controller.text = widget.currentQty.toString();
                      _controller.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _controller.text.length);
                    });
                  },
                  child: _editingQty
                      ? SizedBox(
                    width: 52,
                    height: 36,
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      autofocus: true,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: const Color(0xFFE8F5E9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _confirmEdit(),
                      onTapOutside: (_) => _confirmEdit(),
                    ),
                  )
                      : Container(
                    width: 52,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.hasChange
                          ? const Color(0xFF1B5E20).withOpacity(0.1)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.currentQty.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: widget.hasChange
                            ? const Color(0xFF1B5E20)
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _CircleIconButton(
                  icon: Icons.add,
                  color: const Color(0xFF1B5E20),
                  iconColor: Colors.white,
                  onTap: widget.onIncrement,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REQUEST ITEM ROW (unchanged)
// ─────────────────────────────────────────────
class RequestItemRow extends StatefulWidget {
  final String name;
  final int currentQty;
  final String sId;
  const RequestItemRow(
      {super.key,
        required this.name,
        required this.currentQty,
        required this.sId});
  @override
  State<RequestItemRow> createState() => _RequestItemRowState();
}

class _RequestItemRowState extends State<RequestItemRow> {
  final TextEditingController qtyController = TextEditingController();
  bool isSending = false;

  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(widget.name,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              Text("Stock: ${widget.currentQty}",
                  style: TextStyle(
                      color:
                      widget.currentQty < 5 ? Colors.red : Colors.black54,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "Qty",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none)),
                ),
              ),
              const SizedBox(width: 10),
              isSending
                  ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () async {
                  if (qtyController.text.trim().isEmpty) return;
                  setState(() => isSending = true);
                  try {
                    User? user = FirebaseAuth.instance.currentUser;
                    DocumentSnapshot uDoc =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .get();
                    await FirebaseFirestore.instance
                        .collection('requests')
                        .add({
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
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white)),
                              Text(
                                "The supplier for ${widget.name} has been notified.",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF1B5E20),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          margin: const EdgeInsets.all(20),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error: $e"),
                          backgroundColor: Colors.red.shade800,
                          behavior: SnackBarBehavior.floating));
                    }
                  } finally {
                    if (mounted) setState(() => isSending = false);
                  }
                },
                child: const Text("Request",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}