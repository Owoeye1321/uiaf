import 'package:flutter/material.dart';

import '../models/grocery_item.dart';

class Item extends StatelessWidget {
  final GroceryItem groceryItem;
  const Item({super.key, required this.groceryItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: groceryItem.category?.color),
          ),
          const SizedBox(
            width: 30,
          ),
          Text(groceryItem.name),
          const Spacer(),
          Text(groceryItem.quantity.toString())
        ],
      ),
    );
  }
}
