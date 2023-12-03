// This class plays an important role in the initial startup of the App.
// The Login pages are essentially built on top of this class 

import 'package:dynamic_list/auth.dart'; // Class that handles most of the authentification with Firebase 
import 'package:dynamic_list/pages/list_page.dart'; // The apps inital list screen 
import 'package:dynamic_list/pages/login_register_page.dart'; // The apps login and registration page 
import 'package:flutter/material.dart'; // Core Flutter libaray offering major features for widget building 

class WidgetTree extends StatefulWidget { // Creating WidgetTree class
  const WidgetTree({Key ? key}) : super(key: key); // Constructor for class 

  @override
  State<WidgetTree> createState() => _WidgetTreeState(); // Overiding create state method and linking WidgetTree to _WidgetTreeState

}

class _WidgetTreeState extends State<WidgetTree> { 

  @override  
  Widget build(BuildContext context) { // Widget Build for WidgetTree
    return StreamBuilder(  // StreamBuilder that listens for the Firebase Auth state changes 
      stream: Auth().authStateChanges, // Stream from auth.dart that listens to user sign in state 
      builder: (context, snapshot) {
        if (snapshot.hasData) { 
          return ListOfListsScreen(); // Return Homepage, logging in the user 
        } else{
          return const LoginPage(); // Do not login user 
        }
      }
    );
    
  }
}