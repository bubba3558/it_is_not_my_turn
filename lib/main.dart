import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:it_is_not_my_turn/add_duty_page.dart';
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
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          appTitle,
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: NetworkImage(
                    'https://cdn.pixabay.com/photo/2015/05/31/14/23/organizer-791939_1280.jpg'),
                fit: BoxFit.cover,
              )),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: primaryColor),
              title: Text(
                'Logout',
                style: TextStyle(color: primaryColor),
              ),
              onTap: signOut,
            ),
          ],
        ),
      ),
      body: new Container(
        child: StreamBuilder(
          stream: Firestore.instance.collection('duties').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) =>
                    buildItem(context, snapshot.data.documents[index]),
                itemCount: snapshot.data.documents.length,
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onAddDutyPress();
        },
        child: Icon(Icons.add),
        backgroundColor: primaryColor,
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Text(document['name']),
    );
  }

  Future<Null> signOut() async {
    GoogleSignIn googleSignIn = new GoogleSignIn();

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginSignUpPage()),
        (Route<dynamic> route) => false);
  }

  void onAddDutyPress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDutyPage()),
    );
  }
}
