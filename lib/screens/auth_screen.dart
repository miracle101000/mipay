import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/providers/login_check.dart';
import 'package:mi_pay/widgets/auth_form.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  PageController controller;

  AuthScreen(this.controller);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  Future<void> _submitAuthForm(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;
    final prefs = await SharedPreferences.getInstance();
    try {
      setState(() {
        _isLoading = true;
      });
      var usernameExists = await usernameCheck(username);

      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        // ignore: missing_return
        );
        if (widget.controller.hasClients) {
          widget.controller.jumpToPage(2);
        }
        Provider.of<LoginCheck>(ctx, listen: false).setIsLogin(true);
        await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser.uid).get().then((val) {
          if (val !=  null) {
            prefs.setString('previousDate', val['previousDate']);
          }
        });
      } else {
        if (usernameExists == true) {
          authResult = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
            // ignore: missing_return
          );
          await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          await authResult.user.sendEmailVerification();
          if (widget.controller.hasClients) {
            widget.controller.jumpToPage(1);
          }
          Provider.of<LoginCheck>(ctx, listen: false).setIsRegister(true);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(authResult.user.uid)
              .set({
            'id':authResult.user.uid,
            'username': username,
            'email': email,
            'balance': '0.00',
            'previousDate': '',
            'measureAmount': '0.00',
            'selectedCard': {},
            'cards': {},
            'transactions': {},
            'image_url': '',
            'pushToken':'',
            'sentTo': '',
          }).then((value) async {
            final ref = FirebaseStorage.instance
                .ref()
                .child('user_image')
                .child(authResult.user.uid + '.jpg');
            await ref.putFile(image).then((val) async {
              final url = await ref.getDownloadURL();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(authResult.user.uid)
                  .update({
                'image_url': url,
              });
            });
          });
        } else {
          Helpers.showMessage('User Name already exists',_scaffoldKey);
          setState(() {
            _isLoading = false;
          });
        }
      }

    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials!';

      if (err.message != null) {
        message = err.message;
        Helpers.showMessage(message,_scaffoldKey);
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text('message'),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      if (err.toString().contains('no user record')) {
        Helpers.showMessage('User does not exist',_scaffoldKey);
      } else if (err.toString().contains('network-request-failed') ||
          err.toString().contains('unreachable host')) {
        Helpers.showMessage('No internet connection',_scaffoldKey);
      }else if (err.toString().contains('The password is invalid')){
        Helpers.showMessage('Password is invalid',_scaffoldKey);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: deviceSize.height,
                width: deviceSize.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: deviceSize.height * 0.13,
                    ),
                    Center(
                      child: Text(
                        'MiPay',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Flexible(
                      flex: deviceSize.width > 700 ? 2 : 1,
                      child: AuthForm(_submitAuthForm, _isLoading),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> usernameCheck(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }

}
