import 'package:flutter/material.dart';

class LowStockScreen extends StatefulWidget {
  const LowStockScreen({super.key});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  bool showCritical = true;

  // Mock data - In the future, this will come from your Firebase collection
  final List<Map<String, dynamic>> items = [
    {"name": "Industrial Widget A", "qty": 2, "threshold": 10, "status": "Critical"},
    {"name": "Steel Component B", "qty": 5, "threshold": 15, "status": "Critical"},
    {"name": "Safety Valve C", "qty": 12, "threshold": 10, "status": "Warning"},
    {"name": "Copper Pipe D", "qty": 8, "threshold": 5, "status": "Warning"},
  ];

  @override
  Widget build(BuildContext context) {
    List filteredItems = showCritical
        ? items.where((e) => e["status"] == "Critical").toList()
        : items.where((e) => e["status"] == "Warning").toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Light Stoxy Green
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        // Fix: Ensures the back arrow is white
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
            "Inventory Alerts",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Toggle
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToggleButton("Critical", showCritical, () {
                  setState(() => showCritical = true);
                }),
                const SizedBox(width: 12),
                _buildToggleButton("Warning", !showCritical, () {
                  setState(() => showCritical = false);
                }),
              ],
            ),
          ),

          // Stock List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return StockCard(item: filteredItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1B5E20) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class StockCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const StockCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isCritical = item['status'] == 'Critical';
    final Color statusColor = isCritical ? const Color(0xFFD32F2F) : const Color(0xFFF57C00);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Row(
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                const SizedBox(height: 4),
                Text(
                  "Current Qty: ${item['qty']} / Limit: ${item['threshold']}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          // Status Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item['status'],
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}