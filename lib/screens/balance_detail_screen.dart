
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/models/transactionInfo.dart';


// ignore: must_be_immutable
class BalanceDetailScreen extends StatelessWidget {
  static const routeName = '/balance-transaction-detail-screen';

  TransactionForBalance transactionModel;

  BalanceDetailScreen(this.transactionModel);

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
              height: 150,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                '${transactionModel.userName}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                '+ ₦${Helpers.dp(double.tryParse(transactionModel.amountSent), 2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${DateFormat("EEE, d MMM yyyy").format(DateTime.parse(transactionModel.dateCreated.substring(0, 10) + ' ' + transactionModel.dateCreated.substring(11, 16)))}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8,
                  ),
                  child: Text(
                    '${transactionModel.dateCreated.substring(11, 16)}',
                    style:
                    TextStyle(color: Colors.grey,fontWeight: FontWeight.bold, fontSize: 20),
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
