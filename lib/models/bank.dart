import 'package:flutter/material.dart';

class Bank {
  String name;
  String code;

  Bank({@required this.name, @required this.code});
}

class BankAndBalance {
  final List<Bank> bank;
  final balance;

  BankAndBalance({@required this.bank, @required this.balance});
}
