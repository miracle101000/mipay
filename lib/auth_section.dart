import 'package:flutter/material.dart';
import 'package:mi_pay/screens/auth_screen.dart';
import 'package:mi_pay/screens/validate_phone_number.dart';



import 'check_email_verfied.dart';

// ignore: must_be_immutable
class AuthSection extends StatefulWidget {

  AsyncSnapshot snapshot;
  AsyncSnapshot<bool> snap;

  AuthSection(this.snapshot, this.snap);

  @override
  _AuthSectionState createState() => _AuthSectionState();
}

class _AuthSectionState extends State<AuthSection> {

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(
      initialPage: 0,
    );
    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          AuthScreen(pageController),
          CheckEmailIsVerified(pageController),
          ValidateNumber(pageController),
        ],
      ),
    );
  }
}
