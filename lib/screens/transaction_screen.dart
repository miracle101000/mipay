import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_pay/screens/tab_bar_screens/balance_transaction.dart';
import 'package:mi_pay/screens/tab_bar_screens/top_up_transactions.dart';
import 'package:mi_pay/screens/tab_bar_screens/withdrawal_transactions.dart';


// ignore: must_be_immutable
class TransactionScreen extends StatefulWidget {
  static const routeName = '/transaction-screen';

  int position;


  TransactionScreen(this.position);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  int index = 0;

  @override
  void initState() {
    // TODO: implement initState
    index = widget.position;
    super.initState();
  }
  List<Widget> _widgets = [
    TopUpTransactions(),
    BalanceTransaction(),
    WithdrawalTransactions()
  ];

  tapped(int tappedIndex) {
    setState(() {
      index = tappedIndex;
    });
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
            child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 Padding(
                    padding: EdgeInsets.only(top: height * 0.05, left: 10),
                    child: Center(
                        child: Text(
                          'Transactions',
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
            Expanded(child: _widgets[index])
          ],
        ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          selectedItemColor: Colors.black,
          currentIndex: index,
          onTap: tapped,
          items: [
            BottomNavigationBarItem(
              icon: Container(),
              label: 'Top-Up',
            ),
            BottomNavigationBarItem(
              icon: Container(),
              label: 'Balance',
            ),
            BottomNavigationBarItem(
              icon: Container(),
              label: 'Withdrawal',
            )
          ],
        ),
      ),
    );
  }
}
