// This class represents each item list 


import 'package:firebase_database/firebase_database.dart'; // Library for Firebase realtime database 
import 'package:flutter/material.dart'; // Core Flutter libaray offering major features for widget building

class ListItemPage extends StatefulWidget {
  final String listID; // Varibable for List Id 
  final String listName;  // Variable for list name 

  const ListItemPage({super.key, required this.listID, required this.listName}); // Constructor taking in listName and ID from list of list screen 

  @override 
  _ListItemPageState createState() => _ListItemPageState(); // Creating state 
}

class ListItem {
  String id; // Varibale for item id 
  String name; // Variable for item name 
  bool completed; // Will be used later for check marks
  double price; // Variable to track price 

  ListItem({required this.id, required this.name, this.completed = false, this.price = 0.0}); // Constructor for ListItem 

  factory ListItem.fromMapEntry(MapEntry<dynamic, dynamic> entry) { // Factory constructor for creating listitems from map entries 
    var key = entry.key; // getting key from map entry 
    var value = entry.value as Map<dynamic, dynamic>?;  // getting values from map entry 
    if (value == null) {
      throw Exception('Map entry data is null'); // exception handling 
    }

    return ListItem( // returning a new instance of list item 
      id: key, // setting id
      name: value['name'] as String? ?? 'Unnamed Item', // setting name
      completed: value['completed'] as bool? ?? false, // setting completed value
      price: (value['price'] as num?)?.toDouble() ?? 0.0, // setting price 
    );
  }
}


class _ListItemPageState extends State<ListItemPage> {
  

 @override
Widget build(BuildContext context) {
  final fb = FirebaseDatabase.instance; // Initialize firebase 
  final ref = fb.ref().child('lists/${widget.listID}/items'); // creating reference to the items of the list 

  return Scaffold(
    appBar: AppBar( // creating app bar 
      title: Text(widget.listName), // setting appbar title to list name 
    ),
 body: StreamBuilder( // Streambuilder to listen to firebase for updates 
  stream: ref.onValue,
  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.hasData && !snapshot.hasError && snapshot.data!.snapshot.value != null) { // checking for errors in snapshot 
      Map<dynamic, dynamic> items = snapshot.data!.snapshot.value as Map<dynamic, dynamic>; // creating a map from the snapshot 
      List<ListItem> listItems = items.entries.map((entry) => ListItem.fromMapEntry(entry)).toList(); // creating list of list items from the map 

       return ListView.builder( // Building the list 
          itemCount: listItems.length, // setting item count to list length 
          itemBuilder: (context, index) {
            ListItem item = listItems[index]; // Setting current item by index 
            return ListTile( // creating list row 
              title: Text(item.name), // set title to item name 
              subtitle: Text("\$${item.price.toStringAsFixed(2)}"), // Displaying price here
              onTap: () => _editItem(item.id, item.name, item.price), // call edit item on tap 
              trailing: IconButton( // adding trailing icon button for delete 
                icon: const Icon(Icons.delete), // setting icon type
                onPressed: () => _deleteItem(item.id), // call delete item  
              ),
          );
        },
      );
    } else {
      return const Center(child: CircularProgressIndicator()); // circular progress indicator if list is empty 
    }
  },
),

    floatingActionButton: FloatingActionButton( // Adding floating action button 
      onPressed: () => _showAddItemDialog(context), // Call show item dialog 
      child: const Icon(Icons.add), // set icon type 
    ),
  );
}
void _showAddItemDialog(BuildContext context) { // Method to
  TextEditingController itemNameController = TextEditingController(); // Test controller for name 
  TextEditingController itemPriceController = TextEditingController(); // Controller for price

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Add New Item"), // set title
        content: Column(
          mainAxisSize: MainAxisSize.min, // To avoid dialog stretching
          children: [
            TextField(
              controller: itemNameController, // set controller 
              decoration: const InputDecoration(hintText: "Item Name"), // set hint 
            ),
            TextField(
              controller: itemPriceController, // set controller 
              decoration: const InputDecoration(hintText: "Price"), // set hint 
              keyboardType: const TextInputType.numberWithOptions(decimal: true), // Setting the keyboard type 
            ),
          ],
        ),
        actions: <Widget>[
          TextButton( // Cancel Button
            child: const Text("Cancel"), // set text 
            onPressed: () => Navigator.of(context).pop(), // return to list screen 
          ),
          TextButton( // Add button
            child: const Text("Add"), // set text 
            onPressed: () {
              if (itemNameController.text.isNotEmpty && itemPriceController.text.isNotEmpty) {
                double price = double.tryParse(itemPriceController.text) ?? 0.0; // Parse the price
                _addItem(itemNameController.text, price); // call add item with name and price 
                Navigator.of(context).pop(); // return to list screen 
              }
            },
          ),
        ],
      );
    },
  );
}

void _addItem(String itemName, double itemPrice) { // Add item to list 
  final fb = FirebaseDatabase.instance; // Create firebase instance 
  final ref = fb.ref().child('lists/${widget.listID}/items'); // Creating reference to firebase 
  ref.push().set({'name': itemName, 'completed': false, 'price': itemPrice}); // seting new item at refrence 
}


void _editItem(String itemId, String currentName, double currentPrice) { // Method for editing item 
  TextEditingController itemNameController = TextEditingController(text: currentName);  // Text editing controller for name
  TextEditingController itemPriceController = TextEditingController(text: currentPrice.toString()); // Text editing controller for price 

  showDialog( // Show dialog box for edit item 
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Edit Item"), // set title
        content: Column(
          mainAxisSize: MainAxisSize.min, // To avoid dialog stretching
          children: [
            TextField( // Name text field 
              controller: itemNameController, // set controller 
              decoration: const InputDecoration(hintText: "Item Name"), // set hint 
            ),
            TextField( // Price text field
              controller: itemPriceController, // set controller
              decoration: const InputDecoration(hintText: "Price"), // set hint 
              keyboardType: const TextInputType.numberWithOptions(decimal: true), // Changing tht keyboard to only show numbers 
            ),
          ],
        ),
        actions: <Widget>[
          TextButton( // Cancel Button
            child: const Text("Cancel"), // set text 
            onPressed: () => Navigator.of(context).pop(), // return to list screen 
          ),
          TextButton( // Save Button
            child: const Text("Save"), // set text
            onPressed: () {
              if (itemNameController.text.isNotEmpty && itemPriceController.text.isNotEmpty) {
                double newPrice = double.tryParse(itemPriceController.text) ?? 0.0; // Parse the price as double
                _updateItem(itemId, itemNameController.text, newPrice); // Pass the price
                Navigator.of(context).pop(); // return to list screen 
              }
            },
          ),
        ],
      );
    },
  );
}

void _updateItem(String itemId, String newName, double newPrice) { // Method for updating items 
  final fb = FirebaseDatabase.instance; // creating firebase instance 
  final ref = fb.ref().child('lists/${widget.listID}/items/$itemId'); // Referenceing firebase based on passed itemid 
  ref.update({'name': newName, 'price': newPrice}); // firebase method to update 
}


void _deleteItem(String itemId) { // Method for delting items
  final fb = FirebaseDatabase.instance; // Creating firebase instance 
  final ref = fb.ref().child('lists/${widget.listID}/items/$itemId'); // referencing firebase based on passed itemid 
  ref.remove(); // firebase method to delete 
}
}
