import 'package:flutter/material.dart';
import 'package:it_is_not_my_turn/login_sign_up_page.dart';

import 'const.dart';

void main() => runApp(LoginSignUpPage());

class MainScreen extends StatefulWidget {
  final String currentUserId;

  MainScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          'Flutter login demo',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new Container(
        child: new Text("Hello World"),
      ),
    );
  }
}
