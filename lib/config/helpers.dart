import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mi_pay/screens/add_bank_card.dart';
import 'package:mi_pay/screens/transaction_screen.dart';


class Helpers {
  static const paystackSecretKey =
      'sk_live_1aa3c80fc02cde053ddfcfa4427024d83cfe6304';
  static const paystackPublicKey =
      'pk_live_f74444b52a57e9dc6f71d9b6f686bc6d2dc80dbb';
  static const backendUrl = 'https://mi-pay.herokuapp.com';

  static showMessage(String message, GlobalKey<ScaffoldState> _scaffoldKey,
      [Duration duration = const Duration(seconds: 4)]) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      backgroundColor: Colors.black,
      content: new Text(message),
      duration: duration,
      action: new SnackBarAction(
          label: 'CLOSE',
          textColor: Colors.white,
          onPressed: () => _scaffoldKey.currentState.removeCurrentSnackBar()),
    ));
  }

  static Route createRouteTransaction(int index) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          TransactionScreen(index),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route createRouteAddBankCard() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AddBankCard(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static double dp(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }
}
