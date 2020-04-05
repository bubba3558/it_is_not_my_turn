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

class DataRequiredForBuild {
  String mostActiveUser;
  String leastActiveUser;

  DataRequiredForBuild(this.mostActiveUser, this.leastActiveUser);
}

class DutyHistoryState extends State<DutyHistoryScreen> {
  final winnerIcon = 'https://image.flaticon.com/icons/svg/1170/1170611.svg';
  final loserIcon = 'https://image.flaticon.com/icons/svg/43/43646.svg';
  final formatter = new DateFormat('dd-MM-yyyy H:m');
  Duty duty;

  Future<DataRequiredForBuild> dataRequiredForBuild;

  DutyHistoryState({Key key, @required this.duty});

  Future<DataRequiredForBuild> _fetchAllData() async {
    return DataRequiredForBuild(
      await _fetchMostActiveUser(),
      await _fetchLeastActiveUser(),
    );
  }

  @override
  void initState() {
    super.initState();

    dataRequiredForBuild = _fetchAllData();
  }

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
          FutureBuilder<DataRequiredForBuild>(
            future: dataRequiredForBuild,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      padding: const EdgeInsets.all(4.0),
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                      children: <Widget>[
                          buildAwardCard('The most active user:',
                              snapshot.data.mostActiveUser, winnerIcon),
                          buildAwardCard('The most inactive user:',
                              snapshot.data.leastActiveUser, loserIcon),
                        ])
                  : Center(
                      child: CircularProgressIndicator(),
                    );
            },
          ),
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
      leading: history.imageUrl != null
          ? Image.network( history.imageUrl, width: 40)
          : Image(image: AssetImage('assets/icons/no-pictures.png'), width: 40),
      title: Row(children: <Widget>[Text(history.userName)]),
      subtitle: Text(formatter.format(history.completionDate)),
      trailing: history.daysBeforeDeadline >= 0
          ? Text(
              'Done ' +
                  history.daysBeforeDeadline.toString() +
                  ' days before deadline',
              style: TextStyle(color: Colors.greenAccent),
            )
          : Text(
              'Done ' +
                  history.daysBeforeDeadline.toString() + //todo *-1?
                  ' after deadline',
              style: TextStyle(color: Colors.redAccent),
            ),
    );
  }

  Future<String> _fetchLeastActiveUser() async {
    //todo after adding user groups, choose totally inactive (==not included on list)
    // user first
    return _fetchUserByCount(false);
  }

  Future<String> _fetchMostActiveUser() async {
    return _fetchUserByCount(true);
  }

  Future<String> _fetchUserByCount(bool descending) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection('completionHistory')
        .document(duty.name)
        .collection('userStatistics')
        .orderBy('count', descending: descending)
        .limit(1)
        .getDocuments();
    if (snapshot.documents.length > 0) {
      return snapshot.documents[0].documentID;
    } else {
      return '';
    }
  }
}
