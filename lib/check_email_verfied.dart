import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'config/save_image.dart';

// ignore: must_be_immutable
class CheckEmailIsVerified extends StatefulWidget {
  PageController controller;

  CheckEmailIsVerified(this.controller);

  @override
  _CheckEmailIsVerifiedState createState() => _CheckEmailIsVerifiedState();
}

class _CheckEmailIsVerifiedState extends State<CheckEmailIsVerified> {

  Timer _timer;
  UserCredential authResult;

  @override
  void initState() {
    Future(() async {
      const oneSec = const Duration(seconds: 30);
      _timer = new Timer.periodic(oneSec, (timer) async {
        await FirebaseAuth.instance.currentUser
          .reload();
        var authResult = FirebaseAuth.instance.currentUser;
        if (authResult.emailVerified) {
          if (widget.controller.hasClients) {
            widget.controller.animateToPage(2,
                duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
          }
          if (_timer != null) {
            _timer.cancel();
          }
        } else {
          ImageSharedPrefs.emptyPrefs();
          if (widget.controller.hasClients) {
            widget.controller.animateToPage(0,
                duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
          }
          await FirebaseFirestore.instance
              .collection('users')
              .doc(authResult.uid)
              .delete()
              .then((value) async {
            await authResult.delete();
          });
          if (_timer != null) {
            _timer.cancel();
          }
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('Check your mail box or spam'),
          ),
          SizedBox(height: 32),
          Center(
              child: Text('This page automatically closes after 30 secs...'),
          ),
        ],
      ),
    );
  }



}
