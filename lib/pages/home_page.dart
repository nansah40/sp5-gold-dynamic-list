import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  final String listName; // Create final variable listName 

  Homepage({required this.listName, Key? key}) : super(key: key); // constructor for the Homepage class 

  @override
  _HomepageState createState() => _HomepageState(); // Create Homepage state 
}


class _HomepageState extends State<Homepage> { // The list of items to be displayed. Initially empty.
  List<Map<String, dynamic>> items = [
   
  ];

  Widget _title() { // Widget for the title 
    return const Text('List Name');
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
              onPressed: () {
                _deleteItem(index); // Call delte item  method when button is pressed 
              },
            ),
          );
        },
      ),
    );
  }

  void _addNewItem(String name, double price) { // Method for adding new item to the list 
    setState(() {
      items.add({'name': name, 'price': price});
    });
  }

  void _editItem(int index) async { // Method for editing an item 
    TextEditingController nameController = TextEditingController(); // Text editing controllers for name
    TextEditingController priceController = TextEditingController(); // Text editing controller for price 

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
              onPressed: () {
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