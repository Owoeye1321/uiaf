import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uiaf/data/categories.dart';
import 'package:uiaf/models/grocery_item.dart';
import 'package:uiaf/widgets/grocery_item.dart';
import 'package:uiaf/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<GroceryItem> listCategories = [];
  bool _isloading = true;
  String? error;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final url = Uri.https(
        'flutterprep-a2d8e-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      setState(() {
        error = "Try again later";
      });
    }
    final Map<String, dynamic> loadItem = json.decode(response.body);
    final List<GroceryItem> indentedItem = [];
    for (final item in loadItem.entries) {
      final category = categories.entries
          .firstWhere(
            (catItem) => catItem.value.name == item.value["category"],
          )
          .value;
      indentedItem.add(GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: item.value['quantity'],
        category: category,
      ));
    }
    setState(() {
      listCategories = indentedItem;
      _isloading = false;
    });
  }

  void _addNewItem() async {
    final newGroceryItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newGroceryItem == null) return;
    setState(() {
      listCategories.add(newGroceryItem!);
    });
  }

  void _disMissItem(GroceryItem item) {
    final indexOfCurrentItem = listCategories.indexOf(item);
    setState(() {
      listCategories.remove(item);
    });
    final url = Uri.https('flutterprep-a2d8e-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    http.delete(
      url,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: const Text("Grocery Item Deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(
              () async {
                listCategories.add(item);
                final url = Uri.https(
                    'flutterprep-a2d8e-default-rtdb.firebaseio.com',
                    'shopping-list.json');
                await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(
                    {
                      "name": item.id,
                      "quantity": item.quantity,
                      "category": item.name
                    },
                  ),
                );
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
    if (_isloading) {
      content = const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (error != null) {
      content = Center(
        child: Text(
          error!,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }
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
