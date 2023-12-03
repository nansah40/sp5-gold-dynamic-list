// This class is basically a container for the Authenifcation functions provided by Firebase

import 'package:firebase_auth/firebase_auth.dart'; // Authentifcation Library for Firebase 

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Creating an instance of FirebaseAuth 

  User? get currentUser => _firebaseAuth.currentUser; // Gets the current user if there is one signed in 

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges(); // Stream that tracks the users sign in state 


Future<void> signIn({ // Method for signing in the user using email and password 
  required String email,     // String for email
  required String password,  // Strimg for password 
}) async {
  await _firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}


Future<void> createUser({ // Method for creating user account using email and password 
  required String email, // string for email
  required String password, // string for password 
}) async {
  await _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}

Future<void> signOut() async { // Method for signing out the user 
  await _firebaseAuth.signOut();
}

}