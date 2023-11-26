import 'package:dynamic_list/pages/list_item_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_list/pages/home_page.dart';
import 'package:dynamic_list/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';



class ListOfListsScreen extends StatefulWidget { // This class represents the main screen of the app, displaying a list of lists.
  @override
  _ListOfListsScreenState createState() => _ListOfListsScreenState();
}

class _ListOfListsScreenState extends State<ListOfListsScreen> {
  final fb = FirebaseDatabase.instance;
  final User? user = Auth().currentUser;
  String? userUid;

  Map<String, String> lists = {};  // Changed from List<String> to Map<String, String>

  @override
  void initState() {
    super.initState();
    userUid = user?.uid; 
  }

  Stream<Map<String, String>> getAllListsStream() {
  // Stream for the user's own lists
  final userListsRef = fb.ref().child('users/$userUid/lists');
  final userListsStream = userListsRef.onValue.map((event) {
    final data = event.snapshot.value as Map? ?? {};
    return data.map((key, value) => MapEntry<String, String>(key, value['listName']));
  });

  // Stream for lists shared with the user
  final sharedListsRef = fb.ref().child('users/$userUid/sharedLists');
  final sharedListsStream = sharedListsRef.onValue.map((event) {
    final data = event.snapshot.value as Map? ?? {};
    return data.map((key, value) => MapEntry<String, String>(key, value['listName']));
  });

  // Using rxdart's combineLatest2 to merge the two streams
  return Rx.combineLatest2<Map<String, String>, Map<String, String>, Map<String, String>>(
    userListsStream,
    sharedListsStream,
    (userLists, sharedLists) => {...userLists, ...sharedLists},
  );
}


  void addList(String name) {
    if (userUid != null && name.isNotEmpty) {
      final ref = fb.ref().child('users/$userUid/lists');
      ref.push().set({'listName': name});
    }
  }

  void deleteList(String key) {
    if (userUid != null) {
      final ref = fb.ref().child('users/$userUid/lists/$key');
      ref.remove();
    }
  }

  void _confirmDeleteList(BuildContext context, String key) {
   showDialog(
              context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Delete List'),
                    content: Text('Are you sure you want to delete this list?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();  
                          },
                            child: Text('Cancel'),
                          ),
                                  TextButton(
                                    onPressed: () {
                                      deleteList(key);  // Updated to use key
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Delete'),
                                  ),   
                                ],
                              );
                            },
                          );
}

  void _shareList(String listId, String? listName) {
  TextEditingController _shareController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Share List"),
        content: TextField(
          controller: _shareController,
          decoration: InputDecoration(hintText: "Enter user ID"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Share"),
            onPressed: () {
              String shareWithUserId = _shareController.text;
              // Call function to handle the sharing logic
              _handleShareLogic(listId, listName, shareWithUserId);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}



void _handleShareLogic(String listId, String? listName, String shareWithUserId) {
  shareListWithUser(listId, shareWithUserId).then((_) {
    // Handle successful sharing, like showing a confirmation message
  }).catchError((error) {
    // Handle errors, like showing an error message
  });
}

Future<void> shareListWithUser(String listId, String recipientUserId) async {
  final listRef = fb.ref().child('users/$userUid/lists/$listId');
  final snapshot = await listRef.get();

  if (snapshot.exists) {
    final listData = snapshot.value;
    final sharedListRef = fb.ref().child('users/$recipientUserId/sharedLists');
    sharedListRef.child(listId).set(listData);
  } else {
    // Handle case where the list does not exist
  }
}

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

  Widget _userID() {
  String uidText = user?.uid ?? 'Not available';
  return Column(
    children: [
      SizedBox(height: 4), // Add some spacing between email and UID
      InkWell(
        onTap: () {
          if (user?.uid != null) {
            Clipboard.setData(ClipboardData(text: uidText));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User ID copied to clipboard'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Text(
          '$uidText',
        ),
      ),
    ],
  );
}

  

  
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Your Lists'),
    ),
    body: Column(
      children: [
        Expanded(
          child: StreamBuilder<Map<String, String>>(
            stream: getAllListsStream(), // Updated to use the new function
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              lists = snapshot.data ?? {};
              return ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final key = lists.keys.elementAt(index);
                  final listName = lists[key];
                  return ListTile(
                    title: Text(listName ?? ''),
                    onTap: () {
                      String listID = lists.keys.elementAt(index);
                      String listName = lists[listID] ?? 'Unknown List';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListItemPage(listID: listID, listName: listName),
                        ),
                      );
                    },
                    trailing: SizedBox(
                      width: 96, // Adjust this width as necessary
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () => _shareList(key, listName),
                            tooltip: 'Share List',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _confirmDeleteList(context, key),
                            tooltip: 'Delete List',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        _userUid(),
        _userID(),       // Display the user's UID
        _signOutButton(), // Sign out button
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
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
                    addList(name);
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
}
