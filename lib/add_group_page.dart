import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:it_is_not_my_turn/model/const.dart';
import 'package:it_is_not_my_turn/model/user.dart';
import 'package:it_is_not_my_turn/model/userGroup.dart';

class AddGroupPage extends StatelessWidget {
  final User currentUser;

  const AddGroupPage(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New user group'),
      ),
      body: Container(
        margin: EdgeInsets.all(15.0),
        child: AddUserGroupForm(currentUser),
      ),
    );
  }
}

class AddUserGroupForm extends StatefulWidget {
  final User currentUser;

  const AddUserGroupForm(this.currentUser);

  @override
  AddUserGroupFormState createState() {
    return AddUserGroupFormState();
  }
}

class AddUserGroupFormState extends State<AddUserGroupForm> {
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _name;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                  padding: EdgeInsets.all(13),
                  child: Column(
                    children: <Widget>[
                      _image != null
                          ? InkWell(
                              child: Image.file(_image, width: 80),
                              onTap: getImage)
                          : SizedBox(
                              height: 80.0,
                              width: 80.0,
                              child: IconButton(
                                onPressed: getImage,
                                icon: Icon(Icons.add_a_photo,
                                    color: Colors.black, size: 80.0),
                              )),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                      ),
                      SizedBox(
                          height: 60,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                            keyboardType: TextInputType.text,
                            validator: validateNotEmpty,
                            onChanged: (String val) {
                              _name = val;
                            },
                          )),
                    ],
                  ))),
          buildSaveButton()
        ]));
  }

  Widget buildSaveButton() {
    return RaisedButton.icon(
      onPressed: save,
      label: Text('Submit', style: TextStyle(color: buttonLabelColor)),
      icon: Icon(Icons.save, color: buttonLabelColor),
      color: buttonColor,
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  String validateNotEmpty(String value) {
    return value.isEmpty ? 'Can not be empty' : null;
  }

  Future<void> save() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      String url = await uploadImage();
      Firestore.instance
          .collection('userGroups')
          .add(toFirebaseUserGroup(_name, [widget.currentUser.name], url));
      Fluttertoast.showToast(msg: 'Group with name $_name was created');
      Navigator.pop(context);
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  Future<String> uploadImage() async {
    if (_image == null) {
      return null;
    }
    File image = File(_image.path);
    StorageReference ref =
        FirebaseStorage.instance.ref().child('images/$_name');
    var uploadTask = ref.putFile(image);
    return await (await uploadTask.onComplete).ref.getDownloadURL();
  }
}
