import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/widgets/card_design.dart';



class BankCard extends StatefulWidget {
  @override
  _BankCardState createState() => _BankCardState();
}

class _BankCardState extends State<BankCard> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          color: Color(0xFFF9F9F9),
          height: height,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.05, left: 10),
                    child: Center(
                        child: Text(
                          'Bank Cards',
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
              SizedBox(
                height: 8,
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .snapshots(),
                  builder: (ctx, cardsSnapshot) {
                    if (cardsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.black),
                      ));
                    }
                    final cardsDocs = cardsSnapshot.data['cards'];
                    return cardsDocs.length == 0
                        ? Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'You do not have any bank cards',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.all(8),
                            child: Container(
                              child: ListView.builder(
                                  itemCount: cardsDocs.length,
                                  itemBuilder: (_, index) {
                                    return Dismissible(
                                      key:
                                          Key(cardsDocs[index]['cardNumber']),
                                      background: Container(
                                        margin: EdgeInsets.only(bottom: 20),
                                        alignment: AlignmentDirectional.centerEnd,
                                        color: Colors.red,
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                          child: Icon(Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 20),
                                        child: CardDesign(
                                          cardNumber: cardsDocs[index]
                                              ['cardNumber'],
                                          cardForm: cardsDocs[index]
                                              ['cardForm'],
                                          cardType: cardsDocs[index]
                                              ['cardType'],
                                          cvv: cardsDocs[index]['cvv'],
                                          bankName: cardsDocs[index]
                                              ['bankName'],
                                        ),
                                      ),
                                      onDismissed: (direction) async {
                                        Helpers.showMessage('Card Deleted',_scaffoldKey);
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(auth.currentUser.uid)
                                              .update({
                                            'cards': FieldValue.arrayRemove(
                                                [cardsDocs[index]])
                                          });
                                        }catch(error){
                                          print(error);
                                        }
                                      },
                                    );
                                  }),
                            ));
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0,left: 8,right: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.add),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Add Bank Card'),
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push(Helpers.createRouteAddBankCard());
          },
        ),
      ),
    );
  }


}
