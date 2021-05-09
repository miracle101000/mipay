import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/providers/withdrawals.dart';
import 'package:provider/provider.dart';

import '../transaction_detail_screen.dart';


class WithdrawalTransactions extends StatefulWidget {
  @override
  _WithdrawalTransactionsState createState() => _WithdrawalTransactionsState();
}

class _WithdrawalTransactionsState extends State<WithdrawalTransactions> {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool checkNetwork = false;
    return FutureBuilder(
      future:
          Provider.of<Withdrawals>(context, listen: false).fetchWithdrawals(),
      builder: (c, snapshot) {
        print(snapshot.data);
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

        if (checkNetwork == true) {
          return snapshot.data.length == 0
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'You have not made any Withdrawals',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: _sliverList(context, snapshot.data),
                );
        }
        return snapshot.data.length == 0
            ? Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You have not made any Withdrawals',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: _sliverList(context, snapshot.data),
              );
      },
    );
  }

  List<Widget> _sliverList(BuildContext context, List withdrawals) {
    var widgetList = new List<Widget>();

    var widgetLis = new List<Widget>();

    FirebaseAuth auth = FirebaseAuth.instance;

    List expenses = [];
    for (int x = 0; x < 4; x++) {
      for (int y = 0; y < currentMonth; y++) {
        if (currentMonth - y != 0 && currentYear - x == currentYear) {
          var list = withdrawals
              .where((element) =>
                  element.time.substring(0, 7) ==
                      '${currentYear - x}-${currentMonth - y}' &&
                  element.email == auth.currentUser.email)
              .toList();
          for (int i = 0; i < list.length; i++) {
            totalExpenses += list
                .where((element) =>
                    element.time.substring(0, 7) ==
                        '${currentYear - x}-${currentMonth - y}' &&
                    element.email == auth.currentUser.email)
                .toList()[i]
                .amount;
          }
          expenses.add((totalExpenses / 100).toDouble());
          totalExpenses = 0.0;
        }
      }
    }

    for (int x = 0; x < 4; x++) {
      for (int y = 0; y < currentMonth; y++) {
        if (currentMonth - y != 0 && currentYear - x == currentYear) {
          var checkIfTransactionsExist = withdrawals
              .where((element) =>
                  element.time.substring(0, 7) ==
                      '${currentYear - x}-${currentMonth - y}' &&
                  element.email == auth.currentUser.email)
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
                          context, currentMonth, currentYear, withdrawals),
                    ),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      var list = withdrawals
                          .where((element) =>
                              element.time.substring(0, 7) ==
                                  '${currentYear - x}-${currentMonth - y}' &&
                              element.email == auth.currentUser.email)
                          .toList();
                      return Container(
                        child: SingleChildScrollView(
                          physics: ScrollPhysics(),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              print(list[index].time.substring(8, 10));
                              return GestureDetector(
                                child: Column(
                                  children: [
                                    index == 0 ? Container() : Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14.0, horizontal: 8),
                                          child: Text(
                                            '+ ₦${Helpers.dp(list[index].amount.toDouble() / 100, 2)}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
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
                                                '${dayDigit - int.tryParse(list[index].time.substring(8, 10)) == 0 && currentMonth == int.tryParse(list[index].time.substring(5, 7)) && currentYear == int.tryParse(list[index].time.substring(0, 4)) ? 'Today' : dayDigit - int.tryParse(list[index].time.substring(8, 10)) == 1 && currentMonth == int.tryParse(list[index].time.substring(5, 7)) && currentYear == int.tryParse(list[index].time.substring(0, 4)) ? 'Yesterday' : DateFormat("EEE, d MMM yyyy").format(DateTime.parse(list[index].time.substring(0, 10)))}',
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
                                                '${list[index].time.substring(11, 16)}',
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
                            },
                          ),
                        ),
                      );
                    }, childCount: 1),
                  ),
                ));
        } else {
          var checkIfTransactionsExist = withdrawals
              .where((element) =>
                  element.time.substring(0, 7) ==
                      '${currentYear - x}-${currentMonth - y}' &&
                  element.email == auth.currentUser.email)
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
                          context, currentMonth, currentYear, withdrawals),
                    ),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        var list = withdrawals
                            .where((element) =>
                                element.time.substring(0, 7) ==
                                    '${currentYear - x}-${currentMonth - y}' &&
                                element.email == auth.currentUser.email)
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
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14.0,
                                                      horizontal: 8),
                                              child: Text(
                                                  '+ ₦${Helpers.dp(list[index].amount.toDouble() / 100, 2)}'),
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
                                                      '${DateFormat("EEE, d MMM yyyy HH:mm:ss").format(DateTime.parse(list[index].time.substring(0, 10) + ' ' + list[index].time.substring(11, 16)))}'),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8.0,
                                                    horizontal: 8,
                                                  ),
                                                  child: Text(
                                                    '${list[index].time.substring(11, 16)}',
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
    var list = withdrawals
        .where((element) =>
            element.time.substring(0, 7) == '$chosenYear-$chosenMonth' &&
            element.email == auth.currentUser.email)
        .toList();
    for (int i = 0; i < list.length; i++) {
      chosenDateTotalExpenses += list
          .where((element) =>
              element.time.substring(0, 7) == '$chosenYear-$chosenMonth' &&
              element.email == auth.currentUser.email)
          .toList()[i]
          .amount;
    }
    widgetLis.add(withdrawals
                .where((element) =>
                    element.time.substring(0, 7) ==
                        '$chosenYear-$chosenMonth' &&
                    element.email == auth.currentUser.email)
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
                        'Expenses : ₦${chosenDateTotalExpenses / 100}',
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
                var list = withdrawals
                    .where((element) =>
                        element.time.substring(0, 7) ==
                            '$chosenYear-$chosenMonth' &&
                        element.email == auth.currentUser.email)
                    .toList();
                return Container(
                  child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        print(list[index].time.substring(8, 10));
                        return GestureDetector(
                          child: Column(
                            children: [
                              index == 0 ? Container() : Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14.0, horizontal: 8),
                                    child: Text(
                                      '+ ₦${Helpers.dp(list[index].amount.toDouble() / 100, 2)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
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
                                          '${dayDigit - int.tryParse(list[index].time.substring(8, 10)) == 0 && currentMonth == int.tryParse(list[index].time.substring(5, 7)) && currentYear == int.tryParse(list[index].time.substring(0, 4)) ? 'Today' : dayDigit - int.tryParse(list[index].time.substring(8, 10)) == 1 && currentMonth == int.tryParse(list[index].time.substring(5, 7)) && currentYear == int.tryParse(list[index].time.substring(0, 4)) ? 'Yesterday' : DateFormat("EEE, d MMM yyyy").format(DateTime.parse(list[index].time.substring(0, 10)))}',
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
                                          '${list[index].time.substring(11, 16)}',
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
