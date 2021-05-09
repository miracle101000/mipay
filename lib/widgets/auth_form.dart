import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/config/save_image.dart';
import 'package:mi_pay/config/user_image_picker.dart';
import 'package:mi_pay/providers/login_check.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;
  final void Function(
    String email,
    String password,
    String userName,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var auth = FirebaseAuth.instance;
  var _isLogin = true;
  var _userEmail = '';
  File image;
  var _userName = '';
  var _userPassword = '';
  var _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  _trySubmit() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('userVerify', false);
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null && _isLogin == false) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick an image'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), _userName.trim(),
          _userImageFile, _isLogin, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: Card(
          elevation: 0,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    if (_isLogin == false) UserImagePicker(_pickedImage),
                    if (_isLogin == false)
                      Theme(
                        data: new ThemeData(
                            primaryColor: Colors.black,
                            primaryColorDark: Colors.black),
                        child: TextFormField(
                          key: ValueKey('username'),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                              suffixIcon: Icon(Icons.accessibility_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              labelText: 'Username'),
                          validator: (value) {
                            if (value.length < 4 || value.isEmpty) {
                              return "Username is too short.";
                            } else if (value.length > 12) {
                              return "Username is too long.";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            _userName = value.trim();
                          },
                        ),
                      ),
                    if (_isLogin == false)
                      SizedBox(
                        height: 20,
                      ),
                    Theme(
                      data: new ThemeData(
                          primaryColor: Colors.black,
                          primaryColorDark: Colors.black),
                      child: TextFormField(
                        key: ValueKey('email'),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            suffixIcon: Icon(Icons.mail_outline),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            labelText: 'E-Mail'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid  email address!';
                          }
                          return null;
                        },
                        onChanged: (input) {
                          _userEmail = input.trim();
                        },
                        onSaved: (value) {
                          _userEmail = value.trim();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Theme(
                      data: new ThemeData(
                          primaryColor: Colors.black,
                          primaryColorDark: Colors.black),
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
                    SizedBox(
                      height: 20,
                    ),
                    if (_isLogin == false)
                      Theme(
                        data: new ThemeData(
                            primaryColor: Colors.black,
                            primaryColorDark: Colors.black),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          enabled: _isLogin == false,
                          decoration: InputDecoration(
                              suffixIcon: Icon(Icons.remove),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              labelText: 'Confirm Password'),
                          obscureText: true,
                          validator: _isLogin == false
                              ? (value) {
                                  if (_userPassword != value.trim()) {
                                    return 'Passwords do not match!';
                                  }
                                  return null;
                                }
                              : null,
                        ),
                      ),
                    if (_isLogin == false)
                      SizedBox(
                        height: 20,
                      ),
                    if (widget.isLoading == true)
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    if (widget.isLoading == false)
                      FlatButton(
                        child: Container(
                            height: 50,
                            width: 250,
                            child: Center(
                                child: Text(
                                    _isLogin == true ? 'LOGIN' : 'SIGN UP'))),
                        onPressed: () {
                          Provider.of<LoginCheck>(context, listen: false)
                              .checkedLoginTimeOut(false);
                          _trySubmit();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
//                  padding:
//                  EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                        color: Colors.black,
                        textColor: Colors.white,
                      ),
                    if (widget.isLoading == false)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FlatButton(
                              child: Text(
                                '${_isLogin == true ? 'SignUp' : 'Login'}',
                                style: TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                ImageSharedPrefs.emptyPrefs();
                                print(MediaQuery.of(context).size.width);
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              textColor: Colors.black,
                            ),
                            if (_isLogin == true)
                              FlatButton(
                                child: Text(
                                  'Forgot Password',
                                  style: TextStyle(fontSize: 11),
                                ),
                                onPressed: () {
                                  resetPassword(_userEmail);
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                textColor: Colors.black,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      Helpers.showMessage(
          'Please fill in the email part of the login form!', _scaffoldKey);
    }
    try {
      await auth.sendPasswordResetEmail(email: email).then((value) {
        Helpers.showMessage(
            'Please check your inbox or your junk mail box', _scaffoldKey);
      });
    } catch (error) {
      if (error.toString().contains('network-request-failed') ||
          error.toString().contains('unreachable host')) {
        Helpers.showMessage('No internet connection', _scaffoldKey);
      }
    }
  }
}
