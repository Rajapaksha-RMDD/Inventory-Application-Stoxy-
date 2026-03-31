import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  final Map item;

  const StockCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    bool isCritical = item["status"] == "Critical";

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: isCritical ? Colors.red : Colors.orange),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(item["name"]),
    );
  }
}