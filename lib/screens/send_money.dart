import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/models/transactionInfo.dart';
import 'package:mi_pay/providers/balance_transactions.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SendMoney extends StatefulWidget {
  static const routeName = '/send-money';
  var barcodeScanResults;

  SendMoney(this.barcodeScanResults);

  @override
  _SendMoneyState createState() => _SendMoneyState();
}

class _SendMoneyState extends State<SendMoney> {
  final _form = GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String amount = '';
  var auth = FirebaseAuth.instance;
  bool isLoading = false;
  String presentDay;
  int extractUserName;
  String userNameId;

  @override
  void initState() {
    int selection = widget.barcodeScanResults.length - 3;
    var result = widget.barcodeScanResults.substring(0, selection);
    Future(() async {
     await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser.uid)
          .update({'sendTo': result});
    });
    extractUserName = widget.barcodeScanResults.length - 3;
    userNameId = widget.barcodeScanResults.substring(0, extractUserName);
    presentDay = DateTime.now().toString().substring(0, 10);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(auth.currentUser.uid)
                                  .update({'sendTo': ''});
                            }),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userNameId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.black,
                                        backgroundImage: AssetImage(
                                            'assets/images/placeholder.png'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Text(
                                          'Loading...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.black,
                                      backgroundImage: NetworkImage(
                                          snapshot.data['image_url']),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Text(
                                        '${snapshot.data['username']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
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
                                    return 'Please provide a value';
                                  } else if (double.tryParse(value.trim()) ==
                                      0.00) {
                                    return 'Cannot transfer';
                                  } else if (value == '') {
                                    return 'Cannot transfer';
                                  } else if (value == ' ') {
                                    return 'Cannot transfer';
                                  }
                                  return null;
                                },
                                onSaved: (input) {
                                  amount = Helpers.dp(
                                          double.tryParse(input.trim()), 2)
                                      .toString();
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(20)),
                                  labelText: '₦',
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            isLoading == true
                                ? Container(
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
                                  )
                                : GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.black,
                                        ),
                                        width: 300,
                                        height: 60,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              'Send Money',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      _form.currentState.validate();
                                      _form.currentState.save();
                                      setState(() {
                                        isLoading = true;
                                      });
                                      FocusScope.of(context).unfocus();
                                      _sendMoney(widget.barcodeScanResults);
                                    },
                                  )
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
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
                          .push(Helpers.createRouteTransaction(1));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendMoney(String barCodeScanResult) async {
    _form.currentState.validate();
    _form.currentState.save();
    double subtractionResult;
    double additionResult;
    FocusScope.of(context).unfocus();
    int selection = barCodeScanResult.length - 3;
    var result = barCodeScanResult.substring(0, selection);
    if (result != auth.currentUser.uid.toString()) {
      final user = FirebaseAuth.instance.currentUser;
      final senderData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final receiverData = await FirebaseFirestore.instance
          .collection('users')
          .doc(result)
          .get();
      subtractionResult = Helpers.dp(
          double.tryParse(senderData['balance']) - double.tryParse(amount), 2);
      additionResult = Helpers.dp(
          double.tryParse(receiverData['balance']) + double.tryParse(amount),
          2);
      if (subtractionResult < 0.0) {
        setState(() {
          isLoading = false;
        });
        _form.currentState.validate();
        _form.currentState.save();
        Helpers.showMessage(
            'Cannot send more than your current balance', _scaffoldKey);
      } else {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(result)
              .update({'balance': additionResult.toString()}).then(
                  (value) async {
            await Provider.of<BalanceTransactions>(context, listen: false)
                .addTransaction(
                    TransactionForBalance(
//                    userName: value['username'],
                        amountSent: amount,
                        dateCreated: DateTime.now().toString(),
                        entity: 'receiver'),
                    result,
                    user.uid);
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'balance': subtractionResult.toString()}).then(
                  (value) async {
            setState(() {
              isLoading = false;
            });
            await Provider.of<BalanceTransactions>(context, listen: false)
                .addTransaction(
                    TransactionForBalance(
//                  userName: value['username'],
                        amountSent: amount,
                        dateCreated: DateTime.now().toString(),
                        entity: 'sender'),
                    user.uid,
                    result);
            FocusScope.of(context).unfocus();
            Helpers.showMessage('Money sent', _scaffoldKey);
            Navigator.of(context).pop();
          }).then((value) async {
          await  FirebaseFirestore.instance.collection('Transactions').add({
              'content': 'sent you',
               'amount': amount,
              'idFrom': auth.currentUser.uid,
              'idTo': result,
              'timestamp': Timestamp.now(),
            }).then((value) async {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(auth.currentUser.uid)
                .update({'sendTo': ''});
          });
          });
        } catch (error) {
//          print(' mY ERROR $error');
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser.uid)
          .update({'sendTo': ''});
      Helpers.showMessage('This is the same account', _scaffoldKey);
    }
  }
}
