import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mi_pay/models/transactionInfo.dart';


class BalanceTransactions with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> addTransaction(TransactionForBalance transaction, String userUid,
      String receiverUid) async {
//    print(uid);
    try {
      final List<TransactionForBalance> loadedTransactions = [];
      final List isLoadingTransactions = [];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .get()
          .then((val) async {
        if (val['transactions'].isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(receiverUid)
              .get()
              .then((val) async {
            for (int i = 0; i < val['transactions'].length; i++) {
              isLoadingTransactions.add(val['transactions'][i]);
            }
            isLoadingTransactions.add({
              'username': val['username'],
              'amountSent': transaction.amountSent,
              'dateCreated': transaction.dateCreated,
              'entity': transaction.entity,
            });
            await FirebaseFirestore.instance
                .collection("users")
                .doc(userUid)
                .update({'transactions': isLoadingTransactions});
          });
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(receiverUid)
              .get()
              .then((val) async {
            loadedTransactions.add(TransactionForBalance(
                userName: val['username'],
                amountSent: transaction.amountSent,
                dateCreated: transaction.dateCreated,
                entity: transaction.entity));

            await FirebaseFirestore.instance
                .collection("users")
                .doc(userUid)
                .update({
              'transactions': TransactionForBalance.convertTransactionToMap(
                  transactions: loadedTransactions)
            });
          });
        }
      });
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
