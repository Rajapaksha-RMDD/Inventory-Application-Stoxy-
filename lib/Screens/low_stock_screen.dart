import 'package:flutter/material.dart';
import '../widgets/stock_card.dart';

class LowStockScreen extends StatefulWidget {
  const LowStockScreen({super.key});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  bool showCritical = true;

  final List<Map<String, dynamic>> items = [
    {"name": "Widget Type A", "qty": 10, "threshold": 10, "status": "Critical"},
    {"name": "Component B", "qty": 12, "threshold": 6, "status": "Warning"},
    {"name": "Component C", "qty": 0, "threshold": 0, "status": "Warning"},
  ];

  @override
  Widget build(BuildContext context) {
    List filteredItems = showCritical
        ? items.where((e) => e["status"] == "Critical").toList()
        : items.where((e) => e["status"] == "Warning").toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5EC),
      appBar: AppBar(title: const Text("Low Stock Alerts")),
      body: ListView.builder(
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          return StockCard(item: filteredItems[index]);
        },
      ),
    );
  }
}