import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ListItemPage extends StatefulWidget {
  final String listID;
  final String listName;

  ListItemPage({required this.listID, required this.listName});

  @override
  _ListItemPageState createState() => _ListItemPageState();
}

class ListItem {
  String id;
  String name;
  bool completed;
  double price;

  ListItem({required this.id, required this.name, this.completed = false, this.price = 0.0});

  factory ListItem.fromMapEntry(MapEntry<dynamic, dynamic> entry) {
    var key = entry.key;
    var value = entry.value as Map<dynamic, dynamic>?;
    if (value == null) {
      throw Exception('Map entry data is null');
    }

    return ListItem(
      id: key,
      name: value['name'] as String? ?? 'Unnamed Item',
      completed: value['completed'] as bool? ?? false,
      price: (value['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}


class _ListItemPageState extends State<ListItemPage> {
  // Firebase methods to get, add, edit, and delete items...

 @override
Widget build(BuildContext context) {
  final fb = FirebaseDatabase.instance;
  final ref = fb.ref().child('lists/${widget.listID}/items');

  return Scaffold(
    appBar: AppBar(
      title: Text(widget.listName),
    ),
 body: StreamBuilder(
  stream: ref.onValue,
  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.hasData && !snapshot.hasError && snapshot.data!.snapshot.value != null) {
      Map<dynamic, dynamic> items = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
      List<ListItem> listItems = items.entries.map((entry) => ListItem.fromMapEntry(entry)).toList();

       return ListView.builder(
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            ListItem item = listItems[index];
            return ListTile(
              title: Text(item.name),
              subtitle: Text("\$${item.price.toStringAsFixed(2)}"), // Display price here
              onTap: () => _editItem(item.id, item.name, item.price),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteItem(item.id),
              ),
          );
        },
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  },
),

    floatingActionButton: FloatingActionButton(
      onPressed: () => _showAddItemDialog(context),
      child: Icon(Icons.add),
    ),
  );
}
void _showAddItemDialog(BuildContext context) {
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemPriceController = TextEditingController(); // Controller for price

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add New Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min, // To avoid dialog stretching
          children: [
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(hintText: "Item Name"),
            ),
            TextField(
              controller: _itemPriceController,
              decoration: InputDecoration(hintText: "Price"),
              keyboardType: TextInputType.numberWithOptions(decimal: true), // For price input
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Add"),
            onPressed: () {
              if (_itemNameController.text.isNotEmpty && _itemPriceController.text.isNotEmpty) {
                double price = double.tryParse(_itemPriceController.text) ?? 0.0; // Parse the price
                _addItem(_itemNameController.text, price); // Now passing two arguments
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

void _addItem(String itemName, double itemPrice) {
  final fb = FirebaseDatabase.instance;
  final ref = fb.ref().child('lists/${widget.listID}/items');
  ref.push().set({'name': itemName, 'completed': false, 'price': itemPrice});
}


void _editItem(String itemId, String currentName, double currentPrice) {
  TextEditingController _itemNameController = TextEditingController(text: currentName);
  TextEditingController _itemPriceController = TextEditingController(text: currentPrice.toString());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Edit Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min, // To avoid dialog stretching
          children: [
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(hintText: "Item Name"),
            ),
            TextField(
              controller: _itemPriceController,
              decoration: InputDecoration(hintText: "Price"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Save"),
            onPressed: () {
              if (_itemNameController.text.isNotEmpty && _itemPriceController.text.isNotEmpty) {
                double newPrice = double.tryParse(_itemPriceController.text) ?? 0.0; // Parse the price as double
                _updateItem(itemId, _itemNameController.text, newPrice); // Pass the parsed price
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

void _updateItem(String itemId, String newName, double newPrice) {
  final fb = FirebaseDatabase.instance;
  final ref = fb.ref().child('lists/${widget.listID}/items/$itemId');
  ref.update({'name': newName, 'price': newPrice});
}


void _deleteItem(String itemId) {
  final fb = FirebaseDatabase.instance;
  final ref = fb.ref().child('lists/${widget.listID}/items/$itemId');
  ref.remove();
}
}
