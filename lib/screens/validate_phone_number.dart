import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/config/save_image.dart';
import 'package:mi_pay/providers/auth.dart';
import 'package:mi_pay/providers/login_check.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ValidateNumber extends StatefulWidget {
  static const routeName = '/validate-number';

  PageController controller;

  ValidateNumber(this.controller);

  @override
  _ValidateNumberState createState() => _ValidateNumberState();
}

class _ValidateNumberState extends State<ValidateNumber> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  String phoneNumber = '';
  String smsCode;
  String verificationCode;
  String phoneIsoCode = 'CHN';
  bool visible = false;
  String confirmedNumber = '';
  var isLoading = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  @override
  void dispose() {
    // TODO: implement dispose
    widget.controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    registerNotification();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          ImageSharedPrefs.emptyPrefs();
                          if (widget.controller.hasClients) {
                            widget.controller.jumpToPage(0);
                          }
                          if (Provider.of<LoginCheck>(context, listen: false)
                                  .isRegister ==
                              true) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(auth.currentUser.uid)
                                .delete()
                                .then((value) async {
                              await auth.currentUser.delete();
                            });
                            Provider.of<LoginCheck>(context, listen: false)
                                .setIsRegister(false);
                          } else {
                            auth.signOut();
                          }
                        }),
                    Center(
                      child: Container(
                        child: Text(
                          'Validate Your Number',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(child: Container())
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            child: Theme(
                              data: new ThemeData(
                                  cursorColor: Colors.black,
                                  primaryColor: Colors.black,
                                  primaryColorDark: Colors.black),
                              child: TextFormField(
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.dialpad_outlined),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                                onSaved: (value){
                                  phoneNumber = '+86${value.trim()}';
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FlatButton(
                                child: Text(
                                  'Update my phone number',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  if (phoneNumber == '' ||
                                      phoneNumber == null) {
                                    Helpers.showMessage(
                                        'Please fill in a valid phone number',
                                        _scaffoldKey);
                                  } else {
                                    updateMyPhoneNumber(phoneNumber, context);
                                  }
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ],
                          ),
                          isLoading == true
                              ? Column(
                                  children: [
                                    CircularProgressIndicator(strokeWidth: 2),
                                    Text('Please wait a moment...')
                                  ],
                                )
                              : Container(
                                  width: 200,
                                  height: 50,
                                  child: FlatButton(
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    color: Colors.black,
                                    onPressed: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      _formKey.currentState.save();
                                      if (phoneNumber == '' ||
                                          phoneNumber == null) {
                                        Helpers.showMessage(
                                            'Please fill in a valid phone number',
                                            _scaffoldKey);
                                      } else {
                                        signIn(phoneNumber, context);
                                      }
                                      FocusScope.of(context).unfocus();
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  signIn(String phone, contex, [String verificationCode]) async {
    await auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int resendToken) async {
          print(phone);
          final _codeController = TextEditingController();
          showDialog(
              context: contex,
              barrierDismissible: false,
              builder: (contex) {
                return Container(
                  height: 100,
                  width: MediaQuery.of(contex).size.width,
                  child: AlertDialog(
                      elevation: 0,
                      title: Text("Enter SMS Code"),
                      content: Builder(builder: (contex) {
                        var width = MediaQuery.of(contex).size.width;
                        return Container(
                          width: width,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Theme(
                                data: new ThemeData(
                                    primaryColor: Colors.black,
                                    primaryColorDark: Colors.black),
                                child: Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: _codeController,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.remove),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        labelText: 'Verification code'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      actions: <Widget>[
                        Consumer<LoginCheck>(
                          builder: (ctx, check, _) => FlatButton(
                              child: Text("Done"),
                              textColor: Colors.white,
                              color: Colors.black,
                              onPressed: () async {
                                FocusScope.of(contex).unfocus();
                                final prefs =
                                    await SharedPreferences.getInstance();
                                verificationCode = _codeController.text.trim();
                                var _credential = PhoneAuthProvider.credential(
                                    verificationId: verificationId,
                                    smsCode: verificationCode);
                                Provider.of<LoginCheck>(contex, listen: false)
                                            .isLogin ==
                                        true
                                    ? auth
                                        .signInWithCredential(_credential)
                                        .then((value) async {
                                        Navigator.of(contex).pop();
                                        Provider.of<Auth>(contex, listen: false)
                                            .setIsVerified(true);
                                        prefs.setBool(
                                            'userVerify',
                                            Provider.of<Auth>(contex,
                                                    listen: false)
                                                .isVerify);
                                        check.checkedLoginTimeOut(true);
                                      }).catchError((e) {
                                        Navigator.of(contex).pop();
                                        Helpers.showMessage(
                                            e
                                                        .toString()
                                                        .toLowerCase()
                                                        .contains('invalid') ==
                                                    true
                                                ? 'The verification code is invalid please try again'
                                                : 'Something went wrong please try again',
                                            _scaffoldKey);
                                      })
                                    : auth.currentUser
                                        .updatePhoneNumber(_credential)
                                        .then((value) {
                                        Navigator.of(contex).pop();
                                        Provider.of<Auth>(contex, listen: false)
                                            .setIsVerified(true);
                                        prefs.setBool(
                                            'userVerify',
                                            Provider.of<Auth>(contex,
                                                    listen: false)
                                                .isVerify);
                                        FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(auth.currentUser.uid)
                                            .update(
                                          {'phoneNumber': phoneNumber},
                                        );
                                      }).catchError((e) {
                                        Navigator.of(contex).pop();
                                        Helpers.showMessage(
                                            e
                                                        .toString()
                                                        .toLowerCase()
                                                        .contains('invalid') ==
                                                    true
                                                ? 'The verification code is invalid please try again'
                                                : 'Something went wrong please try again',
                                            _scaffoldKey);
                                      });
                              }),
                        ),
                      ]),
                );
              });
        },
        timeout: const Duration(seconds: 1),
        codeAutoRetrievalTimeout: (String verficationId) {
//          print(verficationId);
//          print('Time out');
        }).catchError((onError){
          print(onError);
    });
  }

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
      phoneNumber = internationalizedPhoneNumber;
      phoneIsoCode = isoCode;
    });
  }

  /// this could be a potential issue
  Future<void> updateMyPhoneNumber(
      String phoneNumber, BuildContext contex) async {
    auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int resendToken) async {
          final _codeController = TextEditingController();
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (contex) {
                return Container(
                  height: 100,
                  width: MediaQuery.of(contex).size.width,
                  child: AlertDialog(
                      elevation: 0,
                      title: Text("Enter SMS Code"),
                      content: Builder(builder: (context) {
                        var width = MediaQuery.of(context).size.width;
                        return Container(
                          width: width,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Theme(
                                data: new ThemeData(
                                    primaryColor: Colors.black,
                                    primaryColorDark: Colors.black),
                                child: Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: _codeController,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.remove),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        labelText: 'Verification code'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      actions: <Widget>[
                        Consumer<LoginCheck>(
                          builder: (ctx, check, _) => FlatButton(
                              child: Text("Done"),
                              textColor: Colors.white,
                              color: Colors.black,
                              onPressed: () async {
                                FocusScope.of(contex).unfocus();
                                final prefs =
                                    await SharedPreferences.getInstance();
                                verificationCode = _codeController.text.trim();
                                var _credential = PhoneAuthProvider.credential(
                                    verificationId: verificationId,
                                    smsCode: verificationCode);
                                auth.currentUser
                                    .updatePhoneNumber(_credential)
                                    .then((value) async {
                                  Navigator.of(contex).pop();
                                  Provider.of<Auth>(context, listen: false)
                                      .setIsVerified(true);
                                  prefs.setBool(
                                      'userVerify',
                                      Provider.of<Auth>(context, listen: false)
                                          .isVerify);
                                  check.checkedLoginTimeOut(true);
                                  FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(auth.currentUser.uid)
                                      .update(
                                    {'phoneNumber': phoneNumber},
                                  );
                                }).catchError((e) {
                                  Navigator.of(contex).pop();
                                  Helpers.showMessage(
                                      e
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains('invalid') ==
                                              true
                                          ? 'The verification code is invalid please try again'
                                          : 'Something went wrong please try again',
                                      _scaffoldKey);
                                });
                              }),
                        )
                      ]),
                );
              });
        },
        timeout: const Duration(seconds: 30),
        codeAutoRetrievalTimeout: (String verficationId) {
//          print(verficationId);
//          print('Time out');
        });
  }

  void registerNotification() {
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();

    fbm.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
//      Platform.isAndroid
//          ? showNotification(message['notification'])
//          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
//      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
//      print('onLaunch: $message');
      return;
    });

    fbm.getToken().then((token) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser.uid)
          .update({'pushToken': token});
    }).catchError((err) {
//      Fluttertoast.showToast(msg: err.message.toString());
    });
  }
}
