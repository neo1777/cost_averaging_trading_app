abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {}

class ChangePage extends DashboardEvent {
  final int newPage;

  ChangePage(this.newPage);
}

class ChangeTradesPerPage extends DashboardEvent {
  final int tradesPerPage;

  ChangeTradesPerPage(this.tradesPerPage);
}

class ChangeSymbol extends DashboardEvent {
  final String symbol;

  ChangeSymbol(this.symbol);

  List<Object> get props => [symbol];
}
