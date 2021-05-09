import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/config/save_image.dart';
import 'package:mi_pay/providers/auth.dart';
import 'package:mi_pay/providers/login_check.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


// ignore: must_be_immutable
class TimeOutLoginScreen extends StatefulWidget {

  @override
  _TimeOutLoginScreenState createState() => _TimeOutLoginScreenState();
}

class _TimeOutLoginScreenState extends State<TimeOutLoginScreen> {
  String imageString;
  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _userPassword = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          height: height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.2,
                ),
                Text('Oops! Time Out',style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder(
                        future: loadImageFromPrefs(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.black,
                                backgroundImage: AssetImage('assets/images/placeholder.png'),
                              ),
                            );
                          }
                          if (snapshot.data == null) {
                            loadImageFromPrefs();
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.black,
                                backgroundImage: AssetImage('assets/images/placeholder.png'),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.black,
                              backgroundImage: FileImage(File(snapshot.data)),
                            ),
                          );
                        }),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(_auth.currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text('Loading...'),
                            ),
                          ],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, top: 8, right: 8, bottom: 8),
                            child: Text(
                              '${snapshot.data['username']}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    }),
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Theme(
                        data: new ThemeData(
                            primaryColor: Colors.black,
                            primaryColorDark: Colors.black),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            key: ValueKey('password'),
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                                suffixIcon: Icon(Icons.remove),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              print(value);
                              if (value.isEmpty || value.length < 5) {
                                return 'Password is too short!';
                              }
                              return null;
                            },
                            onChanged: (input) {
                              _userPassword = input.trim();
                            },
                            onSaved: (value) {
                              _userPassword = value.trim();
                            },
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Not my Account',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            Provider.of<Auth>(context, listen: false).setIsVerified(false);
                            prefs.setBool('userVerify',
                                Provider
                                    .of<Auth>(context, listen: false)
                                    .isVerify);
                            FirebaseAuth.instance.signOut();
                            await  Future<void>.delayed(
                              Duration(seconds: 3),
                                  () async {
                                ImageSharedPrefs.emptyPrefs();
                                prefs.remove('userName');
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    isLoading == true
                        ? Column(
                            children: [
                              CircularProgressIndicator(strokeWidth: 2),
                              Text('Please wait a moment...')
                            ],
                          )
                        : FlatButton(
                            child: Container(
                                height: 50,
                                width: 100,
                                child: Center(child: Text('LOGIN'))),
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                isLoading = true;
                              });
                              _formKey.currentState.validate();
                              _formKey.currentState.save();
                              try {
                                await _auth
                                    .signInWithEmailAndPassword(
                                  email: _auth.currentUser.email,
                                  password: _userPassword,
                                )
                                    .then((value) async {
                                  await signIn(
                                      _auth.currentUser.phoneNumber, context);
                                });
                              } catch (error) {
                                setState(() {
                                  isLoading = false;
                                });
                                Helpers.showMessage('Something went wrong please try again',_scaffoldKey);
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            color: Colors.black,
                            textColor: Colors.white,
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  loadImageFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final imageKeyValue = prefs.getString(IMAGE_KEY);
    if (imageKeyValue != null) {
      imageString = await ImageSharedPrefs.loadImageFromPrefs();
    }
    return imageString = await ImageSharedPrefs.loadImageFromPrefs();
  }

  signIn(String phoneNumber, contex, [String verificationCode]) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: _auth.currentUser.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
//            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int resendToken) async {
          final _codeController = TextEditingController();
          showDialog(
              context: contex,
              barrierDismissible: false,
              builder: (contex) {
                return Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
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
                                                      BorderRadius.circular(
                                                          20)),
                                              labelText: 'Verification code'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                      }),
                      actions: <Widget>[
                   FlatButton(
                              child: Text("Done"),
                              textColor: Colors.white,
                              color: Colors.black,
                              onPressed: () async {
                                FocusScope.of(contex).unfocus();
                                verificationCode = _codeController.text.trim();
                                var _credential = PhoneAuthProvider.credential(
                                    verificationId: verificationId,
                                    smsCode: verificationCode);
                                Navigator.of(contex).pop();
                                _auth
                                    .signInWithCredential(_credential)
                                    .then((value) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Provider.of<LoginCheck>(context,listen: false).checkedLoginTimeOut(true);
                                }).catchError((e) {
                                  print(e.toString());
                                  Navigator.of(contex).pop();
                                  Helpers.showMessage(e
                                      .toString()
                                      .toLowerCase()
                                      .contains('invalid') ==
                                      true
                                      ? 'The verification code is invalid please try again'
                                      : 'Something went wrong please try again',_scaffoldKey);
                                });
                              }),
                      ]),
                );
              });
        },
        timeout: const Duration(minutes: 1),
        codeAutoRetrievalTimeout: (String verficationId) {
//          print(verficationId);
//          print('Time out');
        });
  }
}
