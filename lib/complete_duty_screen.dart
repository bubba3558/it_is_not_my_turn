import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:it_is_not_my_turn/model/const.dart';
import 'package:it_is_not_my_turn/model/duty.dart';
import 'package:it_is_not_my_turn/model/dutyHistory.dart';
import 'package:it_is_not_my_turn/model/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CompleteDutyScreen extends StatefulWidget {
  CompleteDutyScreen({Key key, @required this.duty, @required this.currentUser})
      : super(key: key);

  final Duty duty;
  final User currentUser;

  @override
  CompleteDutyState createState() => CompleteDutyState();
}

class CompleteDutyState extends State<CompleteDutyScreen> {
  var imagePath;
  FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'You are about to complete task ',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10.0),
            Text(widget.duty.name, style: TextStyle(fontSize: 25)),
            SizedBox(height: 10.0),
            AutoSizeText(
              widget.duty.description != null ? widget.duty.description : '',
              style: TextStyle(fontSize: 20),
              maxLines: 2,
            ),
            SizedBox(height: 10.0),
            imagePath != null
                ? Expanded(
                    child: InkWell(
                        child: Image.file(File(imagePath)),
                        onTap: () => _onAddPhotoClick(context)))
                : Center(
                    child: RaisedButton.icon(
                    onPressed: () {
                      _onAddPhotoClick(context);
                    },
                    label: Text('Add photo of your job!',
                        style: TextStyle(color: buttonLabelColor)),
                    icon: Icon(Icons.camera_alt, color: buttonLabelColor),
                    color: buttonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ))
          ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onDoneClick(context),
        child: Icon(Icons.done),
        backgroundColor: buttonColor,
      ),
    );
  }

  _onAddPhotoClick(BuildContext context) async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    final returnedPath = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(
          builder: (context) => TakePictureScreen(camera: firstCamera)),
    );
    imagePath = returnedPath == null ? imagePath : returnedPath;
  }

  DateTime _getLastMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  int calculateDiffInDay(DateTime datetime) {
    final lastMidnight = _getLastMidnight();
    return datetime.difference(lastMidnight).inDays;
  }

  onDoneClick(BuildContext context) async {
    var daysToDeadline = calculateDiffInDay(widget.duty.nextDeadline);
    if (daysToDeadline < 2) {
      return completeTask(context);
    }
    await _showAlertDialog(context, daysToDeadline);
    Navigator.pop(context);
  }

  completeTask(BuildContext context) async {
    widget.duty.lastUserName = widget.currentUser.name;
    var diffInDays = calculateDiffInDay(widget.duty.nextDeadline);
    widget.duty.nextDeadline = calculateDeadline(widget.duty);
    String url = await uploadImage();
    //todo replace with server function
    Firestore.instance
        .collection('userGroups')
        .document(widget.duty.groupId)
        .collection('duties')
        .document(widget.duty.name)
        .setData(widget.duty.toJson());
    var historyRef = Firestore.instance
        .collection('completionHistory')
        .document(widget.duty.name);
    historyRef.collection('dutyHistory').add(
        DutyHistory(widget.currentUser.name, DateTime.now(), diffInDays, url)
            .toJson());
    historyRef
        .collection('userStatistics')
        .document(widget.currentUser.name)
        .setData({'count': FieldValue.increment(1)}, merge: true);
    Navigator.pop(context);
    Fluttertoast.showToast(msg: 'Task marked as complated');
  }

  Future<String> uploadImage() async {
    if (imagePath == null) {
      return null;
    }
    File image = File(imagePath);
    StorageReference ref =
        _storage.ref().child("images/${Random().nextInt(999999)}");
    var uploadTask = ref.putFile(image);
    return await (await uploadTask.onComplete).ref.getDownloadURL();
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

  Future<void> _showAlertDialog(
      BuildContext context, int daysToDeadline) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You can rest'),
          content: Text('You have $daysToDeadline more days to do it.'),
          actions: <Widget>[
            FlatButton(
                onPressed: () => completeTask(context),
                child: Text('I want to do it anyway')),
            FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Ok, let's rest")),
          ],
        );
      },
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );
            await _controller.takePicture(path);
            Navigator.pop(context, path);
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
