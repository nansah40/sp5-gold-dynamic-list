// This class represents the reset password screen 

import 'package:flutter/material.dart'; // Core Flutter libaray offering major features for widget building 
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication library
import 'package:fluttertoast/fluttertoast.dart'; // Provides toast functions in flutter 


class ResetPage extends StatefulWidget { // Class for reset page
  const ResetPage({Key?key}) : super(key:key); // Reset page constructor 

  

  @override
  State<ResetPage> createState() => _ResetPageState(); // Overinding reset page state 
}

class _ResetPageState extends State<ResetPage> {

  String? errorMessage = ''; // String for error message when
 

  final auth = FirebaseAuth.instance; // Creating Firebase instance 

  final TextEditingController _controllerEmail = TextEditingController(); // Text editing controller to read in email from user 
  
  Widget _title(){ // Widget for the title 
    return const Text('Reset Your Password');
  }

  Widget _entryField( // Widget for email entry box
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() { // Widget that represents error messages 
    return Text(errorMessage == '' ? '' : 'Something went wrong? $errorMessage');
  }

  Widget _submitButton() { // Widget for the submit button 
  return ElevatedButton(
    onPressed: () async {
      try {
        await auth.sendPasswordResetEmail(email: _controllerEmail.text); // Calling Firebase rest password method 
        Navigator.of(context).pop(); // Return to the login screen

        Fluttertoast.showToast( // Toast
          msg: "Reset Email Sent", // Text for the reset toast 
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1, // Reset toast hang time 
          backgroundColor: Colors.orange, // Color of reset toast 
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (e) {
        // Updating the error message 
        setState(() {
          errorMessage = e.toString(); // seting error message 
        });
      }
    },
    child: const Text('Send Reset Email'), // Text for reset button 
  );
}

  

  @override
  Widget build(BuildContext context) { // Widget build for reset page 
    return Scaffold(
      appBar: AppBar(
        title: _title(), // Adding title to AppBar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _entryField("email", _controllerEmail), // Adding email entry field with text editing controller
          _errorMessage(), // Adding error message 
          _submitButton(), // Adding submit button 
        ]
      ),

    );
  }
  }
