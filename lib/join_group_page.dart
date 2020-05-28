import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:it_is_not_my_turn/model/const.dart';
import 'package:it_is_not_my_turn/model/user.dart';

class JoinGroupPage extends StatelessWidget {
  final User currentUser;

  const JoinGroupPage(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join group'),
      ),
      body: Container(
        margin: EdgeInsets.all(15.0),
        child: JoinGroupForm(currentUser),
      ),
    );
  }
}

class JoinGroupForm extends StatelessWidget {
  User currentUser;

  JoinGroupForm(this.currentUser);

  String _group_id;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      TextFormField(
        textAlign: TextAlign.center,
        decoration: const InputDecoration(labelText: 'Name'),
        keyboardType: TextInputType.text,
        validator: validateNotEmpty,
        onChanged: (String val) {
          _group_id = val;
        },
      ),
      joinButton(context)
    ]);
  }

  Widget joinButton(BuildContext context) {
    return RaisedButton.icon(
      onPressed: () => save(context),
      label: Text('Join', style: TextStyle(color: buttonLabelColor)),
      icon: Icon(Icons.group_add, color: buttonLabelColor),
      color: buttonColor,
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  String validateNotEmpty(String value) {
    return value.isEmpty ? 'Can not be empty' : null;
  }

  Future<void> save(BuildContext context) async {
    if (_group_id.length == 0) {
      Fluttertoast.showToast(msg: 'Group id can not be empty');
      return;
    }
    DocumentSnapshot snapshot = await Firestore.instance
        .collection('userGroups')
        .document(_group_id)
        .get();
    if (snapshot.exists) {
      //todo replace with server function or list with collection
      _join_group(snapshot, context);
    } else {
      Fluttertoast.showToast(msg: 'Group with id $_group_id does not exist');
    }
  }

  void _join_group(DocumentSnapshot snapshot, BuildContext context) {
    var users = snapshot.data['userNames'] as List;
    if (users == null)
      users = [currentUser.name];
    else {
      if (users.contains(currentUser.name)) {
        Fluttertoast.showToast(
            msg: 'You are already a member of $_group_id group');
        return;
      }
      users.add(currentUser.name);
    }
    snapshot.reference.updateData({'userNames': users});
    Fluttertoast.showToast(msg: 'You joined $_group_id group');
    Navigator.pop(context);
  }
}
