class TransactionForBalance {
  String userName;
  String amountSent;
  String dateCreated;
  String entity;

  TransactionForBalance(
      {this.userName, this.amountSent, this.dateCreated, this.entity});

  static List<Map> convertTransactionToMap(
      {List<TransactionForBalance> transactions}) {
    List<Map> cards = [];
    transactions.forEach((TransactionForBalance cardInfo) {
      Map card = cardInfo.tMap();
      cards.add(card);
    });
    return cards;
  }

  Map<String, dynamic> tMap() => {
        'username': userName,
        'amountSent': amountSent,
        'dateCreated': dateCreated,
        'entity': entity,
      };
}
