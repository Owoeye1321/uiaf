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
  late Future<List<GroceryItem>> loadedItems;
  String? error;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadedItems = _loadItem();
  }

  Future<List<GroceryItem>> _loadItem() async {
    final url = Uri.https(
        'flutterprep-a2d8e-default-rtdb.firebaseio.com', 'shopping-list.json');
    //try {
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      throw Exception("An error occured, please try again later");
      // setState(() {
      //   error = "Try again later";
      // });
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
    return indentedItem;
    // } catch (errorException) {
    //   setState(() {
    //     error = "An error occured, try again later";
    //   });
    // }
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

  void _disMissItem(GroceryItem item) async {
    final indexOfCurrentItem = listCategories.indexOf(item);
    setState(() {
      listCategories.remove(item);
    });
    final url = Uri.https('flutterprep-a2d8e-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final deleteResponse = await http.delete(url);
    if (deleteResponse.statusCode >= 400) {
      setState(() {
        listCategories.insert(indexOfCurrentItem, item);
      });
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: const Text("Grocery Item Deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(
              () {
                listCategories.add(item);
                final url = Uri.https(
                    'flutterprep-a2d8e-default-rtdb.firebaseio.com',
                    'shopping-list.json');
                http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(
                    {
                      "name": item.name,
                      "quantity": item.quantity,
                      "category": item.category?.name
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
      //this future builder isn't suitable for rendering ui with a stateful lifecycle
      body: FutureBuilder(
        future: loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Empty grocery",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(snapshot.data![index]),
              background: Container(
                color: Theme.of(context).colorScheme.onError,
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onDismissed: (direction) => _disMissItem(snapshot.data![index]),
              child: Item(
                groceryItem: snapshot.data![index],
              ),
            ),
          );
        },
      ),
    );
  }
}
