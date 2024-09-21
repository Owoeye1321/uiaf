import 'package:flutter/material.dart';
import 'package:uiaf/data/categories.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                maxLength: 52,
                decoration: InputDecoration(label: Text("Name")),
                validator: (value) {
                  return "Demo";
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text("Quantity"),
                        ),
                        initialValue: "1"),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(items: [
                      ...categories.entries
                          .map((eachCategory) => DropdownMenuItem(
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
                              )))
                          .toList()
                    ], onChanged: (value) {}),
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
