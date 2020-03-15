import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:it_is_not_my_turn/model/dutyHistory.dart';

import 'const.dart';
import 'model/duty.dart';

class DutyHistoryScreen extends StatefulWidget {
  DutyHistoryScreen({Key key, @required this.duty}) : super(key: key);

  final Duty duty;

  @override
  State createState() => DutyHistoryState(duty: duty);
}

class DutyHistoryState extends State<DutyHistoryScreen> {
  final winnerIcon = 'https://image.flaticon.com/icons/svg/1170/1170611.svg';
  final loserIcon = 'https://image.flaticon.com/icons/svg/43/43646.svg';
  final formatter = new DateFormat('dd-MM-yyyy H:m');
  Duty duty;

  DutyHistoryState({Key key, @required this.duty});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text(
            duty.name,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(children: <Widget>[
          GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.all(4.0),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              children: <Widget>[
//                        todo count statistics
                buildAwardCard(
                    'The most active user:', 'Martyna Kania', winnerIcon),
                buildAwardCard(
                    'The most inactive user:', 'Martyna Kania', loserIcon),
              ]),
          Text('History:', style: TextStyle(fontSize: 20)),
          Expanded(
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('completionHistory')
                      .document(duty.name)
                      .collection('dutyHistory')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(themeColor)),
                      );
                    } else {
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) =>
                            buildItem(snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                      );
                    }
                  }))
        ]));
  }

  Widget buildAwardCard(String title, String userName, String svnIconUrl) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
              width: 100, height: 100, child: SvgPicture.network(svnIconUrl)),
          SizedBox(height: 10),
          Text(title),
          Text(userName, style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Widget buildItem(DocumentSnapshot document) {
    DutyHistory history = DutyHistory.fromJson(document.data);
    return ListTile(
      title: Row(children: <Widget>[Text(history.userName)]),
      subtitle: Text(formatter.format(history.completionDate)),
      trailing: history.daysBeforeDeadline >= 0
          ? Text(
              'Done ' +
                  history.daysBeforeDeadline.toString() +
                  ' before deadline',
              style: TextStyle(color: Colors.greenAccent),
            )
          : Text(
              'Done ' +
                  history.daysBeforeDeadline.toString() +
                  ' after deadline',
              style: TextStyle(color: Colors.redAccent),
            ),
    );
  }
}
