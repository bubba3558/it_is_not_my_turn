import 'dart:ui';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:it_is_not_my_turn/add_duty_page.dart';
import 'package:it_is_not_my_turn/const.dart';
import 'package:it_is_not_my_turn/duty_history.dart';
import 'package:it_is_not_my_turn/login_sign_up_page.dart';
import 'package:it_is_not_my_turn/model/duty.dart';
import 'package:it_is_not_my_turn/model/dutyHistory.dart';

import 'model/user.dart';

void main() => runApp(LoginSignUpPage());

class MainScreen extends StatefulWidget {
  final User currentUser;

  MainScreen({Key key, @required this.currentUser}) : super(key: key);

  @override
  State createState() => MainScreenState(currentUser: currentUser);
}

class MainScreenState extends State<MainScreen> {
  final User currentUser;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isLoading = false;
  List<Duty> _dutiesWithScheduledNotification;

  MainScreenState({Key key, @required this.currentUser});

  @override
  initState() {
    super.initState();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: showOverdueAlert);
  }

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
      body: Container(
          color: bodyColor,
          child: StreamBuilder(
              stream: Firestore.instance.collection('duties').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ));
                } else {
                  List<DocumentSnapshot> duties1 = snapshot.data.documents;
                  var duties =
                      duties1.map((d) => Duty.fromJson(d.data)).toList();
                  _scheduleNotificationAboutOverdueDuties(duties);
                  return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(context, duties[index]),
                      itemCount: snapshot.data.documents.length);
                }
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onAddDutyPress(),
        child: Icon(Icons.add),
        backgroundColor: buttonColor,
      ),
    );
  }

  Widget buildItem(BuildContext context, Duty duty) {
    return ListTile(
        title: Row(
//        todo align somehow
          children: <Widget>[
            Text(duty.name),
            SizedBox(
              width: 16.0,
            ),
            buildLeftTimeInfo(duty.nextDeadline),
          ],
        ),
        subtitle: duty.lastUserName == null
            ? Text('Was never done')
            : Text('last done by ' + duty.lastUserName),
        onTap: () => onInfoClick(duty),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.calendar_today),
                tooltip: 'Creating event',
                color: iconButtonColor,
                disabledColor: bodyColor,
                onPressed: duty.nextDeadline == null ||
                        duty.nextDeadline.isBefore(DateTime.now())
                    ? null
                    : () => onCalendarClick(duty)),
            IconButton(
                icon: Icon(Icons.done),
                tooltip: 'Checked as done',
                color: iconButtonColor,
                disabledColor: bodyColor,
                onPressed:
                    duty.nextDeadline == null ? null : () => onDoneClick(duty)),
          ],
        ));
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
    if (deadline == null) {
      return Text('Task complated', style: TextStyle(color: Colors.black26));
    }
    int diffInDays = calculateDiffInDay(deadline);
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

  DateTime _getNextMidnight(DateTime dateTime) {
    return new DateTime(dateTime.year, dateTime.month, dateTime.day + 1);
  }

  DateTime _getLastMidnight() {
    final now = DateTime.now();
    return new DateTime(now.year, now.month, now.day);
  }

  int calculateDiffInDay(DateTime datetime) {
    final lastMidnight = _getLastMidnight();
    return datetime.difference(lastMidnight).inDays;
  }

  onDoneClick(Duty duty) {
    duty.lastUserName = currentUser.name;
    int diffInDays = calculateDiffInDay(duty.nextDeadline);
    duty.nextDeadline = calculateDeadline(duty);
    Firestore.instance
        .collection('duties')
        .document(duty.name)
        .setData(duty.toJson());
    var historyRef =
        Firestore.instance.collection('completionHistory').document(duty.name);
    historyRef.collection('dutyHistory').add(
        DutyHistory(currentUser.name, DateTime.now(), diffInDays).toJson());
    historyRef
        .collection('userStatistics')
        .document(currentUser.name)
        .setData({'count': 1});
  }

  DateTime calculateDeadline(Duty duty) {
    DateTime nextDeadline =
        calculateNextDate(duty.periodicity, duty.nextDeadline);
    return duty.endDate == null || nextDeadline.isBefore(duty.endDate)
        ? nextDeadline
        : null;
  }

  // ignore: missing_return
  DateTime calculateNextDate(
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

  onInfoClick(Duty duty) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DutyHistoryScreen(duty: duty)));
  }

  onCalendarClick(Duty duty) {
    final Event event = Event(
        title: duty.name,
        description: duty.description,
        allDay: true,
        startDate: duty.nextDeadline,
        endDate: duty.nextDeadline.add(Duration.zero));
    Add2Calendar.addEvent2Cal(event);
  }

  Future showOverdueAlert(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title:
              Text('You have overdue tasks. Check if it is not your turn :)'),
          content: Text('Overdue tasks: $payload'),
        );
      },
    );
  }

  Future _scheduleNotificationAboutOverdueDuties(List<Duty> duties) async {
    List<Duty> futureDuties = duties
        .where((d) =>
            d.nextDeadline != null &&
            d.nextDeadline.isAfter(_getLastMidnight().add(Duration(days: 1))))
        .toList();
    futureDuties.sort((a, b) => a.nextDeadline.compareTo(b.nextDeadline));
    if (listEquals(futureDuties, _dutiesWithScheduledNotification)) {
      return;
    }
    _dutiesWithScheduledNotification = futureDuties;
    flutterLocalNotificationsPlugin.cancelAll();
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'OverdueDuties', 'Overdue duties', 'Notification about overdue tasks',
        importance: Importance.High, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    var newMap = groupBy(futureDuties, (d) => _getNextMidnight(d.nextDeadline));
    int index = 0;
    for (List<Duty> list in newMap.values) {
      await flutterLocalNotificationsPlugin.schedule(
          index++,
          'You have overdue task',
          'Check if it is not your turn :)',
          _getNextMidnight(list.first.nextDeadline),
          platformChannelSpecifics,
          payload: list.map((d) => d.name).join(', '),
          androidAllowWhileIdle: true);
    }
  }
}
