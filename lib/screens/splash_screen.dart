import 'package:flutter/material.dart';


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Text('MiPay...',style: TextStyle(fontSize: 30,color: Colors.black,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }
}