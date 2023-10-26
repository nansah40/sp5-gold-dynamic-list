import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_list/pages/home_page.dart';
import 'package:dynamic_list/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListOfListsScreen extends StatefulWidget {
  @override
  _ListOfListsScreenState createState() => _ListOfListsScreenState();
}

class _ListOfListsScreenState extends State<ListOfListsScreen> {
  final fb = FirebaseDatabase.instance;
  final User? user = Auth().currentUser;
  List<String> lists = [
    'Groceries',
    'To-Do',
    'Movies to Watch',
    // Add more list names here
  ];

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  @override
  Widget build(BuildContext context) {
    var rng = Random();
    var k = rng.nextInt(10000);
    final ref = fb.ref().child('ListOfLists/$k');
    return Scaffold(
      appBar: AppBar(
        title: Text('Lists of Lists'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final listName = lists[index];
                return ListTile(
                  title: Text(listName),
                  onTap: () {
                    // Navigate to the corresponding item list page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Homepage(listName: listName),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Prompt the user to confirm the deletion
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Delete List'),
                            content: Text(
                                'Are you sure you want to delete this list?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteList(index); // Delete the list
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          _userUid(),
          _signOutButton(), // Add the logout button here
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Display a dialog to add a new list
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController listNameController =
                  TextEditingController();
              return AlertDialog(
                title: Text('Create a New List'),
                content: TextField(
                  controller: listNameController,
                  decoration: InputDecoration(labelText: 'List Name'),
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
                      ref.set({
                        'list name': listNameController.text,
                      }).asStream();
                      final name = listNameController.text;
                      if (name.isNotEmpty) {
                        addList(name);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text('Create'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void addList(String name) {
    setState(() {
      lists.add(name);
    });
  }

  void deleteList(int index) {
    setState(() {
      lists.removeAt(index);
    });
  }
}
