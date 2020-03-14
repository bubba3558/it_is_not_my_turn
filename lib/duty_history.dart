import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'const.dart';
import 'model/duty.dart';

class DutyHistoryScreen extends StatefulWidget {
  DutyHistoryScreen({Key key, @required this.duty}) : super(key: key);

  final Duty duty;

  @override
  State createState() => DutyHistoryState(duty: duty);
}

class DutyHistoryState extends State<DutyHistoryScreen> {
  bool isLoading = false;
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
    );
  }
}
