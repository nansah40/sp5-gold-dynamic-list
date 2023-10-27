import 'package:flutter/material.dart';
import 'package:dynamic_list/pages/home_page.dart';
import 'package:dynamic_list/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListOfListsScreen extends StatefulWidget { // This class represents the main screen of the app, displaying a list of lists.
  @override
  
  _ListOfListsScreenState createState() => _ListOfListsScreenState(); // Create the state for this widget.
}

class _ListOfListsScreenState extends State<ListOfListsScreen> {
  final User? user = Auth().currentUser; // Get the current user using the Auth class

  
  List<String> lists = [ // Initialize a list of example list names.
    'Groceries',
    'Soccer team',
    'Movies to Watch',
    // Add more list names here
  ];
  
  Future<void> signOut() async {  // Function to sign the user out.
    await Auth().signOut();
  }

  Widget _signOutButton() { // Widget for the "Sign Out" button 
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  Widget _userUid() { // Widget to display the user's email or a placeholder if not logged in.
    return Text(user?.email ?? 'User email');
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Lists'), // Set the text displayed on the appbar 
      ),
      body: Column(
        children: [
          Expanded( // Expanded is a widget that ensures its child (in this case, the ListView.builder) takes up all available vertical space within its parent widget.
                    // Expanded is used to make the ListView.builder fill the remaining vertical space below other widgets in the column, ensuring that the list can scroll within that space.

            child: ListView.builder( // Widget that creates a scrollable list of items 
              itemCount: lists.length, // Set the number of list items based on the length of the 'lists' array.
              itemBuilder: (context, index) { //callback function that defines how each item in the list should be built.
                final listName = lists[index]; // Get the name of the list at the current index.
                return ListTile( //creates a ListTile for each list, displaying the list name and an optional delete icon
                  title: Text(listName), // Display the list name as the title of the ListTile.
                  onTap: () {  // Navigate to the corresponding item list page (Homepage) when tapped
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Homepage(listName: listName),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete), // Display a delete icon on the right side of the list item.
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
                                  Navigator.of(context).pop(); // Close the dialog if the user cancels.
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
          _userUid(),       // Add the userId here 
          _signOutButton(), // Add the logout button here
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Display a dialog to add a new list
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController listNameController = TextEditingController(); // TextEditingContoller for reading and managing the list name that user inputs 
              return AlertDialog( // Method used to display a dialog box 
                title: Text('Create a New List'),
                content: TextField(
                  controller: listNameController,
                  decoration: InputDecoration(labelText: 'List Name'),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog if the user cancels.
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      final name = listNameController.text; // Set name variable to the contents of the textEditing controller 
                      if (name.isNotEmpty) {
                        addList(name); // If a name is provided, call the 'addList' function to add a new list.
                      }
                      Navigator.of(context).pop(); // Close the dialog after list creation.
                    },
                    child: Text('Create'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add), // The button displays an icon for adding a new list.
      ),
    );
  }

  void addList(String name) { // Function to add a new list to the lists array.
    setState(() {
      lists.add(name);
    });
  }

  void deleteList(int index) { // Function to delete a list from the lists array.
    setState(() {
      lists.removeAt(index);
    });
  }
}
