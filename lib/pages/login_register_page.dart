// This class represnts the login and registration pages 

import 'package:dynamic_list/pages/reset.dart'; // Firebase librabry for reset password
import 'package:flutter/material.dart'; // Core Flutter libaray offering major features for widget building 
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentification Library 
import 'package:dynamic_list/auth.dart'; // File that hold authentification features

class LoginPage extends StatefulWidget { // LoginPage class that represents login page 
  const LoginPage({Key?key}) : super(key:key); // constructor for LoginPage 

  

  @override
  State<LoginPage> createState() => _LoginPageState(); // Creating login page state 
}

class _LoginPageState extends State<LoginPage> { 

  String? errorMessage = ''; // String to hold potential error messages 
  bool isLogin = true; // Boolean to track login 

  final TextEditingController _controllerEmail = TextEditingController(); // Text editing controller for email
  final TextEditingController _controllerPassword = TextEditingController(); // Text editing controller for password 

  Future<void> signInWithEmailAndPassword() async { // Method for signing in with email and password 
    try { 
      await Auth().signIn( // Call sign in method from Auth.dart 
        email: _controllerEmail.text, // pass signIn method user inputs 
        password: _controllerPassword.text,
        );
    } on FirebaseAuthException catch (e) { 
    setState(() {
      errorMessage = e.message; // set error message from firebase 
    });
  }
  }

  Future<void> createUserWithEmailAndPassword() async{ // Method for creating user using firebase 
    try{
      await Auth().createUser( // Call creat user from Auth.dart 
        email: _controllerEmail.text, // Pass create user method users inputs 
        password: _controllerPassword.text,
        );
    } on FirebaseAuthException catch (e) { 
      setState(() {
        errorMessage = e.message; // set error message from firebase 
      });
    }
  }

  Widget _title(){
    return const Text('Dynamic Grocery Lists'); // Title for app bar
  }

  Widget _entryFieldU( // Widget for username entry field 
    String title,
    TextEditingController controller, // text editing controller for entry field 
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }
  Widget _entryFieldP( // widget for the password entryfield
    String title, 
    TextEditingController controller, // Text controller for password 
  ) {
    return TextField(
      controller: controller,
      obscureText: true, // Hides password input 
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Something went wrong? $errorMessage'); // error message 
  }

  Widget _submitButton(){ // Submit button widget 
    return ElevatedButton(
      onPressed:
        isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword, // switched between login and registration button depending on isLogin bool
        child: Text(isLogin ? 'Login' : 'Register'), // Set text for buttons here 
    );
  }

  Widget _loginOrRegisterButton() { // Widget for login or registration button 
    return TextButton( 
      onPressed: () {
        setState(() { 
          isLogin = !isLogin; // set the state of isLogin
      });
      },
      child: Text(isLogin ? 'Register Instead' : 'Login Instead'), // Set text for login/regitration button 
    );
  }

  Widget _forgotPasswordButton() { // Widget for forgot password text button
    return TextButton(
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ResetPage())) // Navigate to forgot password screen
        
      ,
      child: const Text('Forgot Password?'), // Text for forgot passowrd button 
    );
  }

  @override
  Widget build(BuildContext context) { // Widget Build for loginpage 
    return Scaffold(
      appBar: AppBar( // Building app bar 
        title: _title(), // Title on app bar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _entryFieldU("email", _controllerEmail), // Adding email text box 
          _entryFieldP('password', _controllerPassword), // Adding password text box
          _errorMessage(), // Adding error message 
          _submitButton(), // Adding submit button 
          _loginOrRegisterButton(), // Adding Login/Registration button 
          _forgotPasswordButton() // Adding forgot passwod button 
        ]
      ),

    );
  }
  }
