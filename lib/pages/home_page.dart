import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  final String listName;

  Homepage({required this.listName, Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  User? user;
  DatabaseReference? taskRef;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      taskRef =
          FirebaseDatabase.instance.ref().child('Grocery').child(user!.uid);
    }
    super.initState();
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _itemList() {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item['name'].toString()),
            subtitle: Text('Price: \$${item['price']}'),
            onTap: () {
              _editItem(index);
            },
            trailing: IconButton(
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
    final DatabaseReference taskRef =
        FirebaseDatabase.instance.reference().child('Grocery');
    String key = taskRef.push().key.toString();
    taskRef.push().set({
      'key': key,
      'name': name,
      'price': price,
    });
    setState(() {
      items.add({'name': name, 'price': price});
    });
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

  void _updateItem(int index, String name, double price) {
    setState(() {
      items[index]['name'] = name;
      items[index]['price'] = price;
    });
  }

  void _deleteItem(int index) {
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
