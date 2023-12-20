import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoppinglist/Screens/new_item.dart';
import 'package:shoppinglist/data/categories.dart';
import 'package:shoppinglist/models/grocery_item.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});
  @override
  State<ItemsScreen> createState() {
    return _ItemsScreen();
  }
}

class _ItemsScreen extends State<ItemsScreen> {
  List<GroceryItem> groceryItems = [];
  String? _error;
  var isLoading = true;
  void _addItem() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => const NewItem(),
    ));
  }

  void _removeItem(GroceryItem item) async {
    final url = Uri.https('flutter-prep-3775c-default-rtdb.firebaseio.com',
        'shpping-list/${item.id}.json');

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        groceryItems.add(item);
      });
    }
  }

  void loadItems() async {
    final url = Uri.https(
        'flutter-prep-3775c-default-rtdb.firebaseio.com', 'shpping-list.json');
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      _error = 'failed to fetch data please try again soon';
    }

    if (response.body == 'null') {
      setState(() {
        isLoading == false;
      });
      return;
    }
    final Map<String, dynamic> listdata = json.decode(response.body);
    final List<GroceryItem> _loadedItems = [];
    for (final item in listdata.entries) {
      final categoryy = categories.entries
          .firstWhere((element) => element.value.type == item.value['category'])
          .value;
      _loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: categoryy));
    }
    setState(() {
      groceryItems = _loadedItems;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Empty shopping list ,Start adding items!'),
    );
    if (_error != null) {
      setState(() {
        content = Center(
          child: Text(_error!),
        );
      });
    }
    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(groceryItems[index].id.toString()),
            onDismissed: (direction) {
              // Remove the item from the data source
              _removeItem(groceryItems[index]);
              setState(() {
                groceryItems.removeAt(index);
              });
            },
            child: ListTile(
                leading: Icon(
                  Icons.square,
                  color: groceryItems[index].category.color,
                ),
                title: Text(groceryItems[index].name),
                trailing: Text(groceryItems[index].quantity.toString())),
          );
        },
      );
    }
    return Scaffold(
        appBar: AppBar(
            actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
            title: const Text('Your Groceries')),
        body: content);
  }
}
