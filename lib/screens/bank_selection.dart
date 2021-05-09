import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mi_pay/config/helpers.dart';


typedef void ListCallback(List<int> val);

// ignore: must_be_immutable
class BankSelection extends StatefulWidget {
  ListCallback callback;

  BankSelection({this.callback});

  @override
  _BankSelectionState createState() => _BankSelectionState();
}

class _BankSelectionState extends State<BankSelection> {

  List<int> _selectedItems = [];
  List<int> selectItem = [];
  FirebaseAuth auth = FirebaseAuth.instance;



  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
              SizedBox(
                width: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                    child: Text(
                  'Select Payment Method',
                  style: TextStyle(fontSize: 16),
                )),
              ),
            ],
          ),
          Divider(),
          Expanded(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users').doc(auth.currentUser.uid)
                            .snapshots(),
                        builder: (ctx, cardsSnapshot) {
                          if (cardsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.black),
                            ));
                          }
                          final cardsDocs =
                              cardsSnapshot.data['cards'];
                          if (cardsDocs != null) {
                            for (int i = 0; i < cardsDocs.length; i++) {
                              _selectedItems.add(i);
                            }
                            print(_selectedItems.toSet().toList());
                          }
                          return Padding(
                            padding: EdgeInsets.all(8),
                            child: cardsDocs.isEmpty == true
                                ? Container(
                                    child: Center(
                                    child: Text(
                                      'Add a Payment Method',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ))
                                : ListView.builder(
                                    itemCount: cardsDocs.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                child: cardsDocs[index][
                                                'cardType'] ==
                                                    'Visa'
                                                    ? Image.network(
                                                    'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/viasacard.png?alt=media&token=4f4ec102-54bd-4aeb-8b4e-74505bfba8db')
                                                    : cardsDocs[index]['cardType'] ==
                                                    'MasterCard'
                                                    ? Image.network(
                                                    'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/mastrcard.png?alt=media&token=e4ea1367-0740-4e96-a500-be0995955a76')
                                                    : cardsDocs[index]['cardType'] ==
                                                    'American Express'
                                                    ? Image.network(
                                                    'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/americanexp.png?alt=media&token=75c43624-071a-43fb-96e4-427a4a6e660c')
                                                    : cardsDocs[index]['cardType'] ==
                                                    'Diners Club'
                                                    ? Image.network(
                                                    'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/dinersclub.png?alt=media&token=e2c6c846-f083-4c94-82e6-ae4a5b0798ee')
                                                    : cardsDocs[index]['cardType'] ==
                                                    'Discover'
                                                    ? Image.network(
                                                    'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/discover.png?alt=media&token=1a13524b-f9dc-4952-bb0c-046581b9f162')
                                                    : cardsDocs[index]['cardType'] ==
                                                    'JCB'
                                                    ? Image.network('https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/jcb.png?alt=media&token=14291f65-3d6e-4bdc-9c3e-ca7ffbc07536')
                                                    : cardsDocs[index]['cardType'] == 'VERVE'
                                                    ? Image.network('https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/verve.png?alt=media&token=8c3a45fa-c919-4cb6-ad11-4576eb3e48da')
                                                    : Container(),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  top: 8.0,
                                                  bottom: 4),
                                              child: Text(
                                                ' ${cardsDocs[index]['cardType']} ${cardsDocs[index]['cardForm']}...${cardsDocs[index]['cardNumber'].substring(cardsDocs[index]['cardNumber'].length - 4)}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            if (_selectedItems != null)
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: cardsSnapshot.data

                                                                      [
                                                                      'selectedCard']
                                                                  [
                                                                  'selectedIndex']  ==
                                                              index && cardsSnapshot.data != null
                                                          ? Icon(Icons.check)
                                                          : Container(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        onTap: () async {
                                          print(index);
                                          Navigator.of(context).pop();
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(auth.currentUser.uid)
                                              .update({
                                            'selectedCard': {
                                              'cardNumber': cardsDocs[index]
                                                  ['cardNumber'],
                                              'cardForm': cardsDocs[index]
                                                  ['cardForm'],
                                              'cardType': cardsDocs[index]
                                                  ['cardType'],
                                              'cvv': cardsDocs[index]['cvv'],
                                              'bankName': cardsDocs[index]
                                                  ['bankName'],
                                              'expiryMonth': cardsDocs[index]
                                                  ['expiryMonth'],
                                              'expiryYear': cardsDocs[index]
                                                  ['expiryYear'],
                                              'selectedIndex': index,
                                            }
                                          });
                                        },
                                      );
                                    }),
                          );
                        }),
                  ),
          Divider(),
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Icon(Icons.add),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Add Bank Card'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(Helpers.createRouteAddBankCard());
            },
          ),
        ],
      ),
    );
  }

}
