//Main Method of the app

import 'package:flutter/material.dart'; // Core Flutter libaray offering major features for widget building 
import 'package:firebase_core/firebase_core.dart'; // Core Firebase Library 
import 'package:dynamic_list/widget_tree.dart'; // Widet_tree class that hold the login screens 


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that flutter in initialized 
  await Firebase.initializeApp(); // Initialize Firebase 

  runApp(const MyApp()); // Start the App
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // App constructor 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disables debug banner 
      theme: ThemeData(
        primarySwatch: Colors.orange, // Setting the color theme of the app
      ),
      home: const WidgetTree(), // Create the widget tree and set it as the app homescreen 
    );
  }
}

