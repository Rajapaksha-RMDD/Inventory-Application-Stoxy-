import 'package:flutter/material.dart';
import 'add_product_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Map<String, dynamic>> products = [
    {"name": "Chair", "qty": 10, "min": 5},
    {"name": "Table", "qty": 3, "min": 5},
    {"name": "Sofa", "qty": 1, "min": 2},
  ];

  List<Map<String, dynamic>> filteredProducts = [];
  String searchText = "";
  bool showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    filteredProducts = products;
  }

  void filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        final matchesSearch = product["name"].toLowerCase().contains(
          searchText.toLowerCase(),
        );

        final isLowStock = product["qty"] <= product["min"];

        if (showLowStockOnly) {
          return matchesSearch && isLowStock;
        } else {
          return matchesSearch;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product List"), centerTitle: true),

      body: Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (value) {
                searchText = value;
                filterProducts();
              },
            ),
          ),

          // 🔘 Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ChoiceChip(
                label: const Text("All"),
                selected: !showLowStockOnly,
                onSelected: (_) {
                  showLowStockOnly = false;
                  filterProducts();
                },
              ),
              ChoiceChip(
                label: const Text("Low Stock"),
                selected: showLowStockOnly,
                onSelected: (_) {
                  showLowStockOnly = true;
                  filterProducts();
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 📦 List
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("No products found"))
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.inventory),

                          title: Text(
                            product["name"],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Text("Qty: ${product["qty"]}"),

                          // ❌ DELETE
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                products.remove(product);
                                filterProducts();
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ➕ ADD
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProduct = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );

          if (newProduct != null) {
            products.add(newProduct);
            filterProducts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
