import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_bloc.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_state.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_event.dart';
import 'package:cost_averaging_trading_app/features/trade_history/ui/widgets/trade_list.dart';
import 'package:cost_averaging_trading_app/features/trade_history/ui/widgets/trade_filters.dart';
import 'package:cost_averaging_trading_app/features/trade_history/ui/widgets/trade_stats.dart';
import 'package:cost_averaging_trading_app/ui/layouts/custom_page_layout.dart';

class TradeHistoryPage extends StatelessWidget {
  const TradeHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradeHistoryBloc, TradeHistoryState>(
      builder: (context, state) {
        return CustomPageLayout(
          title: 'Trade History',
          useSliver: true,
          children: _buildTradeHistoryContent(context, state),
        );
      },
    );
  }

  List<Widget> _buildTradeHistoryContent(
      BuildContext context, TradeHistoryState state) {
    if (state is TradeHistoryInitial) {
      context.read<TradeHistoryBloc>().add(LoadTradeHistory());
      return [const Center(child: CircularProgressIndicator())];
    } else if (state is TradeHistoryLoading) {
      return [const Center(child: CircularProgressIndicator())];
    } else if (state is TradeHistoryLoaded) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TradeFilters(
              onFilterApplied: (startDate, endDate, assetPair) {
                context.read<TradeHistoryBloc>().add(
                      FilterTradeHistory(
                        startDate: startDate,
                        endDate: endDate,
                        assetPair: assetPair,
                      ),
                    );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TradeStats(stats: state.statistics),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TradeList(trades: state.trades),
          ),
        ),
      ];
    } else if (state is TradeHistoryError) {
      return [Center(child: Text('Error: ${state.message}'))];
    }
    return [const Center(child: Text('Unknown state'))];
  }
}
