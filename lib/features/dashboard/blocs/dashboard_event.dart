abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {}

class LoadMoreTrades extends DashboardEvent {}

class ChangeTradesPerPage extends DashboardEvent {
  final int tradesPerPage;

  ChangeTradesPerPage(this.tradesPerPage);
}