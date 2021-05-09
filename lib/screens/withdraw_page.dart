import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/models/bank.dart';


// ignore: must_be_immutable
class Withdraw extends StatefulWidget {
  static const routeName = '/withdraw';
  String balance;

  Withdraw(this.balance);

  @override
  _WithdrawState createState() => _WithdrawState();
}

class _WithdrawState extends State<Withdraw> {
  final _amountKey = GlobalKey<FormState>();
  final _acctNameKey = GlobalKey<FormState>();
  final _acctNumberKey = GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var auth = FirebaseAuth.instance;
  String dropdownValue = 'Access Bank';
  String accountName;
  String accountNumber;
  String code = '044';
  bool isLoading = false;
  bool isLoadingAll = false;
  bool isAgreed = false;
  double updateBalance;
  String recipientCode;
  double settlement;
  String amount = '0.00';
  String check = 'withdraw';

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.05, left: 10),
                      child: Center(
                          child: Text(
                            'Withdraw',
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
                SizedBox(height: 18.0,),
                Container(
                  width: width,
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'The account name should be according to your bank details',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Transactions',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(Helpers.createRouteTransaction(2));
                    }),
                SizedBox(
                  height: height * 0.03,
                ),
                Container(
                  height: height,
                  child: Column(
                    children: [
                      Form(
                        key: _amountKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Theme(
                            data: new ThemeData(
                                primaryColor: Colors.black,
                                primaryColorDark: Colors.black),
                            child: TextFormField(
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                  suffixIcon: Icon(Icons.dialpad_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  labelText: 'Amount'),
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please provide a value';
                                } else if (double.tryParse(value.trim()) >
                                    double.tryParse(widget.balance)) {
                                  return 'Exceeds the maximum amount you can withdraw';
                                } else if (double.tryParse(value.trim()) ==
                                    0.00) {
                                  return 'Cannot withdraw ';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                amount =
                                    Helpers.dp(double.tryParse(value.trim()), 2)
                                        .toString();
                              },
                            ),
                          ),
                        ),
                      ),
                      Form(
                        key: _acctNameKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Theme(
                            data: new ThemeData(
                                primaryColor: Colors.black,
                                primaryColorDark: Colors.black),
                            child: TextFormField(
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                  suffixIcon:
                                      Icon(Icons.accessibility_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  labelText: 'Account Name'),
                              onSaved: (value) {
                                accountName = value.trim();
                              },
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please provide a name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      Form(
                        key: _acctNumberKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Theme(
                            data: new ThemeData(
                                primaryColor: Colors.black,
                                primaryColorDark: Colors.black),
                            child: TextFormField(
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    suffixIcon:
                                        Icon(Icons.more_horiz_rounded),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    labelText: 'Account Number'),
                                onSaved: (value) {
                                  accountNumber = value.trim();
                                },
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Please provide an account number';
                                  }
                                  return null;
                                }),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              width: 100,
                              child: Text(
                                '₦ ${Helpers.dp(double.tryParse(widget.balance), 2)} left in Balance',
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Select bank below'),
                          ),
                        ],
                      ),
                      ///drop
                      buildDropDown(context),
                      isLoading == true
                          ? CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.black),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  width: 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.black,
                                  ),
                                  child: FlatButton(
                                      onPressed: () async {
                                        check = 'withdraw';
                                        FocusScope.of(context).unfocus();
                                        _amountKey.currentState.validate();
                                        _acctNameKey.currentState
                                            .validate();
                                        _acctNumberKey.currentState
                                            .validate();
                                        _amountKey.currentState.save();
                                        _acctNameKey.currentState.save();
                                        _acctNumberKey.currentState.save();
                                        _amountKey.currentState.validate();
                                        _acctNameKey.currentState
                                            .validate();
                                        _acctNumberKey.currentState
                                            .validate();
                                        if (amount.isNotEmpty &&
                                                accountNumber.isNotEmpty &&
                                                accountName.isNotEmpty &&
                                                double.tryParse(amount) <
                                                    double.tryParse(
                                                        widget.balance) &&
                                                double.tryParse(amount) >
                                                    19.00 ||
                                            amount.isNotEmpty &&
                                                accountNumber.isNotEmpty &&
                                                accountName.isNotEmpty &&
                                                double.tryParse(amount) ==
                                                    double.tryParse(
                                                        widget.balance) &&
                                                double.tryParse(amount) >
                                                    19.00) {
                                          await verifyAccount(
                                                  accountNumber, code)
                                              .then((value) async {
                                            if (accountName.toLowerCase() ==
                                                value) {
                                              Helpers.showMessage(
                                                  'Account verification success',_scaffoldKey);
                                              await createTransfer(
                                                      accountName,
                                                      accountNumber,
                                                      code)
                                                  .then((value) {
                                                setState(() {
                                                  recipientCode =
                                                      value.trim();
                                                });
                                                showAlertDialog(
                                                    context, amount);
                                              });
                                            } else {
                                              Helpers.showMessage(
                                                  'The account name does not match the account number',_scaffoldKey);
                                            }
                                          });
                                        } else {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          Helpers.showMessage(double.tryParse(
                                                      amount) >
                                                  double.tryParse(
                                                      widget.balance)
                                              ? 'The amount set is more than the maximum amount you can withdraw'
                                              : double.tryParse(amount) < 20
                                                  ? 'You cannot with draw less than ₦20'
                                                  : 'Please fill in all required fields',_scaffoldKey);
                                        }
                                      },
                                      child: Text(
                                        'Withdraw',
                                        style:
                                            TextStyle(color: Colors.white),
                                      ))),
                            ),
                      isLoadingAll == true
                          ? CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.black),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.black,
                                  ),
                                  width: 300,
                                  child: FlatButton(
                                      onPressed: () async {
                                        check = 'withdraw all';
                                        FocusScope.of(context).unfocus();
                                        _acctNameKey.currentState
                                            .validate();
                                        _acctNumberKey.currentState
                                            .validate();
                                        _acctNameKey.currentState.save();
                                        _acctNumberKey.currentState.save();
                                        _acctNameKey.currentState
                                            .validate();
                                        _acctNumberKey.currentState
                                            .validate();
                                        if (double.tryParse(
                                                    widget.balance) !=
                                                0.00 &&
                                            accountNumber.isNotEmpty &&
                                            accountName.isNotEmpty &&
                                            double.tryParse(
                                                    widget.balance) >
                                                19.00) {
                                          await verifyAccount(
                                                  accountNumber, code)
                                              .then((value) async {
                                            if (accountName.toLowerCase() ==
                                                value) {
                                              Helpers.showMessage(
                                                  'Account verification success',_scaffoldKey);
                                              await createTransfer(
                                                      accountName,
                                                      accountNumber,
                                                      code)
                                                  .then((value) {
                                                setState(() {
                                                  recipientCode =
                                                      value.trim();
                                                });
                                                showAlertDialog(context,
                                                    widget.balance);
                                              });
                                            } else {
                                              Helpers.showMessage(
                                                  'The account name does not match the account number',_scaffoldKey);
                                            }
                                          });
                                        } else {
                                          setState(() {
                                            isLoadingAll = false;
                                          });
                                          Helpers.showMessage(double.tryParse(
                                                      widget.balance) ==
                                                  0.00
                                              ? 'You do not have money in your balance'
                                              : double.tryParse(
                                                          widget.balance) >
                                                      19.00
                                                  ? 'You cannot with draw less than ₦20'
                                                  : 'Please fill in all required fields ',_scaffoldKey);
                                        }
                                      },
                                      child: Text(
                                        'Withdrawal All ',
                                        style:
                                            TextStyle(color: Colors.white),
                                      ))),
                            ),
//                            Padding(
//                              padding: const EdgeInsets.all(8.0),
//                              child: Container(
//                                  decoration: BoxDecoration(
//                                    borderRadius: BorderRadius.circular(20),
//                                    color: Colors.black,
//                                  ),
//                                  width: 300,
//                                  child: FlatButton(
//                                      onPressed: () async {
//                                        FocusScope.of(context).unfocus();
//                                        disableOTP();
//                                      },
//                                      child: Text(
//                                        'Disable OTP ',
//                                        style: TextStyle(color: Colors.white),
//                                      ))),
//                            ),
//                            Padding(
//                              padding: const EdgeInsets.all(8.0),
//                              child: Container(
//                                  decoration: BoxDecoration(
//                                    borderRadius: BorderRadius.circular(20),
//                                    color: Colors.black,
//                                  ),
//                                  width: 300,
//                                  child: FlatButton(
//                                      onPressed: () async {
//                                        finalizeDisableOTP('913789');
//                                        FocusScope.of(context).unfocus();
//                                      },
//                                      child: Text(
//                                        'Finalize Disable OTP',
//                                        style: TextStyle(color: Colors.white),
//                                      ))),
//                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropDown(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('banks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null && snapshot.data.documents.length != 0 ) {
            List<Bank> banks = [];
            for (int i = 0; i < 49; i++) {
              banks.add(Bank(
                  name: snapshot.data.documents[i]['name'],
                  code: snapshot.data.documents[i]['code']));
            }
            return Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton(
                    value: dropdownValue,
                    icon: Icon(
                      Icons.more,
                      color: Colors.black,
                    ),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black),
                    underline: Container(
                      height: 2,
                      width: 250,
                      color: Colors.black,
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        var b;
                        b = banks
                            .where((element) => element.name == dropdownValue)
                            .toSet()
                            .toList();
                        code = b[0].code;
                      });
                    },
                    items: banks.map((value) {
                      return DropdownMenuItem<String>(
                        value: value.name,
                        child: Text(value.name),
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 3.0, bottom: 3),
            child: Container(
              height: 50,
              child: Text('Loading...'),
            ),
          );
        });
  }



  Future<String> verifyAccount(String accountNumber, String code) async {
    setState(() {
      isLoading = check != 'withdraw' ? false : true;
      isLoadingAll = check == 'withdraw' ? false : true;
    });
    var extractedData;

    try {
      http.Response response = await http.get(
          'https://api.paystack.co/bank/resolve?account_number=$accountNumber&bank_code=$code',
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer ${Helpers.paystackSecretKey}'
          });
      extractedData = jsonDecode(response.body)['data'];

      if (extractedData == null) {
        isLoading = false;
        isLoadingAll = false;
       Helpers.showMessage('Something went wrong please try again',_scaffoldKey);
      }

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON.
        setState(() {
          isLoading = false;
          isLoadingAll = false;
        });
        Helpers.showMessage('Account Name and Number is verified',_scaffoldKey);
      } else {
        setState(() {
          isLoading = false;
          isLoadingAll = false;
        });

        // If that response was not OK, throw an error.
        Helpers.showMessage(
            'Something went wrong please try again. Please check your details and try again',_scaffoldKey);
        throw Exception('Failed to load json data');
      }
    } catch (error) {}
     print(extractedData['account_name'].toString().toLowerCase());
    return extractedData['account_name'].toString().toLowerCase();
  }

  Future<String> createTransfer(
      String accountName, String accountNumber, String code) async {
    var extractedData;
    try {
      http.Response response =
          await http.post('https://api.paystack.co/transferrecipient',
              headers: {
                HttpHeaders.authorizationHeader: 'Bearer ${Helpers.paystackSecretKey}',
                HttpHeaders.contentTypeHeader: 'application/json',
              },
              body: json.encode({
                'type': 'nuban',
                'name': '$accountName',
                'account_number': '$accountNumber',
                'bank_code': '$code',
                'currency': 'NGN'
              }));
      extractedData = jsonDecode(response.body)['data']['recipient_code'];
      if (extractedData == null) {
        Helpers.showMessage('Something went wrong please try again',_scaffoldKey);
      }

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON.
        return json.decode('Good');
      } else {
        Helpers.showMessage('Something went wrong please try again',_scaffoldKey);
        // If that response was not OK, throw an error.
        throw Exception('Failed to load json data');
      }
    } catch (error) {}
    print(extractedData);
    return extractedData;
  }

  Future<String> initiateTransfer(String amount, String recipientCode) async {
    print(amount);
    print(recipientCode);

    settlement = double.tryParse(amount) < 2500.00
        ? Helpers.dp(((double.tryParse(amount) * 0.985) - 13), 2) * 100
        : double.tryParse(amount) > 2500.00 &&
                    double.tryParse(amount) < 5000.00 ||
                double.tryParse(amount) == 2500.00 ||
                double.tryParse(amount) == 5000.00
            ? Helpers.dp(((double.tryParse(amount) * 0.985) - 113), 2) * 100
            : double.tryParse(amount) > 5000.00 &&
                        double.tryParse(amount) < 50000.00 ||
                    double.tryParse(amount) == 50000.00
                ? Helpers.dp(((double.tryParse(amount) * 0.985) - 128), 2) * 100
                : double.tryParse(amount) > 50000.00 &&
                            double.tryParse(amount) < 126666.99 ||
                        double.tryParse(amount) == 126666.99
                    ? Helpers.dp(((double.tryParse(amount) * 0.985) - 153), 2) * 100
                    : Helpers.dp((double.tryParse(amount) - 2053), 2) * 100 ;
    var extractedData;
    try {
      http.Response response =
          await http.post('https://api.paystack.co/transfer',
              headers: {
                HttpHeaders.authorizationHeader: 'Bearer ${Helpers.paystackSecretKey}',
                HttpHeaders.contentTypeHeader: 'application/json',
              },
              body: json.encode({
                'source': 'balance',
                'reason': 'balance',
                'amount': '$settlement',
                'recipient': recipientCode
              }));
      extractedData = jsonDecode(response.body);

      if (extractedData == null) {
        Helpers.showMessage('Something went wrong please try again',_scaffoldKey);
      }

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON.
        return json.decode('Good');
      } else {
        Helpers.showMessage('Something went wrong please try again',_scaffoldKey);
        // If that response was not OK, throw an error.
        throw Exception('Failed to load json data');
      }
    } catch (error) {
      print(error);
    }
    print(extractedData);
    return extractedData;
  }

  Future<String> finalizeTransfer(String transferCode) async {
//    print(amount);
//    print(recipientCode);
    print(transferCode);
    var extractedData;
    try {
      http.Response response =
          await http.post('https://api.paystack.co/transfer/finalize_transfer',
              headers: {
                HttpHeaders.authorizationHeader: 'Bearer ${Helpers.paystackSecretKey}',
                HttpHeaders.contentTypeHeader: 'application/json',
              },
              body: json.encode({'transfer_code': transferCode}));
      extractedData = jsonDecode(response.body)['data']['status'];

      if (extractedData == null) {
        Helpers.showMessage('Something went wrong please try again',_scaffoldKey);
      }

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON.
        return json.decode('Good');
      } else {
        Helpers.showMessage('Something went wrong please try again',_scaffoldKey);
        // If that response was not OK, throw an error.
        throw Exception('Failed to load json data');
      }
    } catch (error) {}
    print(extractedData);
    return extractedData;
  }

  Future<bool> deleteTransferRecipient(String recipientCode) async {
//    print(amount);
//    print(recipientCode);
    var extractedData;
    try {
      http.Response response = await http.delete(
          'https://api.paystack.co/transferrecipient/$recipientCode',
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer ${Helpers.paystackSecretKey}',
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      extractedData = jsonDecode(response.body)['status'];

      if (extractedData == null) {
        Helpers.showMessage('Something went wrong please try again',_scaffoldKey);
      }

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON.
        return json.decode('Good');
      } else {
        Helpers.showMessage('Something went wrong please try again',_scaffoldKey);
        // If that response was not OK, throw an error.
        throw Exception('Failed to load json data');
      }
    } catch (error) {}
    print(extractedData);
    return extractedData;
  }

  showAlertDialog(BuildContext context, String amount) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () async {
        Navigator.of(context).pop();
        var e = await deleteTransferRecipient(recipientCode);
        print(e);
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Agree",
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: () async {
        Navigator.of(context).pop();
        var status;
        await initiateTransfer(amount, recipientCode).then((value) async {
          await finalizeTransfer(value).then((value) async { 
            print('finalize order$value');
            await FirebaseFirestore.instance
                .collection('users')
                .get()
                .then((value) async {
              Helpers.showMessage('The money will be transferred within 2 hours...',_scaffoldKey);
              updateBalance = Helpers.dp(
                  double.tryParse(widget.balance) - double.tryParse(amount), 2);
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(auth.currentUser.uid)
                  .update({'balance': updateBalance.toString()});
            });
            await auth.currentUser.reload();
          }).catchError((onError) async {
            Helpers.showMessage('Something went wrong',_scaffoldKey);
            await deleteTransferRecipient(recipientCode);
          });
        });
        if (status != 'success') {
          Helpers.showMessage('Something went wrong',_scaffoldKey);
          await deleteTransferRecipient(recipientCode);
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          isAgreed = false;
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.black,
      title: Text(
        "Verify Withdrawal",
        style: TextStyle(color: Colors.white),
      ),
      content: RichText(
        maxLines: 4,
        text: TextSpan(
          text: 'Due to services charge, we will settle you :\n',
          style: TextStyle(color: Colors.white),
          children: <TextSpan>[
            TextSpan(
                text:
                    '₦${double.tryParse(amount) < 2500.00 ? '${Helpers.dp(((double.tryParse(amount) * 0.985) - 13), 2)}' : double.tryParse(amount) > 2500.00 && double.tryParse(amount) < 5000.00 || double.tryParse(amount) == 2500.00 || double.tryParse(amount) == 5000.00 ? '${Helpers.dp(((double.tryParse(amount) * 0.985) - 113), 2)}' : double.tryParse(amount) > 5000.00 && double.tryParse(amount) < 50000.00 || double.tryParse(amount) == 50000.00 ? '${Helpers.dp(((double.tryParse(amount) * 0.985) - 128), 2)}' : double.tryParse(amount) > 50000.00 && double.tryParse(amount) < 126666.99 || double.tryParse(amount) == 126666.99 ? '${Helpers.dp(((double.tryParse(amount) * 0.985) - 153), 2)}' : '${Helpers.dp((double.tryParse(amount) - 2053), 2)}'}\n',
                style: TextStyle(color: Colors.green, fontSize: 20)),
          ],
        ),
      ),

//      Text(
//          " ${double.tryParse(amount) < 2500.00 ? '1.5% + ₦13' : double.tryParse(amount) > 2500.00 && double.tryParse(amount) < 5000.00 || double.tryParse(amount) == 2500.00 || double.tryParse(amount) == 5000.00 ? '1.5% + ₦113' : double.tryParse(amount) > 5000.00 && double.tryParse(amount) < 50000.00 || double.tryParse(amount) == 50000.00 ? '1.5% + ₦128' : double.tryParse(amount) > 50000.00 && double.tryParse(amount) < 126666.99 || double.tryParse(amount) == 126666.99 ? '1.5% + ₦153' : '₦2053'}\n"
//          "We will settle you ₦${double.tryParse(amount) < 2500.00 ? '${dp(((double.tryParse(amount) * 0.985) - 13),2)}' : double.tryParse(amount) > 2500.00 && double.tryParse(amount) < 5000.00 || double.tryParse(amount) == 2500.00 || double.tryParse(amount) == 5000.00 ? '${dp(((double.tryParse(amount) * 0.985) - 113),2)}' : double.tryParse(amount) > 5000.00 && double.tryParse(amount) < 50000.00 || double.tryParse(amount) == 50000.00 ? '${dp(((double.tryParse(amount) * 0.985) - 128),2)}' : double.tryParse(amount) > 50000.00 && double.tryParse(amount) < 126666.99 || double.tryParse(amount) == 126666.99 ? '${dp(((double.tryParse(amount) * 0.985) - 153),2)}' : '${dp((double.tryParse(amount)  - 2053),2)}'}\n No extra fees during transfer",style: TextStyle(color: Colors.white),),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

//Future<void> disableOTP()async{
//  var extractedData;
//  try {
//    http.Response response =
//        await http.post('https://api.paystack.co/transfer/disable_otp',
//        headers: {
//          HttpHeaders.authorizationHeader: 'Bearer $paystackSecretKey',
//          HttpHeaders.contentTypeHeader: 'application/json',
//        });
//    extractedData = jsonDecode(response.body)['message'];
//
//    if (extractedData == null) {
//      _showMessage('Something went wrong please try again');
//    }
//
//    if (response.statusCode == 200) {
//      // If server returns an OK response, parse the JSON.
//      return json.decode('Good');
//    } else {
//      _showMessage('Something went wrong please try again');
//      // If that response was not OK, throw an error.
//      throw Exception('Failed to load json data');
//    }
//  } catch (error) {}
//  print(extractedData);
//
//}

//  Future<void> finalizeDisableOTP(String otp)async{
//    var extractedData;
//    try {
//      http.Response response =
//      await http.post('https://api.paystack.co/transfer/disable_otp_finalize',
//          headers: {
//            HttpHeaders.authorizationHeader: 'Bearer $paystackSecretKey',
//            HttpHeaders.contentTypeHeader: 'application/json',
//
//          },
//      body: json.encode({
//        "otp": otp
//      }));
//      extractedData = jsonDecode(response.body)['message'];
//
//      if (extractedData == null) {
//        _showMessage('Something went wrong please try again');
//      }
//
//      if (response.statusCode == 200) {
//        // If server returns an OK response, parse the JSON.
//        return json.decode('Good');
//      } else {
//        _showMessage('Something went wrong please try again');
//        // If that response was not OK, throw an error.
//        throw Exception('Failed to load json data');
//      }
//    } catch (error) {}
//    print(extractedData);
//
//  }

}