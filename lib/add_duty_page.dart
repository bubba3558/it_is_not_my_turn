import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddDutyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New duty'),
      ),
      body: new SingleChildScrollView(
          child: new Container(
        margin: new EdgeInsets.all(15.0),
        child: AddDutyForm(),
      )),
    );
  }
}

class AddDutyForm extends StatefulWidget {
  @override
  AddDutyFormState createState() {
    return AddDutyFormState();
  }
}

class AddDutyFormState extends State<AddDutyForm> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _name;
  String _description;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Column(
          children: <Widget>[
            new TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              keyboardType: TextInputType.text,
              validator: validateNotEmpty,
              onSaved: (String val) {
                _name = val;
              },
            ),
            new TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              keyboardType: TextInputType.text,
              onChanged: (String val) {
                _description = val;
              },
            ),
            new SizedBox(
              height: 10.0,
            ),
            new RaisedButton.icon(
              onPressed: save,
              label: Text('Submit'),
              icon: Icon(Icons.save),
            )
          ],
        ));
  }

  String validateNotEmpty(String value) {
    return value.isEmpty ? 'Can not be empty' : null;
  }

  void save() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Firestore.instance
          .collection('duties')
          .add({'name': _name, 'description': _description});
      Fluttertoast.showToast(msg: 'Duty with name $_name was created');
      Navigator.pop(context);
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }
}
