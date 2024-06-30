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
