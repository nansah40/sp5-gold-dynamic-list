// This class represents the initial list screen of the app 
// It contains the funtions to create lists as well as share them

import 'package:dynamic_list/pages/list_item_page.dart'; // Importing list_item_page.dart which represents list items
import 'package:firebase_database/firebase_database.dart'; // Library for Firebase realtime database 
import 'package:flutter/material.dart'; // Core Flutter libaray offering major features for widget building
import 'package:dynamic_list/auth.dart'; // Class that hold authentifcation functions
import 'package:firebase_auth/firebase_auth.dart'; //Firebase authetifaction library 
import 'package:rxdart/rxdart.dart'; // Librabry that provides the ability to merge multiple input streams into one 
import 'package:flutter/services.dart'; // Libary for using system level functions (clipboard in this case)



class ListOfListsScreen extends StatefulWidget { // This class represents the main screen of the app, displaying a list of lists.
  const ListOfListsScreen({super.key}); // Constructor 
 
  @override
  _ListOfListsScreenState createState() => _ListOfListsScreenState(); // Create state 
}

class _ListOfListsScreenState extends State<ListOfListsScreen> {
  final fb = FirebaseDatabase.instance; // Creating Firebase instance 
  final User? user = Auth().currentUser; // Getting the current user from the Auth class 
  String? userUid; // Create variable for the users ID

  Map<String, String> lists = {};  // Map of string to string that represents the list

  @override
  void initState() {
    super.initState();
    userUid = user?.uid; // Gets the UID of the current user and set it
  }

  Stream<Map<String, String>> getAllListsStream() { // Method for geting a users list streams and shared list stream and combining them 
  // Stream for the user's own lists
  final userListsRef = fb.ref().child('users/$userUid/lists'); // Creating reference to Firebase for the users lists 
  // Extracting data from the event snapshot and converting it to a Map.
  final userListsStream = userListsRef.onValue.map((event) { // Getting data from the event snapshot and changing to a map 
    final data = event.snapshot.value as Map? ?? {};
    return data.map((key, value) => MapEntry<String, String>(key, value['listName'])); // Each map entry uses the lists id as key and the value is the lists name
  });

  // Stream for lists shared with the user
  final sharedListsRef = fb.ref().child('users/$userUid/sharedLists'); // Creating reference to Firebase for the users shared lists
  final sharedListsStream = sharedListsRef.onValue.map((event) {  // Getting data from the event snapshot and changing to a map
    final data = event.snapshot.value as Map? ?? {}; 
    return data.map((key, value) => MapEntry<String, String>(key, value['listName'])); // Each map entry uses the lists id as key and the value is the lists name
  });

  // Using rxdarts combineLatest2 too merge the two streams
  return Rx.combineLatest2<Map<String, String>, Map<String, String>, Map<String, String>>(
    userListsStream,
    sharedListsStream,
    (userLists, sharedLists) => {...userLists, ...sharedLists},
  );
}


  void _addList(String name) { // This Method takes a name and create a list in firebase 
    if (userUid != null && name.isNotEmpty) { 
      final ref = fb.ref().child('users/$userUid/lists'); // Creating reference to firebase where users lists are stored 
      ref.push().set({'listName': name}); // Creates a id for the list item and sets it with the name 
    }
  }

  void _deleteList(String key) { // This method takes a list key and deletes it in firebase 
    if (userUid != null) {
      final ref = fb.ref().child('users/$userUid/lists/$key'); // Creates a reference to the list in firebase 
      ref.remove(); // Deletes the referenced list 
    }
  }

  void _confirmDeleteList(BuildContext context, String key) { // Method for showing confirm delete dialog 
   showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete List'), // Set title here
          content: const Text('Are you sure you want to delete this list?'), // Set the message here 
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // return to list screen
                },
                child: const Text('Cancel'), // set cancel button text here 
                 ),
                    TextButton(
                    onPressed: () {
                      _deleteList(key);  // Call delete list method 
                      Navigator.of(context).pop(); // return to list screen 
                      },
                       child: const Text('Delete'), // Set Delete button text here 
                     ),   
           ],
      );
    },
  );
}

  void _shareList(String listId, String? listName) { // Method for showing share list dialog box and calling handle share logic
  TextEditingController shareController = TextEditingController(); // text editing controller for taking in uid to share with 

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Share List"), // Dialog box tile 
        content: TextField(
          controller: shareController,
          decoration: const InputDecoration(hintText: "Enter User ID"), // Set hint text here 
        ),
        actions: <Widget>[
          TextButton( // Button for cancel 
            child: const Text("Cancel"), // set text here
            onPressed: () => Navigator.of(context).pop(), // return to list screen 
          ),
          TextButton( // Button for share
            child: const Text("Share"), // set text here
            onPressed: () {
              String shareWithUserId = shareController.text; // Set sharing user id
              _handleShareLogic(listId, listName, shareWithUserId); // Call handle share logic method 
              Navigator.of(context).pop(); // return to list screen 
            },
          ),
        ],
      );
    },
  );
}

void _showAddItemDialog(BuildContext context) { // Method to show add item dialog 
  showDialog(
          context: context,
          builder: (context) {
            TextEditingController listNameController = TextEditingController(); // text editing controller 
            return AlertDialog(
              title: const Text('Create a New List'), // Set title here
              content: TextField(
                controller: listNameController,
                decoration: const InputDecoration(labelText: 'List Name'), // Set hint here
              ),
              actions: <Widget>[
                TextButton( // Cancel Button
                  onPressed: () {
                    Navigator.of(context).pop(); // Return to list screen
                  },
                  child: const Text('Cancel'), // set text here 
                ),
                TextButton( // create button 
                  onPressed: () {
                    final name = listNameController.text; // set list name 
                    _addList(name); // call add list method with the name 
                    Navigator.of(context).pop(); // return to list screen 
                  },
                  child: const Text('Create'), // set text here 
                ),
             ],
      );
    },
  );
}




void _handleShareLogic(String listId, String? listName, String shareWithUserId) { // Method for sharing list 
  _shareListWithUser(listId, shareWithUserId).then((_) { // starting the sharing process 
    
  }).catchError((error) { // error checking 
    
  });
}

Future<void> _shareListWithUser(String listId, String recipientUserId) async { // Method to share list with user 
  final listRef = fb.ref().child('users/$userUid/lists/$listId'); // Creating reference to list in firebase 
  final snapshot = await listRef.get(); // geting the snapshot for the list 

  if (snapshot.exists) {
    final listData = snapshot.value; // saving the snapshot of the list 
    final sharedListRef = fb.ref().child('users/$recipientUserId/sharedLists'); // Creating reference to shared lists in firebase 
    sharedListRef.child(listId).set(listData); // Add the list to the shared list of the entered uid 
  } else {
   
  }
}

  Future<void> _signOut() async { // Function for signout 
    await Auth().signOut(); // Call signout from Auth.dart 
  }

  Widget _signOutButton() { // Sign out button widget 
    return ElevatedButton(
      onPressed: _signOut, // call signout method 
      child: const Text('Sign Out'), // Set button text here 
    );
  }

  Widget _userUid() { // Widget for user email
    return Text(user?.email ?? 'User email');
  }

  Widget _userID() { // Widget to display user id 
  String uidText = user?.uid ?? 'Not available'; // Variable for uidText 
  return Column(
    children: [
      const SizedBox(height: 4), // Adding some spacing between email and UID
      InkWell( // Allows user to click on user id and save it to clipoard 
        onTap: () {
          if (user?.uid != null) {
            Clipboard.setData(ClipboardData(text: uidText)); // set the uid to be saved to clipboard 
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User ID copied to clipboard'), // Notifcation message set here 
                duration: Duration(seconds: 2), // set the messages duration here 
              ),
            );
          }
        },
        child: Text(
          uidText, // Setting the text to uid 
        ),
      ),
    ],
  );
}

Widget _buildListView(Map<String, String> lists) { // Widget for the listview 
  return ListView.builder(
    itemCount: lists.length, // set itemcount to the lenght of the list 
    itemBuilder: (context, index) {
      final key = lists.keys.elementAt(index); // Setting key of the current element by the current index 
      final listName = lists[key]; // Setting listname here 
      return _buildListItem(key, listName); // Adding the item to the list view 
    },
  );
}

Widget _buildListItem(String key, String? listName) { // Method to build a list item (a row in the list view)
  return ListTile(
    title: Text(listName ?? ''), // Set the list title to list name 
    onTap: () => _navigateToListItemPage(key, listName ?? 'Unknown List'), // Call method to navigate to that lists itempage 
    trailing: _buildListItemTrailing(key, listName), // adds trailing icons to the list 
  );
}

Widget _buildListItemTrailing(String key, String? listName) { // Method for building the trailing icon buttons 
  return SizedBox(
    width: 96, // 
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton( // Share button
          icon: const Icon(Icons.share), // Setting icon type 
          onPressed: () => _shareList(key, listName), // Call share list method
          tooltip: 'Share List', // Set tool tip here
        ),
        IconButton( // Delete Button 
          icon: const Icon(Icons.delete), // Setting icon type 
          onPressed: () => _confirmDeleteList(context, key), // call delete list method 
          tooltip: 'Delete List', // Set tool tip here
        ),
      ],
    ),
  );
}

void _navigateToListItemPage(String listID, String listName) { // This Method navigates to a desired list itempage 
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ListItemPage(listID: listID, listName: listName), // Creating an instance of list item page using listID and listName 
    ),
  );
}

Widget _buildFloatingActionButton() { // Widget for floating action button 
  return FloatingActionButton(
    onPressed: () => _showAddItemDialog(context), // Calls the method to show the add item dialog box 
    child: const Icon(Icons.add), // Setting the icon type here 
  );
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar( // Creating the appbar
      title: const Text('Your Lists'), // Set appbar title here
    ),
    body: Column( // Organizing widgets into a verical column 
      children: [
        Expanded( // Using expanded so streambuilder takes all available space 
          child: StreamBuilder<Map<String, String>>( // Widget that listens to the streams and displays them 
            stream: getAllListsStream(), // Getting the stream from the Method 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) { // Showing a circular progress indicator when loading 
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}')); // Showing Error if the snapshot has a problem 
              }
              lists = snapshot.data ?? {}; // Update the list with the snapshot data 
              return _buildListView(lists); // Calling method to build a listview 
            },
          ),
        ),
        _userUid(), // Adding user email
        _userID(), // Adding userid
        _signOutButton(), // adding signout button 
      ],
    ),
    floatingActionButton: _buildFloatingActionButton(), // Add new list floating action button 
  );
}
}
