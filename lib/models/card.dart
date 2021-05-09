import 'dart:convert';

import 'package:flutter/foundation.dart';


class CardInfo with ChangeNotifier {
  final String id;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String cardForm;
  final String cardType;
  final String bankName;
  bool isDefault;

  CardInfo({this.id,
    @required this.cardNumber,
    @required this.expiryMonth,
    @required this.expiryYear,
    @required this.cvv,
    this.cardForm,
    this.cardType,
    this.bankName});

  factory CardInfo.fromJson(Map<String, dynamic> jsonData) {
    return CardInfo(
        id: jsonData['id'],
        cardNumber: jsonData['cardNumber'],
        expiryMonth: jsonData['expiryMonth'],
        expiryYear: jsonData['expiryYear'],
        cvv: jsonData['cvv'],
        cardForm: jsonData['cardForm'],
        cardType: jsonData['cardType'],
        bankName: jsonData['bankName'],
    );
  }

 static Map<String, dynamic> toMap(CardInfo cardInfo) =>
      {

        'cardNumber': cardInfo.cardNumber,
        'expiryMonth': cardInfo.expiryMonth,
        'expiryYear': cardInfo.expiryYear,
        'cvv': cardInfo.cvv,
        'cardForm': cardInfo.cardForm,
        'cardType': cardInfo.cardType,
        'bankName': cardInfo.bankName,
      };
  Map<String, dynamic> tMap() =>
      {

        'cardNumber': cardNumber,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cvv': cvv,
        'cardForm': cardForm,
        'cardType': cardType,
        'bankName': bankName,
      };

  static List<Map> convertCardToMap({List<CardInfo> cardInfos}){
    List<Map> cards = [];
    cardInfos.forEach((CardInfo cardInfo) {
      Map card = cardInfo.tMap();
      cards.add(card);
    });
    return cards;
  }

  static String encodeCards(List<CardInfo> cardInfo) =>
      json.encode(
        cardInfo
            .map<Map<String, dynamic>>((card) => CardInfo.toMap(card))
            .toList(),
      );

  static String encodeCard(CardInfo cardInfo) =>
      json.encode({'id': cardInfo.id,
        'cardNumber': cardInfo.cardNumber,
        'expiryMonth': cardInfo.expiryMonth,
        'expiryYear': cardInfo.expiryYear,
        'cvv': cardInfo.cvv,
        'cardForm': cardInfo.cardForm,
        'cardType': cardInfo.cardType,
        'bankName': cardInfo.bankName,
        'isDefault': cardInfo.isDefault});

  static List<CardInfo> decodeCards(String cards) =>
      (json.decode(cards) as List<dynamic>)
          .map<CardInfo>((item) =>CardInfo.fromJson(item))
          .toList();
}



