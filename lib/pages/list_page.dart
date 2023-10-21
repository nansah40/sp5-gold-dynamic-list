import 'package:flutter/material.dart';
import 'package:dynamic_list/pages/home_page.dart';
import 'package:dynamic_list/auth.dart';

class ListOfListsScreen extends StatefulWidget {
  @override
  _ListOfListsScreenState createState() => _ListOfListsScreenState();
}

class _ListOfListsScreenState extends State<ListOfListsScreen> {
  List<String> lists = [
    'Groceries',
    'To-Do',
    'Movies to Watch',
    // Add more list names here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lists of Lists'),
      ),
      body: ListView.builder(
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
                      content: Text('Are you sure you want to delete this list?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteList(index); // Delete the list
                            Navigator.of(context).pop(); // Close the dialog
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Display a dialog to add a new list
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController listNameController = TextEditingController();
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
