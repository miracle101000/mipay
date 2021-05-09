import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/models/card.dart';


class Cards with ChangeNotifier {
  String bankName;
  String cardForm;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<CardInfo> _cards = [];

  List<CardInfo> get cards {
    return [..._cards];
  }

  Future<void> addCard(PaymentCard card, String cardNumber) async {
    try {
      http.Response respons = await http.get(
          'https://api.paystack.co/decision/bin/${cardNumber.substring(0, 5)}',
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${Helpers.paystackSecretKey}'
          });
      cardForm = jsonDecode(respons.body)['data']['card_type'];
      bankName = jsonDecode(respons.body)['data']['bank'];

      final List<CardInfo> loadedCards = [];
      final List isLoadingCards = [];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser.uid)
          .get()
          .then((val) async {
        if (val['cards'].isNotEmpty) {
          for (int i = 0; i < val['cards'].length; i++) {
            isLoadingCards.add(val['cards'][i]);
          }
          isLoadingCards.add({
            'cardNumber': cardNumber,
            'expiryMonth': card.expiryMonth,
            'expiryYear': card.expiryYear,
            'cvv': card.cvc,
            'cardForm': cardForm,
            'cardType': card.type,
            'bankName': bankName,
          });
          await FirebaseFirestore.instance
              .collection("users")
              .doc(auth.currentUser.uid)
              .update({'cards': isLoadingCards});
        } else {
          loadedCards.add(CardInfo(
              cardNumber: cardNumber,
              expiryMonth: card.expiryMonth.toString(),
              expiryYear: card.expiryYear.toString(),
              cvv: card.cvc,
              bankName: bankName,
              cardType: card.type,
              cardForm: cardForm));
          await FirebaseFirestore.instance
              .collection("users")
              .doc(auth.currentUser.uid)
              .update(
                  {'cards': CardInfo.convertCardToMap(cardInfos: loadedCards)});
        }
      });
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

}
