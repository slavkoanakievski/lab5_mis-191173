import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab0345_1911143/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login or Register page"),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controllerEmail,
              decoration: InputDecoration(labelText: "Input email here"),
            ),
            TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              controller: _controllerPassword,
              decoration: InputDecoration(labelText: "Input password here",),
            ),
            Padding(padding: EdgeInsets.only(top: 10.0), child: ElevatedButton(onPressed: createUserWithEmailAndPassword, child: const Text("Register"))),
            Padding(padding: EdgeInsets.only(top: 10.0), child: ElevatedButton(onPressed: signInWithEmailAndPassword, child: const Text("Login")))
          ],
        ),
      ),
    );
  }

}
