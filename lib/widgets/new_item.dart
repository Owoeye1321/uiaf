import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uiaf/data/categories.dart';
import 'package:http/http.dart' as http;
import 'package:uiaf/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = 'Jack';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.fruit]!;
  bool _isSending = false;
  void _saveItem() async {
    setState(() {
      _isSending = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https('flutterprep-a2d8e-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final result = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "name": _enteredName,
            "quantity": _enteredQuantity,
            "category": _selectedCategory.name
          }));

      if (!context.mounted) return;
      final Map<String, dynamic> resData = json.decode(result.body);
      Navigator.of(context).pop(
        GroceryItem(
            id: resData["name"],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _enteredName,
                maxLength: 52,
                decoration: const InputDecoration(label: Text("Name")),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length >= 50)
                    return "Must be between 1 and 50 characters";
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    _enteredName = value!;
                  });
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Quantity"),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0)
                          return "Must be a valid positive number";
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        ...categories.entries
                            .map(
                              (eachCategory) => DropdownMenuItem(
                                value: eachCategory.value,
                                child: Row(
                                  children: [
                                    Container(
                                        width: 16,
                                        height: 16,
                                        color: eachCategory.value.color),
                                    const SizedBox(width: 6),
                                    Text(eachCategory.value.name)
                                  ],
                                ),
                              ),
                            )
                            .toList()
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text("Reset")),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text("Add item"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
