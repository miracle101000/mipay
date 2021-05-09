import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bank_selection.dart';

// ignore: must_be_immutable
class TopUp extends StatefulWidget {
  static const routeName = '/top-up';
  String previousDay;

  TopUp(this.previousDay);

  @override
  _TopUpState createState() => _TopUpState();
}

class _TopUpState extends State<TopUp> {
  final _form = GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String amount = '';
  var auth = FirebaseAuth.instance;
  var initialAmount;
  var currentAmount;

  // ignore: non_constant_identifier_names
  String maxAmount = '5000000.00';
  String presentDay;
  String measureAmount = '0.0';

  bool isLoading = false;

  @override
  void initState() {
    PaystackPlugin.initialize(publicKey: Helpers.paystackPublicKey);
    presentDay = DateTime.now().toString().substring(0, 10);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.05, left: 10),
                      child: Center(
                          child: Text(
                        'Top-Up',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: width * 0.078,
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
                SizedBox(
                  height: 18.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Daily max amount:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, top: 4),
                                  child: Text(
                                    '₦5,000,000.00',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Transactions',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .push(Helpers.createRouteTransaction(0));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          Theme(
                            data: new ThemeData(
                                primaryColor: Colors.black,
                                primaryColorDark: Colors.black),
                            child: TextFormField(
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (String value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return 'Please provide a value';
                                } else if (double.tryParse(value.trim()) >
                                    5000000.00) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return 'Exceeds the maximum amount for top-up';
                                } else if (double.tryParse(value.trim()) ==
                                    0.00) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return 'Cannot Top-up ';
                                }
                                return null;
                              },
                              onSaved: (input) {
                                amount = input.trim();
                                print(amount);
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(20)),
                                labelText: '₦',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(auth.currentUser.uid)
                                  .snapshots(),
                              builder: (ctx, cardsSnapshot) {
                                if (cardsSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final checkCards = cardsSnapshot.data['cards'];
                                List<String> cardNumbers = [];
                                for (int i = 0;
                                    i < cardsSnapshot.data['cards'].length;
                                    i++) {
                                  cardNumbers.add(cardsSnapshot.data['cards'][i]
                                      ['cardNumber']);
                                }
                                final cardsDocs =
                                    cardsSnapshot.data['selectedCard'];
                                return checkCards.isEmpty == true ||
                                        !cardNumbers
                                            .contains(cardsDocs['cardNumber'])
                                    ? GestureDetector(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Container(
                                                child: Text(
                                                    'Add a payment method'),
                                              ),
                                            ),
                                            Icon(Icons.more)
                                          ],
                                        ),
                                        onTap: () {
                                          showBottomShee(context);
                                        },
                                      )
                                    : GestureDetector(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: cardsDocs[
                                                              'cardType'] ==
                                                          'Visa'
                                                      ? Image.network(
                                                          'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/viasacard.png?alt=media&token=4f4ec102-54bd-4aeb-8b4e-74505bfba8db')
                                                      : cardsDocs['cardType'] ==
                                                              'MasterCard'
                                                          ? Image.network(
                                                              'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/mastrcard.png?alt=media&token=e4ea1367-0740-4e96-a500-be0995955a76')
                                                          : cardsDocs['cardType'] ==
                                                                  'American Express'
                                                              ? Image.network(
                                                                  'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/americanexp.png?alt=media&token=75c43624-071a-43fb-96e4-427a4a6e660c')
                                                              : cardsDocs['cardType'] ==
                                                                      'Diners Club'
                                                                  ? Image.network(
                                                                      'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/dinersclub.png?alt=media&token=e2c6c846-f083-4c94-82e6-ae4a5b0798ee')
                                                                  : cardsDocs['cardType'] ==
                                                                          'Discover'
                                                                      ? Image.network(
                                                                          'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/discover.png?alt=media&token=1a13524b-f9dc-4952-bb0c-046581b9f162')
                                                                      : cardsDocs['cardType'] ==
                                                                              'JCB'
                                                                          ? Image.network(
                                                                              'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/jcb.png?alt=media&token=14291f65-3d6e-4bdc-9c3e-ca7ffbc07536')
                                                                          : cardsDocs['cardType'] == 'VERVE'
                                                                              ? Image.network('https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/verve.png?alt=media&token=8c3a45fa-c919-4cb6-ad11-4576eb3e48da')
                                                                              : Container(),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.70,
                                                  child: Text(
                                                    '${cardsDocs['bankName']}  ${cardsDocs['cardForm']}...${cardsDocs['cardNumber'].substring(cardsDocs['cardNumber'].length - 4)}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Icon(Icons.more)
                                          ],
                                        ),
                                        onTap: () {
                                          showBottomShee(context);
                                        },
                                      );
                              }),
                          SizedBox(
                            height: 20,
                          ),
                          isLoading == true
                              ? Column(
                                children: [
                                  Container(
                                      height: 50,
                                      width: 50,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.black),
                                        ),
                                      ),
                                    ),
                                  Container(child: Text('Please wait a moment...'),),
                                  Container(child: Text('Transaction in progress...'),)
                                ],
                              )
                              : GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.black,
                                    ),
                                    width: 300,
                                    height: 60,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          'Top-Up',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    FocusScope.of(context).unfocus();
                                    _form.currentState.validate();
                                    _form.currentState.save();
                                    _form.currentState.validate();
                                    if (amount == '') {
                                      print('error');
                                    } else if (double.tryParse(amount) >
                                        5000000.00) {
                                      print('error');
                                    } else {
                                      _startAfreshCharge();
                                    }
                                  },
                                )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showBottomShee(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            child: BankSelection(),
          );
        });
  }

  _startAfreshCharge() async {
    final prefs = await SharedPreferences.getInstance();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser.uid)
        .get()
        .then((val) async {
      if (val.exists) {
        initialAmount = val['balance'];
        measureAmount = val['measureAmount'].toString();
        if (double.tryParse(amount) > double.tryParse(maxAmount)) {
          Helpers.showMessage(
              'This would exceed the maximum top-up amount for a day',
              _scaffoldKey);
        } else if (double.tryParse(maxAmount) -
                        double.tryParse(initialAmount) ==
                    0 &&
                presentDay == widget.previousDay ||
            (double.tryParse(maxAmount) - double.tryParse(initialAmount))
                    .isNegative &&
                presentDay == widget.previousDay) {
          prefs.setString(
              'previousDate', DateTime.now().toString().substring(0, 10));
          Helpers.showMessage(
              'You have reached the maximum top-up of today ', _scaffoldKey);
          FirebaseFirestore.instance
              .collection("users")
              .doc(auth.currentUser.uid)
              .update(
                  {'previousDate': DateTime.now().toString().substring(0, 10)});
        } else if (double.tryParse(maxAmount) -
                    double.tryParse(measureAmount) ==
                0 &&
            widget.previousDay != presentDay) {
          Helpers.showMessage(
              'You have reached the maximum top-up of today ', _scaffoldKey);
          prefs.setString(
              'previousDate', DateTime.now().toString().substring(0, 10));
          measureAmount = '0.00';
          FirebaseFirestore.instance
              .collection("users")
              .doc(auth.currentUser.uid)
              .update({
            'measureAmount': measureAmount,
            'previousDate': DateTime.now().toString().substring(0, 10)
          });
        } else if (presentDay == prefs.get('previousDate')) {
          Helpers.showMessage(
              'You have reached the maximum top-up of today', _scaffoldKey);
        } else {
          print('approve');
          try {
            int theAmount = 100;
            Charge charge = Charge();
            charge.card = await _getCardFromUI();
            charge
              ..amount = (double.tryParse(amount) * 100).toInt()
              // In base currency
              ..email = auth.currentUser.email
              ..reference = _getReference()
              ..putCustomField('Charged From', 'Flutter SDK');
            await _chargeCard(charge);
          } catch (e) {
            print(e);
          }
        }
      } else {
        print("Not Found");
      }
    });
  }

  Future<void> _chargeCard(Charge charge) async {
    await PaystackPlugin.chargeCard(context, charge: charge).then((response) {
      if (response.status == true) {
        Navigator.of(context).pop();
        currentAmount =
            double.tryParse(initialAmount) + double.tryParse(amount);
        measureAmount =
            '${double.tryParse(measureAmount) + double.tryParse(amount)}';
        FirebaseFirestore.instance
            .collection("users")
            .doc(auth.currentUser.uid)
            .update({
          'balance': currentAmount.toString(),
          'measureAmount': measureAmount
        });
      } else {
        Helpers.showMessage(
            'Something went wrong. Please try again', _scaffoldKey);
//        setState(() => _inProgress = false);
      }
    });
//    setState(() => _inProgress = false);
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

  Future<PaymentCard> _getCardFromUI() async {
    var card;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser.uid)
        .get()
        .then((val) {
      if (val['cards'].isNotEmpty) {
        if (val.exists) {
          card = val['selectedCard'];
          print(' v $card');
        } else {
          print("Not Found");
        }
      } else {
        Helpers.showMessage('Add a payment method', _scaffoldKey);
      }
    });
    // Using just the must-required parameters.
    return PaymentCard(
      number: card['cardNumber'],
      cvc: card['cvv'],
      expiryMonth: int.tryParse(card['expiryMonth']),
      expiryYear: int.tryParse(card['expiryYear']),
    );
  }
}
