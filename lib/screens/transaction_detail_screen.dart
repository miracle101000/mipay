import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/models/transaction_model.dart';

// ignore: must_be_immutable
class TransactionDetailScreen extends StatelessWidget {
  static const routeName = '/transaction-detail-screen';

  TransactionModel transactionModel;

  TransactionDetailScreen(this.transactionModel);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      'Details',
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
            ),
            SizedBox(
              height: height * 0.1,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                '+ ₦${Helpers.dp(transactionModel.amount.toDouble() / 100, 2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: width,
                  child: Text(
                    '${transactionModel.cardType.toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${transactionModel.cardNumberUsed}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${DateFormat("EEE, d MMM yyyy").format(DateTime.parse(transactionModel.time.substring(0, 10) + ' ' + transactionModel.time.substring(11, 16)))}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8,
                  ),
                  child: Text(
                    '${transactionModel.time.substring(11, 16)}',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
