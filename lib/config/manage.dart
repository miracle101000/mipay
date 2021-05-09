import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mi_pay/providers/login_check.dart';
import 'package:mi_pay/screens/pay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Manage extends StatefulWidget {
  static const routeName = '/manage';

  @override
  _ManageState createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  var selectedCard;

Timer _timer;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    Future(() async {
      final prefs =
      await SharedPreferences.getInstance();
      await  FirebaseFirestore.instance.collection('users').doc(auth.currentUser.uid).get().then((value) {
        prefs.setString('userName', value['username']);
      });
      _timer = new Timer.periodic(Duration(minutes: 25), (timer) {
        Provider.of<LoginCheck>(context,listen: false).checkedLoginTimeOut(false);
      });
    });
    super.initState();
  }
@override
  void dispose() {
    // TODO: implement dispose
  _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Pay();
  }

}
