abstract class TradeHistoryEvent {}

class LoadTradeHistory extends TradeHistoryEvent {}

class FilterTradeHistory extends TradeHistoryEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? assetPair;

  FilterTradeHistory({this.startDate, this.endDate, this.assetPair});
}

class ChangePage extends TradeHistoryEvent {
  final int pageNumber;

  ChangePage(this.pageNumber);
}
