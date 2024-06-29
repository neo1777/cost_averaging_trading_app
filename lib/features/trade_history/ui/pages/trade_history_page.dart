// lib/features/trade_history/ui/pages/trade_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/widgets/shared_widgets.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_bloc.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_state.dart';
import 'package:cost_averaging_trading_app/features/trade_history/blocs/trade_history_event.dart';
import 'package:cost_averaging_trading_app/features/trade_history/ui/widgets/trade_list.dart';
import 'package:cost_averaging_trading_app/features/trade_history/ui/widgets/trade_filters.dart';
import 'package:cost_averaging_trading_app/features/trade_history/ui/widgets/trade_stats.dart';
import 'package:cost_averaging_trading_app/ui/widgets/responsive_text.dart';

class TradeHistoryPage extends StatelessWidget {
  const TradeHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradeHistoryBloc, TradeHistoryState>(
      builder: (context, state) {
        if (state is TradeHistoryInitial || state is TradeHistoryLoading) {
          return const LoadingIndicator(message: 'Loading trade history...');
        } else if (state is TradeHistoryLoaded) {
          return _buildLoadedContent(context, state);
        } else if (state is TradeHistoryError) {
          return ErrorMessage(message: state.message);
        }
        return const ErrorMessage(message: 'Unknown state');
      },
    );
  }

  Widget _buildLoadedContent(BuildContext context, TradeHistoryLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildWideLayout(context, state);
        } else {
          return _buildNarrowLayout(context, state);
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context, TradeHistoryLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Trade History',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      CustomCard(
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
                      const SizedBox(height: 16),
                      CustomCard(
                        child: TradeStats(stats: state.statistics),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: CustomCard(
                    child: TradeList(trades: state.trades),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, TradeHistoryLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Trade History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            CustomCard(
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
            const SizedBox(height: 16),
            CustomCard(
              child: TradeStats(stats: state.statistics),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: TradeList(trades: state.trades),
            ),
          ],
        ),
      ),
    );
  }
}
