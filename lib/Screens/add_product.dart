import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController minController = TextEditingController();

  void saveProduct() {
    if (nameController.text.isEmpty ||
        qtyController.text.isEmpty ||
        minController.text.isEmpty) {
      return;
    }

    Navigator.pop(context, {
      "name": nameController.text,
      "qty": int.parse(qtyController.text),
      "min": int.parse(minController.text),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            TextField(
              controller: minController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Min Level"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProduct,
              child: const Text("Save Product"),
            ),
          ],
        ),
      ),
    );
  }
}
