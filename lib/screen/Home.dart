import 'package:flutter/material.dart';
import 'package:uiaf/data/dummy_items.dart';
import 'package:uiaf/widgets/grocery_item.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Your Groceries"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            ...groceryItems.map((item) => Item(groceryItem: item)).toList()
          ],
        ),
      ),
    );
  }
}
