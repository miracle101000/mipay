
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/screens/top_up_page.dart';
import 'package:mi_pay/screens/withdraw_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


// ignore: must_be_immutable
class Balance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String previousDay;
    String balance;
    var height = MediaQuery.of(context).size.height;
//    var width = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: Color(0xFFF9F9F9),
            height: height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 28.0, left: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          child: Text(
                            'Transactions',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .push(Helpers.createRouteTransaction(1));
                          },
                        ),
                        IconButton(
                            icon: Icon(Icons.clear, color: Colors.black),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'My Balance',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser.uid)
                          .snapshots(),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.black)),
                          );
                        }
                        final cardsDocs = snapshot.data['balance'];
                        balance = cardsDocs;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Center(
                            child: Text(
                              '₦ ${cardsDocs == '' ? 0.0 : Helpers.dp(double.tryParse(cardsDocs), 2)}',
                              style: TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }),
                  SizedBox(
                    height: height * 0.2,
                  ),
                  FlatButton(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Top Up',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      previousDay = prefs.get('previousDate');
                      Navigator.of(context)
                          .push(_createRouteTopUp(previousDay));
                    },
                    color: Colors.black,
                  ),
                  FlatButton(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Withdraw',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(_createRouteWithdraw(balance));
                    },
                    color: Colors.black,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Route _createRouteTopUp(String previousDay) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          TopUp(previousDay),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _createRouteWithdraw(String balance) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          Withdraw(balance),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  getUser() async {
    var user = FirebaseAuth.instance.currentUser;
    return user.uid;
  }
}
