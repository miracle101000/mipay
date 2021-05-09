import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CardDesign extends StatelessWidget {
   String cardNumber;

   String cardForm;
   String bankName;
   String cvv;
   String cardType;

  CardDesign({
    Key key,
    this.cardNumber,
    this.cardForm,
    this.bankName = "",
    this.cvv,
    this.cardType,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Color color = cardType == 'Visa'
        ? Colors.blueGrey
        : cardType == 'MasterCard'
            ? Colors.black
            : cardType == 'American Express'
                ? Colors.indigo
                : cardType == 'Diners Club'
                    ? Colors.purple
                    : cardType == 'Discover'
                        ? Colors.deepOrange
                        : cardType == 'JCB'
                            ? Colors.brown
                            : cardType == 'VERVE'
                                ? Colors.blue
                                : Colors.black;
    return Card(
      shadowColor: color,
      elevation: 5,
      child: Container(
        decoration:
            BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(5)),
//        margin: EdgeInsets.symmetric(horizontal: 10),
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$bankName $cardForm Card',
                            overflow: TextOverflow.clip,
                            softWrap: true,
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Transfer,check bills',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '****${cardNumber.substring(cardNumber.length - 4)}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.transparent,
                        child: cardType ==
                            'Visa'
                            ? Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/viasacard.png?alt=media&token=4f4ec102-54bd-4aeb-8b4e-74505bfba8db')
                            : cardType ==
                            'MasterCard'
                            ? Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/mastrcard.png?alt=media&token=e4ea1367-0740-4e96-a500-be0995955a76')
                            : cardType ==
                            'American Express'
                            ? Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/americanexp.png?alt=media&token=75c43624-071a-43fb-96e4-427a4a6e660c')
                            : cardType ==
                            'Diners Club'
                            ? Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/dinersclub.png?alt=media&token=e2c6c846-f083-4c94-82e6-ae4a5b0798ee')
                            : cardType ==
                            'Discover'
                            ? Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/discover.png?alt=media&token=1a13524b-f9dc-4952-bb0c-046581b9f162')
                            : cardType ==
                            'JCB'
                            ? Image.network('https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/jcb.png?alt=media&token=14291f65-3d6e-4bdc-9c3e-ca7ffbc07536')
                            : cardType == 'VERVE'
                            ? Image.network('https://firebasestorage.googleapis.com/v0/b/payapp-4804d.appspot.com/o/verve.png?alt=media&token=8c3a45fa-c919-4cb6-ad11-4576eb3e48da')
                            : Container(),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
