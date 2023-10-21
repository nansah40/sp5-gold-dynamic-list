import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dynamic_list/auth.dart';

class Homepage extends StatefulWidget {
  final String listName;

  Homepage({required this.listName, Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}



class _HomepageState extends State<Homepage> {
  final User? user = Auth().currentUser;
  List<Map<String, dynamic>> items = [
   
  ];

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
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
              onPressed: () {
                _deleteItem(index);
              },
            ),
          );
        },
      ),
    );
  }

  void _addNewItem(String name, double price) {
    setState(() {
      items.add({'name': name, 'price': price});
    });
  }

  void _editItem(int index) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();

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
            _userUid(),
            _signOutButton(),
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