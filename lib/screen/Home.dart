import 'package:flutter/material.dart';
import 'package:uiaf/models/grocery_item.dart';
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
  final List<GroceryItem> listCategories = [];

  void _addNewItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) return;
    setState(() {
      listCategories.add(newItem);
    });
  }

  void _disMissItem(GroceryItem item) {
    final indexOfCurrentItem = listCategories.indexOf(item);
    setState(() {
      listCategories.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: const Text("Grocery Item Deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(
              () {
                listCategories.insert(indexOfCurrentItem, item);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        "Empty grocery",
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
    if (listCategories.isNotEmpty) {
      content = ListView.builder(
        itemCount: listCategories.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(listCategories[index]),
          background: Container(
            color: Theme.of(context).colorScheme.onError,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          onDismissed: (direction) => _disMissItem(listCategories[index]),
          child: Item(
            groceryItem: listCategories[index],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _addNewItem,
            icon: const Icon(Icons.add),
          ),
        ],
        centerTitle: false,
        title: const Text("Your Groceries"),
      ),
      body: content,
    );
  }
}
