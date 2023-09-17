import 'package:lab0345_1911143/auth.dart';
import 'package:lab0345_1911143/main.dart';
import 'pages/login_register_page.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot){
        if(snapshot.hasData){
          return const MyHomePage(title: "Marko");
        }
        else{
          return const LoginPage();
        }
      },

    );
  }



}