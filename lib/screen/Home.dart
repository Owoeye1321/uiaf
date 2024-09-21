import 'package:flutter/material.dart';
import 'package:uiaf/data/dummy_items.dart';
import 'package:uiaf/widgets/grocery_item.dart';
import 'package:uiaf/widgets/new_item.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void _addNewItem() {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return const NewItem();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _addNewItem;
            },
            icon: Icon(Icons.add),
          ),
        ],
        centerTitle: false,
        title: const Text("Your Groceries"),
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) => Item(groceryItem: groceryItems[index]),
      ),
    );
  }
}
