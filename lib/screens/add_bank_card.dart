
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter/material.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/providers/cards.dart';
import 'package:provider/provider.dart';



class AddBankCard extends StatefulWidget {
  static const routeName = ' /add-bank-card';

  @override
  _AddBankCardState createState() => _AddBankCardState();
}

class _AddBankCardState extends State<AddBankCard> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var auth = FirebaseAuth.instance;
  String _cardNumber = '';
  String _cvv = '';
  bool _inProgress = false;
  int _expiryMonth = 0;
  int _expiryYear = 0;

  @override
  void initState() {
    PaystackPlugin.initialize(publicKey: Helpers.paystackPublicKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.05, left: 10),
                      child: Center(
                          child: Text(
                            'Add Bank Card',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: width*0.078,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.05, left: 10),
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
//                                height: height,
                              child: Container(
                                margin: EdgeInsets.only(top: height * 0.15),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        new Theme(
                                          data: new ThemeData(
                                              primaryColor: Colors.black,
                                              primaryColorDark: Colors.black),
                                          child: TextFormField(
                                              keyboardType: TextInputType.number,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                suffixIcon:
                                                    Icon(Icons.payment),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                labelText: 'Card Number',
                                              ),
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Please provide a valid card number';
                                                }
                                                return null;
                                              },
                                              onSaved: (String value) {
                                                _cardNumber = value.trim();
                                              }),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 28.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Container(
                                                  width: width* 0.37,
                                                  child: new Theme(
                                                    data: new ThemeData(
                                                        primaryColor:
                                                            Colors.black,
                                                        primaryColorDark:
                                                            Colors.black),
                                                    child: TextFormField(
                                                      keyboardType: TextInputType.number,
                                                      cursorColor:
                                                          Colors.black,
                                                      decoration:
                                                          InputDecoration(
//                                                              suffixIcon: Icon(Icons.calendar_today),
                                                        border: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        labelText:
                                                            'MM',
                                                      ),
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return 'Invalid Month';
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (String
                                                              value) =>
                                                          _expiryMonth = int
                                                              .tryParse(value
                                                                  .trim()),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                color: Colors.black,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Container(
                                                  width: width* 0.325,
                                                  child: new Theme(
                                                    data: new ThemeData(
                                                        primaryColor:
                                                            Colors.black,
                                                        primaryColorDark:
                                                            Colors.black),
                                                    child: TextFormField(
                                                      keyboardType: TextInputType.number,
                                                      cursorColor:
                                                          Colors.black,
                                                      decoration:
                                                          InputDecoration(
//                                                              suffixIcon: Icon(Icons.calendar_today),
                                                        fillColor:
                                                            Colors.black,
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        labelText:
                                                            'YY',
                                                      ),
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return 'Invalid Year';
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (String
                                                              value) =>
                                                          _expiryYear = int
                                                              .tryParse(value
                                                                  .trim()),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  width: width * 0.35,
                                                  child: new Theme(
                                                    data: new ThemeData(
                                                        primaryColor:
                                                            Colors.black,
                                                        primaryColorDark:
                                                            Colors.black),
                                                    child: TextFormField(
                                                      keyboardType: TextInputType.number,
                                                      cursorColor:
                                                          Colors.black,
                                                      decoration:
                                                          InputDecoration(
                                                        suffixIcon: Icon(Icons
                                                            .dialpad_sharp),
                                                        fillColor:
                                                            Colors.black,
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        labelText: 'CVV',
                                                      ),
                                                      validator:
                                                          (String value) {
                                                        if (value.isEmpty) {
                                                          return 'Invalid cvv';
                                                        } else if (int
                                                                .tryParse(
                                                                    _cvv) >
                                                            999) {
                                                          return 'Invalid cvv';
                                                        }
                                                        return null;
                                                      },
                                                      onChanged: (value) {
                                                        _cvv = value.trim();
                                                      },
                                                      onSaved: (value) =>
                                                          _cvv = value.trim(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Builder(builder: (context) {
                                          return _inProgress == true
                                              ? Column(
                                                children: [
                                                  new Container(
                                                      alignment: Alignment.center,
                                                      height: 50.0,
                                                      child:
                                                          new CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            new AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  Container(child: Text('Please wait a moment...'),)
                                                ],
                                              )
                                              : button(width,height);
                                        })
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget button(double width,double height) {
    return new GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.black,
            ),
            width: 150,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus();
          _formKey.currentState.validate();
          _formKey.currentState.save();
          _formKey.currentState.validate();

          await FirebaseFirestore.instance
              .collection('users').doc(auth.currentUser.uid)
              .get()
              .then((value) {
            if (value['cards'].isEmpty) {
              if (_expiryYear != 0 &&
                  _expiryYear != null &&
                  _expiryMonth != 0 &&
                  _expiryMonth != null &&
                  _cardNumber != null &&
                  _cardNumber != '' &&
                  _cvv != null &&
                  _cvv != '') {
                setState(() => _inProgress = true);
                _startAfreshCharge(context);
              } else {
                Helpers.showMessage('Please fill in all requirements',_scaffoldKey);
              }
            } else {
              List<String> cardNumbers = [];
              for (int i = 0; i < value['cards'].length; i++) {
                cardNumbers.add(value['cards'][i]['cardNumber']);
              }
              if (_expiryYear != 0 &&
                  _expiryYear != null &&
                  _expiryMonth != 0 &&
                  _expiryMonth != null &&
                  _cardNumber != null &&
                  _cardNumber != '' &&
                  _cvv != null &&
                  _cvv != '' &&
                  !cardNumbers.contains(_cardNumber)) {
                setState(() => _inProgress = true);
                _startAfreshCharge(context);
              } else {
                Helpers.showMessage(!cardNumbers.contains(_cardNumber)
                    ? 'Please fill in all requirements properly'
                    : 'This card has already been registered',_scaffoldKey);
              }
            }
          });
        });
  }

  _startAfreshCharge(BuildContext ctx) async {
    _formKey.currentState.save();
   try {
     Charge charge = Charge();
     charge.card = _getCardFromUI();
     setState(() => _inProgress = true);
     charge
       ..amount = 1000 // In base currency
       ..email = auth.currentUser.email
       ..reference = _getReference()
       ..putCustomField('Charged From', 'Flutter SDK');

    await _chargeCard(charge,ctx);
   }catch(e){
     print(e);
   }
  }

  _chargeCard(Charge charge,ctx) async {
    await PaystackPlugin.chargeCard(ctx, charge: charge).then((response) {
//      final reference = response.reference;
      if (response.status == true) {
        Provider.of<Cards>(context, listen: false)
            .addCard(charge.card, _cardNumber);
        Navigator.of(context).pop();
      } else {
         print(response.message);
        Helpers.showMessage('Something went wrong. Please try again',_scaffoldKey);
        setState(() => _inProgress = false);
      }
      // The transaction failed. Checking if we should verify the transaction

//      if (response.verify) {
//        _verifyOnServer(reference);
//      } else {
//        setState(() => _inProgress = false);
//        _updateStatus(reference, response.message);
//      }

    }).catchError((onError){
      print(onError.toString());
    });
    setState(() => _inProgress = false);
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  PaymentCard _getCardFromUI() {
    // Using just the must-required parameters.
    return PaymentCard(
      number: _cardNumber,
      cvc: _cvv,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
    );
  }

//  Future<String> _fetchAccessCodeFrmServer(String reference) async {
//    String url = '${Helpers.backendUrl}/new-access-code';
//    String accessCode;
//    try {
//      print("Access code url = $url");
//      http.Response response = await http.get(url);
//      accessCode = response.body;
//      print('Response for access code = $accessCode');
//    } catch (e) {
//      setState(() => _inProgress = false);
//      _updateStatus(
//          reference,
//          'There was a problem getting a new access code form'
//              ' the backend: $e');
//    }
//
//    return accessCode;
//  }


//  void _verifyOnServer(String reference) async {
//    _updateStatus(reference, 'Verifying...');
//    String url = '${Helpers.backendUrl}/verify/$reference';
//    try {
//      http.Response response = await http.get(url);
//      var body = response.body;
//      _updateStatus(reference, body);
//    } catch (e) {
//      _updateStatus(
//          reference,
//          'There was a problem verifying %s on the backend: '
//              '$reference $e');
//    }
//    setState(() => _inProgress = false);
//  }

//  _updateStatus(String reference, String message) {
//    Helpers.showMessage('Reference: $reference \n\ Response: $message',
//    _scaffoldKey);
//  }
}
