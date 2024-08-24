// lib/features/trade_history/ui/pages/trade_history_page.dart

import 'package:cost_averaging_trading_app/features/trade_history/ui/widgets/trade_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_bloc.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_state.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_event.dart';
import 'package:cost_averaging_trading_app/features/trade_history/ui/widgets/trade_filters.dart';
import 'package:cost_averaging_trading_app/features/trade_history/ui/widgets/trade_list.dart';

class TradeHistoryPage extends StatelessWidget {
  const TradeHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradeHistoryBloc, TradeHistoryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trade History',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  _buildTradeHistoryContent(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTradeHistoryContent(
      BuildContext context, TradeHistoryState state) {
    // ... [il resto del codice rimane invariato]
    if (state is TradeHistoryLoaded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildTile(constraints, TradeFilters(
                onFilterApplied: (startDate, endDate, assetPair) {
                  context.read<TradeHistoryBloc>().add(FilterTradeHistory(
                        startDate: startDate,
                        endDate: endDate,
                        assetPair: assetPair,
                      ));
                },
              )),
              _buildTile(constraints, TradeStats(stats: state.statistics)),
              _buildTile(constraints, TradeList(trades: state.trades)),
              _buildPagination(context, state),
            ],
          );
        },
      );
    } else if (state is TradeHistoryError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    return const Center(child: Text('Unknown state'));
  }

  Widget _buildTile(BoxConstraints constraints, Widget child) {
    double width = constraints.maxWidth > 600
        ? (constraints.maxWidth - 16) / 2
        : constraints.maxWidth;
    return SizedBox(
      width: width,
      child: child,
    );
  }

  Widget _buildPagination(BuildContext context, TradeHistoryLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: state.currentPage > 1
              ? () => context
                  .read<TradeHistoryBloc>()
                  .add(ChangePage(state.currentPage - 1))
              : null,
        ),
        Text('Page ${state.currentPage}'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: state.currentPage < state.totalPages
              ? () => context
                  .read<TradeHistoryBloc>()
                  .add(ChangePage(state.currentPage + 1))
              : null,
        ),
      ],
    );
  }
}
