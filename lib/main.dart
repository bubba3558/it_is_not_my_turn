import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
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
  State createState() => MainScreenState(currentUserId: currentUserId);
}

class MainScreenState extends State<MainScreen> {
  bool isLoading = false;
  final String currentUserId;

  MainScreenState({Key key, @required this.currentUserId});

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
                ),
              ),
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
        backgroundColor: buttonColor,
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    var lastUser = document['lastUserId'];
    return ListTile(
      title: Row(
//        todo align somehow
        children: <Widget>[
          Text(document['name']),
          SizedBox(
            width: 16.0,
          ),
          buildLeftTimeInfo(document['nextDeadline'].toDate()),
        ],
      ),
      subtitle: lastUser == null
          ? Text('Was never done')
          : Text('last done by $lastUser'),
      trailing: new IconButton(
          icon: Icon(Icons.done),
          tooltip: 'Increase volume by 10',
          onPressed: () => onDoneClick(document)),
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

  Widget buildLeftTimeInfo(DateTime deadline) {
//    todo choose better colors
    final now = DateTime.now();
    final lastMidnight = new DateTime(now.year, now.month, now.day);
    int diffInDays = deadline.difference(lastMidnight).inDays;
    if (diffInDays < 0) {
      diffInDays *= -1;
      return Text('Overdue by $diffInDays',
          style: TextStyle(color: Colors.red));
    }
    if (diffInDays == 0) {
      return Text('Do it today', style: TextStyle(color: Colors.yellow));
    }
    if (diffInDays < 7) {
      return Text('Left $diffInDays days',
          style: TextStyle(color: Colors.green));
    }
    int weeksLeft = (diffInDays / 7).floor();
    if (diffInDays < 5) {
      return Text('Left $weeksLeft weeks',
          style: TextStyle(color: Colors.blueGrey));
    } else {
      return Text('Left more than 4 weeks',
          style: TextStyle(color: Colors.grey));
    }
  }

  onDoneClick(DocumentSnapshot task) {
    task.reference.updateData({
      'nextDeadline': calculateNextDeadline(
          EnumToString.fromString(Periodicity.values, task['periodicity']),
          task['nextDeadline'].toDate()),
      'lastUserId': currentUserId
    });
  }

  // ignore: missing_return
  DateTime calculateNextDeadline(
      Periodicity periodicity, DateTime currentDeadline) {
    const frequency = 1;
    var now = DateTime.now();
    switch (periodicity) {
      case Periodicity.Daily:
        return DateTime(now.year, now.month, now.day + frequency,
            currentDeadline.hour, currentDeadline.minute);
      case Periodicity.Weekly:
        return DateTime(now.year, now.month, now.day + frequency * 7,
            currentDeadline.hour, currentDeadline.minute);
      case Periodicity.Monthly:
        return DateTime(now.year, now.month + frequency, now.day,
            currentDeadline.hour, currentDeadline.minute);
      case Periodicity.Annually:
        return DateTime(now.year + frequency, now.month, now.day,
            currentDeadline.hour, currentDeadline.minute);
    }
  }
}
