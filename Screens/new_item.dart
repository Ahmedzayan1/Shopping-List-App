import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoppinglist/Screens/itemsscreen.dart';
import 'package:shoppinglist/data/categories.dart';
import 'package:shoppinglist/data/dummy_items.dart';
import 'package:shoppinglist/models/grocery_item.dart';
import 'package:shoppinglist/models/category.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  final mytextcontroller = TextEditingController(text: 'New Item');
  final mynumbercontroller = TextEditingController(text: '1');
  late Category category;
  @override
  void dispose() {
    mytextcontroller.dispose();
    mynumbercontroller.dispose();
    super.dispose();
  }

  void SaveItem(
      GroceryItem newgroceryitem, List<GroceryItem> grocerylist) async {
    _formkey.currentState!.validate();
    final url = Uri.https(
        'flutter-prep-3775c-default-rtdb.firebaseio.com', 'shpping-list.json');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': newgroceryitem.name,
          'quantity': newgroceryitem.quantity,
          'category': newgroceryitem.category.type
        }));

    // grocerylist.add(newgroceryitem);

    // ;
    print(response.body);
    print(response.statusCode);
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const ItemsScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formkey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: mytextcontroller,
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text('Name')),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) return 'enter a valid item';
                    return null;
                  },
                ),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(
                      child: TextFormField(
                    decoration: const InputDecoration(label: Text('Quantity')),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null ||
                          int.tryParse(value)! <= 0) {
                        return 'enter a valid number ';
                      }
                      return null;
                    },
                    controller: mynumbercontroller,
                  )),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(category.value.type)
                                  ],
                                ))
                        ],
                        validator: (value) {
                          if (value == null) {
                            return 'Select a category'; // Add validation for DropdownButtonFormField
                          }
                          return null; // Return null when the input is valid
                        },
                        onChanged: (value) {
                          category = value!;
                          ;
                        }),
                  )
                ]),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          GroceryItem newgroceryitem = GroceryItem(
                              id: mytextcontroller.text,
                              name: mytextcontroller.text,
                              quantity: int.tryParse(mynumbercontroller.text)!,
                              category: category);

                          setState(() {
                            SaveItem(newgroceryitem, groceryItems);
                          });
                        },
                        child: const Text('Add Item')),
                    TextButton(
                        onPressed: () {
                          _formkey.currentState!.reset();
                        },
                        child: const Text('Reset'))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
