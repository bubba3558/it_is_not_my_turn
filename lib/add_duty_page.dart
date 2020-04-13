import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:it_is_not_my_turn/model/const.dart';
import 'package:it_is_not_my_turn/model/duty.dart';

class AddDutyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New task'),
      ),
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.all(15.0),
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
  DateTime _startDate = DateTime.now();
  DateTime _endDate;
  Periodicity _periodicity = Periodicity.Daily;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              keyboardType: TextInputType.text,
              validator: validateNotEmpty,
              onChanged: (String val) {
                _name = val;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              keyboardType: TextInputType.text,
              onChanged: (String val) {
                _description = val;
              },
            ),
            buildStartDatePicker(),
            buildEndDatePicker(),
            buildPeriodicityChoice(),
            SizedBox(
              height: 10.0,
            ),
            buildSaveButton(),
          ],
        ));
  }

  Widget buildStartDatePicker() {
    return DateTimeField(
      decoration: InputDecoration(labelText: 'Start date'),
      initialValue: _startDate,
      onChanged: (value) => setState(() => _startDate = value),
      onShowPicker: (context, currentValue) {
        return showDatePicker(
          context: context,
          firstDate: _startDate,
          initialDate: currentValue ?? _startDate,
          lastDate: DateTime(2220),
        );
      },
      format: DateFormat('yyyy-MM-dd'),
    );
  }

  Widget buildEndDatePicker() {
    return DateTimeField(
      decoration: InputDecoration(labelText: 'End date (optional)'),
      initialValue: _endDate,
      onChanged: (value) => setState(() => _endDate = value),
      onShowPicker: (context, currentValue) {
        return showDatePicker(
          context: context,
          firstDate: _startDate,
          initialDate: currentValue ??
              DateTime(_startDate.year + 1, _startDate.month, _startDate.day),
          lastDate: DateTime(2220),
        );
      },
      format: DateFormat('yyyy-MM-dd'),
    );
  }

  Widget buildPeriodicityChoice() {
    return Row(
      children: <Widget>[
        DropdownButton<Periodicity>(
            hint: Text('occurance'),
            value: _periodicity,
            onChanged: (Periodicity newValue) {
              setState(() {
                _periodicity = newValue;
              });
            },
            items: Periodicity.values.map((Periodicity value) {
              return DropdownMenuItem<Periodicity>(
                  value: value, child: Text(value.toString()));
            }).toList()),
      ],
    );
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

  void save() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Firestore.instance.collection('duties').document(_name).setData(
          Duty(_name, _description, _periodicity, _startDate, _endDate)
              .toJson());
      Fluttertoast.showToast(msg: 'Task with name $_name was created');
      Navigator.pop(context);
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }
}
