import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  final String listName;
  final String listID; // Add this

  Homepage({required this.listName, required this.listID, Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  User? user;
  DatabaseReference? taskRef;
  String? userUid;
  List<Map<String, dynamic>> items = [];

  
@override
void initState() {
  super.initState();
  user = FirebaseAuth.instance.currentUser;
  userUid = user?.uid;
  if (user != null) {
    taskRef = FirebaseDatabase.instance.ref().child('users/$userUid/lists/${widget.listID}/items');
    // Add listener to taskRef here to update items
  }
}

  Widget _title() {
  return Text(widget.listName);
}

  Widget _itemList() { // Widget for the list of items 
    return Expanded(// Expanded is a widget that ensures its child (in this case, the _itemList) takes up all available vertical space within its parent widget.
                    // Expanded is used to make the _itemList fill the remaining vertical space below other widgets in the column, ensuring that the list can scroll within that space.

      child: ListView.builder( // Widget that creates a scrollable list of items 
        itemCount: items.length, // The number of items to display.
        itemBuilder: (context, index) { //callback function that defines how each item in the list should be built.
          final item = items[index]; // Get the item data at the current index.
          return ListTile( //creates a ListTile for each item, displaying the item name, price, and an optional delete icon
            title: Text(item['name'].toString()), // Display the item's name.
            subtitle: Text('Price: \$${item['price']}'), // Display the item's price.
            onTap: () {
              _editItem(index); // Call edit item method on tap 
            },
            trailing: IconButton( // Display delete button after list items
              icon: Icon(Icons.delete),
              onPressed: () async {
                _deleteItem(index);
              },
            ),
          );
        },
      ),
    );
  }

  void _addNewItem(String name, double price) {
  String key = taskRef?.push().key ?? '';  // Ensure taskRef is not null
  if (key.isNotEmpty) {
    taskRef?.child(key).set({  // Use ?. to safely access child
      'name': name,
      'price': price,
    });
    setState(() {
      items.add({'name': name, 'price': price});
    });
  }
}

  void _editItem(int index) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    if (index >= 0) {
      nameController.text = items[index]['name'];
      priceController.text = items[index]['price'].toString();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index >= 0 ? 'Edit Item' : 'Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                final price = double.parse(priceController.text);
                if (index >= 0) {
                  _updateItem(index, name, price);
                } else {
                  _addNewItem(name, price);
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateItem(int index, String name, double price) { // Method for updating list item 
    setState(() {
      items[index]['name'] = name;
      items[index]['price'] = price;
    });
  }

  void _deleteItem(int index) { // Method to remove item 
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            _itemList(),
            ElevatedButton(
              onPressed: () {
                _editItem(-1); // -1 indicates adding a new item
              },
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}