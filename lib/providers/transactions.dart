import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/models/transaction_model.dart';


class Transactions with ChangeNotifier {

  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transaction {
    return [..._transactions];
  }

  Future<void> fetchTransactions() async {
    var extractedData;
    try {
      http.Response response = await http.get(
          'https://api.paystack.co/transaction?perPage=1000000000000000&',
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer ${Helpers.paystackSecretKey}'
          });
      extractedData = await json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return null;
      }
      final List<TransactionModel> loadedTransactions = [];
      for (int i = 0; i < extractedData['data'].length; i++) {
        loadedTransactions.add(TransactionModel(
            email: extractedData['data'][i]['customer']['email'],
            amount: extractedData['data'][i]['amount'],
            time: extractedData['data'][i]['created_at'],
            cardNumberUsed: extractedData['data'][i]['authorization']['last4'],
            cardType: extractedData['data'][i]['authorization']['card_type']));
      }
      _transactions = loadedTransactions;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
    return _transactions;
  }
}
