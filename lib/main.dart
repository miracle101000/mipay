import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_pay/providers/auth.dart';
import 'package:mi_pay/providers/balance_transactions.dart';
import 'package:mi_pay/providers/cards.dart';
import 'package:mi_pay/providers/login_check.dart';
import 'package:mi_pay/providers/transactions.dart';
import 'package:mi_pay/providers/withdrawals.dart';
import 'package:mi_pay/screens/splash_screen.dart';
import 'package:mi_pay/screens/time_out/time_out_login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_section.dart';
import 'config/manage.dart';
import 'config/routes.dart';
import 'models/card.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> _refreshCards(BuildContext context) async {
    var extractedUserCard;
    await SharedPreferences.getInstance().then((value) {
      if (value.getBool('userVerify') == null) {
        value.setBool('userVerify', false);
        extractedUserCard = value.getBool('userVerify');
      } else {
        extractedUserCard = value.getBool('userVerify');
      }
    });
    return extractedUserCard;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProvider(create: (ctx) => LoginCheck()),
        ChangeNotifierProvider(create: (ctx) => Cards()),
        ChangeNotifierProvider(create: (ctx) => CardInfo()),
        ChangeNotifierProvider(create: (ctx) => Transactions()),
        ChangeNotifierProvider(create: (ctx) => Withdrawals()),
        ChangeNotifierProvider(create: (ctx) => BalanceTransactions()),
      ],
      child: Consumer<Auth>(
        builder: (ctx,auth,_) => Consumer<LoginCheck>(
          builder: (ctx,check,_) => MaterialApp(
                    theme: ThemeData(
                        focusColor: Colors.black,
                        indicatorColor: Colors.black,
                        cursorColor: Colors.black,
                        brightness: Brightness.light,
                        accentColor: Colors.black),
                    debugShowCheckedModeBanner: false,
                    title: 'MiPay',
                    home: StreamBuilder(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (ctx, snapshot) {
                          return FutureBuilder(
                              future: _refreshCards(context),
                              builder: (ctx, snap) {
                                if (snapshot.hasData && snap.data == true && check.checked == true) {
                                  return Manage();
                                }

                                if (snapshot.hasData && snap.data == true && check.checked == false) {
                                 return TimeOutLoginScreen();
                                }

                                if (snapshot.hasData && snap.data == null ) {
                                  return SplashScreen();
                                }

                                if (snapshot.hasData && snap.data == false && check.checked == false) {
                                  return AuthSection(snapshot, snap);
                                }

                                if (!snapshot.hasData && snap.data == null) {
                                  return SplashScreen();
                                }

                                return AuthSection(snapshot, snap);
                              });
                        }),
                    onGenerateRoute: Routes.generateRoute,
                  ),
        ),
      )
    );
  }
}
