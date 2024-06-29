import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/core/widgets/shared_widgets.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_bloc.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_event.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_state.dart';
import 'package:cost_averaging_trading_app/features/settings/ui/widgets/api_settings.dart';
import 'package:cost_averaging_trading_app/features/settings/ui/widgets/backtesting_settings.dart';
import 'package:cost_averaging_trading_app/features/settings/ui/widgets/demo_mode_toggle.dart';
import 'package:cost_averaging_trading_app/features/settings/ui/widgets/risk_management.dart';
import 'package:cost_averaging_trading_app/ui/widgets/responsive_text.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const LoadingIndicator(message: 'Loading settings...');
        } else if (state is SettingsLoaded) {
          return _buildSettingsContent(context, state);
        } else if (state is SettingsError) {
          return ErrorMessage(message: state.message);
        }
        return const ErrorMessage(message: 'Unknown state');
      },
    );
  }

  Widget _buildSettingsContent(BuildContext context, SettingsLoaded state) {
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

  Widget _buildWideLayout(BuildContext context, SettingsLoaded state) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    CustomCard(
                      child: ApiSettings(
                        apiKey: state.apiKey,
                        secretKey: state.secretKey,
                        onApiKeyChanged: (newKey) {
                          context
                              .read<SettingsBloc>()
                              .add(UpdateApiKey(newKey));
                        },
                        onSecretKeyChanged: (newKey) {
                          context
                              .read<SettingsBloc>()
                              .add(UpdateSecretKey(newKey));
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomCard(
                      child: DemoModeToggle(
                        isDemoMode: state.isDemoMode,
                        onToggle: (isDemo) {
                          context.read<SettingsBloc>().add(ToggleDemoMode());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    CustomCard(
                      child: BacktestingSettings(
                        isBacktestingEnabled: state.isBacktestingEnabled,
                        onToggleBacktesting: () {
                          context.read<SettingsBloc>().add(ToggleBacktesting());
                        },
                        onRunBacktest: () {
                          // Implementare la logica per eseguire il backtesting
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomCard(
                      child: RiskManagement(
                        maxLossPercentage: state.maxLossPercentage,
                        maxConcurrentTrades: state.maxConcurrentTrades,
                        maxPositionSizePercentage:
                            state.maxPositionSizePercentage,
                        dailyExposureLimit: state.dailyExposureLimit,
                        maxAllowedVolatility: state.maxAllowedVolatility,
                        maxRebuyCount: state.maxRebuyCount,
                        onUpdateRiskManagement: (
                          maxLoss,
                          maxTrades,
                          maxPositionSize,
                          dailyExposure,
                          maxVolatility,
                          rebuyCount,
                        ) {
                          context.read<SettingsBloc>().add(UpdateRiskManagement(
                                maxLoss,
                                maxTrades,
                                maxPositionSize,
                                dailyExposure,
                                maxVolatility,
                                rebuyCount,
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildNarrowLayout(BuildContext context, SettingsLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: ApiSettings(
                apiKey: state.apiKey,
                secretKey: state.secretKey,
                onApiKeyChanged: (newKey) {
                  context.read<SettingsBloc>().add(UpdateApiKey(newKey));
                },
                onSecretKeyChanged: (newKey) {
                  context.read<SettingsBloc>().add(UpdateSecretKey(newKey));
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: DemoModeToggle(
                isDemoMode: state.isDemoMode,
                onToggle: (isDemo) {
                  context.read<SettingsBloc>().add(ToggleDemoMode());
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: BacktestingSettings(
                isBacktestingEnabled: state.isBacktestingEnabled,
                onToggleBacktesting: () {
                  context.read<SettingsBloc>().add(ToggleBacktesting());
                },
                onRunBacktest: () {
                  // Implementare la logica per eseguire il backtesting
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: RiskManagement(
                maxLossPercentage: state.maxLossPercentage,
                maxConcurrentTrades: state.maxConcurrentTrades,
                maxPositionSizePercentage: state.maxPositionSizePercentage,
                dailyExposureLimit: state.dailyExposureLimit,
                maxAllowedVolatility: state.maxAllowedVolatility,
                maxRebuyCount: state.maxRebuyCount,
                onUpdateRiskManagement: (
                  maxLoss,
                  maxTrades,
                  maxPositionSize,
                  dailyExposure,
                  maxVolatility,
                  rebuyCount,
                ) {
                  context.read<SettingsBloc>().add(UpdateRiskManagement(
                        maxLoss,
                        maxTrades,
                        maxPositionSize,
                        dailyExposure,
                        maxVolatility,
                        rebuyCount,
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
