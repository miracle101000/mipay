import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/models/transactionInfo.dart';
import '../balance_detail_screen.dart';
import '../transaction_detail_screen.dart';

class BalanceTransaction extends StatefulWidget {
  @override
  _BalanceTransactionState createState() => _BalanceTransactionState();
}

class _BalanceTransactionState extends State<BalanceTransaction>
    with SingleTickerProviderStateMixin {
  int currentMonth, currentYear, dayDigit;
  double totalExpenses = 0.0;
  bool sort = false;
  int chosenMonth;
  int chosenYear;

  @override
  void initState() {
    currentMonth =
        int.tryParse(Timestamp.now().toDate().toString().substring(5, 7));
    currentYear =
        int.tryParse(Timestamp.now().toDate().toString().substring(0, 4));
    dayDigit = int.tryParse(DateTime.now().toString().substring(8, 11));
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool checkNetwork = false;
    FirebaseAuth auth = FirebaseAuth.instance;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser.uid)
          .snapshots(),
      // ignore: missing_return
      builder: (c, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
              child: Center(
                  child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
          )));
        }
        if (snapshot.hasError) {
          checkNetwork = false;
          return Container(
              alignment: Alignment.center,
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Text(
                    'Something went wrong...\n Please check your internet connection and try again',
                    style: TextStyle(color: Colors.black),
                  )),
                  IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          checkNetwork = true;
                        });
                      })
                ],
              ));
        }

        if (!snapshot.hasData) {
          return Container(
              child: Center(
                  child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
          )));
        }
//
        if (snapshot.hasData && snapshot.data != null && checkNetwork == true) {
          var checkIfTransactionsExist = snapshot.data['transactions'].length;
          List<TransactionForBalance> transactions = [];
          for (int i = 0; i < snapshot.data['transactions'].length; i++) {
            transactions.add(TransactionForBalance(
                userName: snapshot.data['transactions'][i]['username'],
                amountSent: snapshot.data['transactions'][i]['amountSent'],
                dateCreated: snapshot.data['transactions'][i]['dateCreated'],
                entity: snapshot.data['transactions'][i]['entity']));
          }
          return checkIfTransactionsExist == 0
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'You have not made any Balance transactions ',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : DefaultTabController(
                  length: 2,
                  child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            backgroundColor: Colors.black,
                            leading: Container(),
                            pinned: false,
                            elevation: 0,
                            forceElevated: false,
                            expandedHeight: 57,
                            title: Container(),
                            floating: false,
                            flexibleSpace: FlexibleSpaceBar(
                              background: Container(
                                color: Colors.black,
                                child: Column(
                                  children: [
                                    TabBar(
                                      indicatorColor: Colors.white,
                                      tabs: [
                                        Tab(
                                          text: 'Sent',
                                          icon: Container(),
                                        ),
                                        Tab(
                                          text: 'Received',
                                          icon: Container(),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ];
                      },
                      body: TabBarView(children: [
                        Container(
                          color: Colors.white,
                          child: transactions
                                      .where((element) =>
                                          element.entity == 'sender' && element.userName != snapshot.data['username'])
                                      .toList()
                                      .length ==
                                  0
                              ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'You have not sent money to anyone',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : CustomScrollView(
                                  slivers: _sliverList(
                                      context,
                                      transactions
                                          .where((element) =>
                                              element.entity == 'sender' && element.userName != snapshot.data['username'])
                                          .toList()
                                          .reversed
                                          .toList(),
                                      'sender'),
                                ),
                        ),
                        Container(
                          color: Colors.white,
                          child: transactions
                                      .where((element) =>
                                          element.entity == 'receiver'&& element.userName != snapshot.data['username'])
                                      .toList()
                                      .length ==
                                  0
                              ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'You have not received money from anyone',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : CustomScrollView(
                                  slivers: _sliverList(
                                      context,
                                      transactions
                                          .where((element) =>
                                              element.entity == 'receiver' && element.userName != snapshot.data['username'])
                                          .toList()
                                          .reversed
                                          .toList(),
                                      'receiver',),
                                ),
                        ),
                      ])),
                );
        }

        if (snapshot.hasData && snapshot.data != null) {
          var checkIfTransactionsExist = snapshot.data['transactions'].length;
          List<TransactionForBalance> transactions = [];
          for (int i = 0; i < snapshot.data['transactions'].length; i++) {
            transactions.add(TransactionForBalance(
                userName: snapshot.data['transactions'][i]['username'],
                amountSent: snapshot.data['transactions'][i]['amountSent'],
                dateCreated: snapshot.data['transactions'][i]['dateCreated'],
                entity: snapshot.data['transactions'][i]['entity']));
          }

          return checkIfTransactionsExist == 0
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'You have not made any Balance transactions ',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : DefaultTabController(
                  length: 2,
                  child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            backgroundColor: Colors.black,
                            leading: Container(),
                            pinned: false,
                            elevation: 0,
//                              snap: true,
                            forceElevated: false,
                            expandedHeight: 57,
                            title: Container(),
                            floating: false,
                            flexibleSpace: FlexibleSpaceBar(
                              background: Container(
                                color: Colors.black,
                                child: Column(
                                  children: [
                                    TabBar(
                                      indicatorColor: Colors.white,
                                      tabs: [
                                        Tab(
                                          text: 'Sent',
                                          icon: Container(),
                                        ),
                                        Tab(
                                          text: 'Received',
                                          icon: Container(),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ];
                      },
                      body: TabBarView(children: [
                        Container(
                          color: Colors.white,
                          child: transactions
                                      .where((element) =>
                                          element.entity == 'sender' && element.userName != snapshot.data['username'])
                                      .toList()
                                      .length ==
                                  0
                              ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'You have not sent money to anyone',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : CustomScrollView(
                                  slivers: _sliverList(
                                      context,
                                      transactions
                                          .where((element) =>
                                              element.entity == 'sender' && element.userName != snapshot.data['username'] )
                                          .toList()
                                          .reversed
                                          .toList(),
                                      'sender'),
                                ),
                        ),
                        Container(
                          color: Colors.white,
                          child: transactions
                                      .where((element) =>
                                          element.entity == 'receiver' && element.userName != snapshot.data['username'] )
                                      .toList()
                                      .length ==
                                  0
                              ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'You have not received money from anyone',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : CustomScrollView(
                                  slivers: _sliverList(
                                      context,
                                      transactions
                                          .where((element) =>
                                              element.entity == 'receiver' && element.userName != snapshot.data['username'])
                                          .toList()
                                          .reversed
                                          .toList(),
                                      'receiver',),
                                ),
                        ),
                      ])),
                );
        }
      },
    );
  }

  List<Widget> _sliverList(
      BuildContext context,
      List<TransactionForBalance> transactions,
      String entity) {
    var widgetList = new List<Widget>();

    var widgetLis = new List<Widget>();

    List expenses = [];
    for (int x = 0; x < 4; x++) {
      for (int y = 0; y < currentMonth; y++) {
        if (currentMonth - y != 0 && currentYear - x == currentYear) {
          var list = transactions
              .where((element) =>
                  element.dateCreated.substring(0, 7) ==
                  '${currentYear - x}-${currentMonth - y}')
              .toList();
          for (int i = 0; i < list.length; i++) {
            totalExpenses += double.tryParse(list
                .where((element) =>
                    element.dateCreated.substring(0, 7) ==
                    '${currentYear - x}-${currentMonth - y}')
                .toList()[i]
                .amountSent);
          }
          expenses.add(Helpers.dp((totalExpenses).toDouble(),2));
          totalExpenses = 0.0;
        }
      }
    }
//    print(expenses);

    for (int x = 0; x < 4; x++) {
      for (int y = 0; y < currentMonth; y++) {
        if (currentMonth - y != 0 && currentYear - x == currentYear) {
          var checkIfTransactionsExist = transactions
              .where((element) =>
                  element.dateCreated.substring(0, 7) ==
                  '${currentYear - x}-${currentMonth - y}')
              .toList()
              .length;
          widgetList.add(checkIfTransactionsExist == 0
              ? SliverStickyHeader()
              : SliverStickyHeader(
                  header: Container(
                    height: 65.0,
                    color: Colors.black,
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                y == 0 && x == 0
                                    ? 'Current Month'
                                    : '${currentYear - x} - ${currentMonth - y}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Icon(
                                Icons.arrow_drop_down_outlined,
                                color: Colors.white,
                              )
                            ],
                          ),
                          Text(
                            'Expenses : ₦${expenses[y]}',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      onTap: () => showBottomShee(
                          context, currentMonth, currentYear, transactions),
                    ),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      var list = transactions
                          .where((element) =>
                              element.dateCreated.substring(0, 7) ==
                              '${currentYear - x}-${currentMonth - y}')
                          .toList();
                      return Container(
                        child: SingleChildScrollView(
                          physics: ScrollPhysics(),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                child: Column(
                                  children: [
                                    index == 0 ? Container() : Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 8),
                                              child: Text(
                                                '${list[index].userName}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 8),
                                              child: Text(
                                                '${entity == 'sender' ? '-' : '+'} ₦${Helpers.dp(double.tryParse(list[index].amountSent), 2)}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 8,
                                              ),
                                              child: Text(
                                                '${dayDigit - int.tryParse(list[index].dateCreated.substring(8, 10)) == 0 && currentMonth == int.tryParse(list[index].dateCreated.substring(5, 7)) && currentYear == int.tryParse(list[index].dateCreated.substring(0, 4)) ? 'Today' : dayDigit - int.tryParse(list[index].dateCreated.substring(8, 10)) == 1 && currentMonth == int.tryParse(list[index].dateCreated.substring(5, 7)) && currentYear == int.tryParse(list[index].dateCreated.substring(0, 4))? 'Yesterday' : DateFormat("EEE, d MMM yyyy").format(DateTime.parse(list[index].dateCreated.substring(0, 10)))}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 8,
                                              ),
                                              child: Text(
                                                '${list[index].dateCreated.substring(11, 16)}',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      BalanceDetailScreen.routeName,
                                      arguments: list[index]);
                                },
                              );
                            },
                          ),
                        ),
                      );
                    }, childCount: 1),
                  ),
                ));
        } else {
          var checkIfTransactionsExist = transactions
              .where((element) =>
                  element.dateCreated.substring(0, 7) ==
                  '${currentYear - x}-${currentMonth - y}')
              .toList()
              .length;
          currentMonth = 12;
          widgetList.add(checkIfTransactionsExist == 0
              ? SliverStickyHeader()
              : SliverStickyHeader(
                  header: Container(
                    height: 60.0,
                    color: Colors.black,
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                y == 0 && x == 0
                                    ? 'Current Month'
                                    : '${currentYear - x} - ${currentMonth - y}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Icon(
                                Icons.arrow_drop_down_outlined,
                                color: Colors.white,
                              )
                            ],
                          ),
                          Text(
                            'Expenses : ₦${expenses[y]}',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      onTap: () => showBottomShee(
                          context, currentMonth, currentYear, transactions),
                    ),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        var list = transactions
                            .where((element) =>
                                element.dateCreated.substring(0, 7) ==
                                '${currentYear - x}-${currentMonth - y}')
                            .toList();
                        return Container(
                          child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: Column(
                                      children: [
                                        index == 0 ? Container() : Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 8),
                                                  child: Text(
                                                    '${list[index].userName}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 8),
                                                  child: Text(
                                                    '${entity == 'sender' ? '-' : '+'} ₦${Helpers.dp(double.tryParse(list[index].amountSent), 2)}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8.0,
                                                    horizontal: 8,
                                                  ),
                                                  child: Text(
                                                      '${DateFormat("EEE, d MMM yyyy HH:mm:ss").format(DateTime.parse(list[index].dateCreated.substring(0, 10) + ' ' + list[index].dateCreated.substring(11, 16)))}'),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8.0,
                                                    horizontal: 8,
                                                  ),
                                                  child: Text(
                                                    '${list[index].dateCreated.substring(11, 16)}',
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          TransactionDetailScreen.routeName,
                                          arguments: list[index]);
                                    },
                                  );
                                }),
                          ),
                        );
                      },
                      childCount: 1,
                    ),
                  ),
                ));
        }
      }
    }

    ///This is used for the sorting
    double chosenDateTotalExpenses = 0;
    var list = transactions
        .where((element) =>
            element.dateCreated.substring(0, 7) == '$chosenYear-$chosenMonth')
        .toList();
    for (int i = 0; i < list.length; i++) {
      chosenDateTotalExpenses += double.tryParse(list
          .where((element) =>
              element.dateCreated.substring(0, 7) == '$chosenYear-$chosenMonth')
          .toList()[i]
          .amountSent);
    }
    widgetLis.add(transactions
                .where((element) =>
                    element.dateCreated.substring(0, 7) ==
                    '$chosenYear-$chosenMonth')
                .toList()
                .length ==
            0
        ? SliverStickyHeader(
            header: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No transactions are available for the selected date',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  GestureDetector(
                    child: Text('Go back'),
                    onTap: () {
                      setState(() {
                        sort = false;
                      });
                    },
                  )
                ],
              ),
            ),
          )
        : SliverStickyHeader(
            header: Container(
              height: 65.0,
              color: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            chosenMonth - currentMonth == 0 &&
                                    chosenYear - currentYear == 0
                                ? 'Current Month'
                                : '$chosenYear-$chosenMonth',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Colors.white,
                          )
                        ],
                      ),
                      Text(
                        'Expenses : ₦${Helpers.dp(chosenDateTotalExpenses / 100,2)}',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        sort = false;
                      });
                    },
                  )
                ],
              ),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                var list = transactions
                    .where((element) =>
                        element.dateCreated.substring(0, 7) ==
                        '$chosenYear-$chosenMonth')
                    .toList();
                return Container(
                  child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        print(list[index].dateCreated.substring(8, 10));
                        return GestureDetector(
                          child: Column(
                            children: [
                              index == 0 ? Container() : Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 8),
                                        child: Text(
                                          '${list[index].userName}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 8),
                                        child: Text(
                                          '${entity == 'sender' ? '-' : '+'} ₦${Helpers.dp(double.tryParse(list[index].amountSent), 2)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          '${dayDigit - int.tryParse(list[index].dateCreated.substring(8, 10)) == 0 && currentMonth == int.tryParse(list[index].dateCreated.substring(5, 7)) && currentYear == int.tryParse(list[index].dateCreated.substring(0, 4))? 'Today' : dayDigit - int.tryParse(list[index].dateCreated.substring(8, 10)) == 1 && currentMonth == int.tryParse(list[index].dateCreated.substring(5, 7)) && currentYear == int.tryParse(list[index].dateCreated.substring(0, 4)) ? 'Yesterday' : DateFormat("EEE, d MMM yyyy").format(DateTime.parse(list[index].dateCreated.substring(0, 10)))}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          '${list[index].dateCreated.substring(11, 16)}',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                TransactionDetailScreen.routeName,
                                arguments: list[index]);
                          },
                        );
                      },
                    ),
                  ),
                );
              }, childCount: 1),
            ),
          ));

    return sort == true ? widgetLis : widgetList;
  }

  void showBottomShee(BuildContext context, int currentMonth, int currentYear,
      var loadedTransactions) {
    Widget selectedMonth = Text('$currentMonth');
    Widget selectedYear = Text('$currentYear');

    List<Widget> years = [Text('$currentYear')];
    List<Widget> months = [Text('$currentMonth')];
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          for (int x = 1; x < 10; x++) {
            years.add(Text('${currentYear - x}'));
          }
          for (int y = 1; y < currentMonth; y++) {
            months.add(Text('${currentMonth - y}'));
          }
          return Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              children: [
                Container(
                  height: 50,
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Done',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            sort = true;
                            chosenMonth = int.tryParse(
                                selectedMonth.toString().substring(6, 8));
                            chosenYear = int.tryParse(
                                selectedYear.toString().substring(6, 10));
                          });
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          looping: true,
                          itemExtent: 25,
                          onSelectedItemChanged: (int value) {
                            selectedYear = years[value];
                          },
                          children: years,
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 25,
                          looping: true,
                          onSelectedItemChanged: (int value) {
                            selectedMonth = months[value];
                          },
                          children: months,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

}
