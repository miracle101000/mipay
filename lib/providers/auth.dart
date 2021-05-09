import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Auth with ChangeNotifier {
  bool isVerify = false;

  PageController _pageController ;

  Future<void> some (int pageNumber) async {
     return await _pageController.animateToPage(pageNumber, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void setIsVerified(bool isVerified) {
    isVerify = isVerified;
    notifyListeners();
  }

  bool getIsVerified(){
    return isVerify;
  }
}
