
import 'package:flutter/material.dart';
import 'package:mi_pay/screens/add_bank_card.dart';
import 'package:mi_pay/screens/balance_detail_screen.dart';
import 'package:mi_pay/screens/send_money.dart';
import 'package:mi_pay/screens/top_up_page.dart';
import 'package:mi_pay/screens/transaction_detail_screen.dart';
import 'package:mi_pay/screens/transaction_screen.dart';
import 'package:mi_pay/screens/withdraw_page.dart';
import '../settings.dart';
import '../terms_and_condition.dart';


class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Setting.routeName:
        var data = settings.arguments;
        return MaterialPageRoute(builder: (_) => Setting(data));
      case TopUp.routeName:
        var data = settings.arguments;
        return MaterialPageRoute(builder: (_) => TopUp(data));
      case TransactionScreen.routeName:
        var data = settings.arguments;
        return MaterialPageRoute(builder: (_) => TransactionScreen(data));
      case TransactionDetailScreen.routeName:
        var data = settings.arguments;
        return MaterialPageRoute(builder: (_) => TransactionDetailScreen(data));
      case BalanceDetailScreen.routeName:
        var data = settings.arguments;
        return MaterialPageRoute(builder: (_) => BalanceDetailScreen(data));
      case SendMoney.routeName:
        var data = settings.arguments;
        return MaterialPageRoute(builder: (_) => SendMoney(data));
      case Withdraw.routeName:
        var data = settings.arguments;
        return MaterialPageRoute(builder: (_) => Withdraw(data));
      case TermsAndCondition.routeName:
        return MaterialPageRoute(builder: (_) => TermsAndCondition());
      case AddBankCard.routeName:
//        var data = settings.arguments;
        return MaterialPageRoute(builder: (_) => AddBankCard());
      default:
        return null;
    }
  }
}
