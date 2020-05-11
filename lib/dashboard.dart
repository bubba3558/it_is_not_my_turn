import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:it_is_not_my_turn/add_group_page.dart';
import 'package:it_is_not_my_turn/model/const.dart';
import 'package:it_is_not_my_turn/model/user.dart';
import 'package:it_is_not_my_turn/model/userGroup.dart';
import 'package:it_is_not_my_turn/user_group_screen.dart';

class Dashboard extends StatefulWidget {
  final User currentUser;

  Dashboard({Key key, @required this.currentUser}) : super(key: key);

  @override
  State createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  Future userGroups;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetchUserGroup(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var radio = _getElementRatio(snapshot.data);
            return Scaffold(
                body: Container(
                    child: Column(
              children: <Widget>[
                Expanded(flex: radio['header'], child: _header(snapshot.data)),
                Expanded(flex: radio['grid'], child: _grid(snapshot.data)),
                Expanded(flex: radio['footer'], child: footer)
              ],
            )));
          } else {
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            );
          }
        });
  }

  _header(List<UserGroup> groupList) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 20, right: 20, top: 20),
      title: Text(
        appTitle,
        style: TextStyle(color: primaryColor),
      ),
      subtitle: Text('You belong to ' + groupList.length.toString() + ' group',
          style: TextStyle(color: secondaryColor)),
      trailing: Image(
        image: AssetImage('assets/icons/icon_sqr.jpg'),
        width: 40,
      ),
    );
  }

  Widget _grid(List<UserGroup> groupList) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: GridView.count(
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        crossAxisCount: 2,
        children: groupList
            .map((group) => Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                    child: InkWell(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            group.photoUrl == null
                                ? Image(
                                    image: AssetImage(
                                        'assets/icons/no-pictures.png'),
                                    height: 60,
                                  )
                                : Image.network(group.photoUrl, height: 60),
                            Text(group.name)
                          ],
                        ),
                        onTap: () => _onGroupPress()))))
            .toList(),
      ),
    );
  }

  get footer => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlineButton.icon(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0)),
            label: Text('Create the new group'),
            icon: Icon(Icons.create, color: primaryColor),
            onPressed: () => _onAddGroupPress(),
          ),
          OutlineButton.icon(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0)),
            label: Text('Join existing group'),
            icon: Icon(Icons.people, color: primaryColor),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          )
        ],
      );

  Future<List<UserGroup>> _fetchUserGroup() async {
    final QuerySnapshot result = await Firestore.instance
        .collection('userGroups')
        .where('userNames', arrayContains: widget.currentUser.name)
        .getDocuments();
    return result.documents.map((d) => UserGroup.fromJson(d.data)).toList();
  }

  Map<String, int> _getElementRatio(List list) {
    if (list.length == 0) {
      return {'header': 3, 'grid': 1, 'footer': 6};
    }
    if (list.length < 3) {
      return {'header': 1, 'grid': 4, 'footer': 5};
    }
    return {'header': 1, 'grid': 7, 'footer': 2};
  }

  void _onAddGroupPress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddGroupPage(widget.currentUser)),
    );
  }

  void _onGroupPress() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => UserGroupScreen(currentUser: widget.currentUser)),
    );
  }
}
