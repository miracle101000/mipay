import 'package:flutter/material.dart';

class LoginCheck with ChangeNotifier {
  bool isLogin = false;
  bool isRegister = false;
  bool twoAuthComplete = false;
  bool checked = true;

  void setIsLogin(bool login) {
    isLogin = login;
    notifyListeners();
  }


  void setIsRegister(bool register) {
    isRegister = register;
    notifyListeners();
  }

  bool getIsRegister() {
    return isRegister;
  }

  bool getIsTwoAuthCompleted() {
    return twoAuthComplete;
  }

  bool setIsTwoAuthCompleted(bool twoAuthComplete) {
    return twoAuthComplete;
  }

  void checkedLoginTimeOut(bool isChecked){
    print('Hello');
    checked = isChecked;
    notifyListeners();
  }
}
