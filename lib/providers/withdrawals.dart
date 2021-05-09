import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/models/withdrawal_model.dart';


class Withdrawals with ChangeNotifier {


  List<WithdrawalModel> _withdrawals = [];

  List<WithdrawalModel> get withdrawal {
    return [..._withdrawals];
  }

  Future<void> fetchWithdrawals() async {
    var extractedData;
    final List<WithdrawalModel> loadWithdrawals = [];
    try {
      http.Response response = await http.get(
          'https://api.paystack.co/transfer',
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer ${Helpers.paystackSecretKey}'
          });
      extractedData = await json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return null;
      }
      final List<WithdrawalModel> loadedTransactions = [];
      for (int i = 0; i < extractedData['data'].length; i++) {
        loadWithdrawals.add(WithdrawalModel(
            amount: extractedData['data'][i]['amount'],
            name: extractedData['data'][i]['recipient']['details']['account_number'],
            time: extractedData['data'][i]['recipient']['created_at'],
            bankName: extractedData['data'][i]['recipient']['bank_name']));
      }
      _withdrawals = loadedTransactions;
      print(_withdrawals);
      notifyListeners();
    } catch (error) {
      throw (error);
    }
    return _withdrawals;
  }
}
