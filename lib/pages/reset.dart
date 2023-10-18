import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ResetPage extends StatefulWidget {
  const ResetPage({Key?key}) : super(key:key);

  

  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {

  String? errorMessage = '';
 

  final auth = FirebaseAuth.instance;

  final TextEditingController _controllerEmail = TextEditingController();
  
  Widget _title(){
    return const Text('reset');
  }

  Widget _entryField(
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

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton(){
    return ElevatedButton(
      onPressed: (){
        auth.sendPasswordResetEmail(email: _controllerEmail.text);
        Navigator.of(context).pop();
        
        Fluttertoast.showToast(
        msg: "Reset Email Sent",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0
    );
      }
        ,
        child: Text('Send Reset Email'),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _entryField("email", _controllerEmail),
          _errorMessage(),
          _submitButton(),
        ]
      ),

    );
  }
  }
