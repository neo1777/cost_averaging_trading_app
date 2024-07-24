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
import 'package:cost_averaging_trading_app/ui/layouts/custom_page_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
        return CustomPageLayout(
          title: 'Settings',
          useSliver: false, // Using standard layout for settings
          children: _buildSettingsContent(context, state),
        );
      },
    );
  }

  List<Widget> _buildSettingsContent(
      BuildContext context, SettingsState state) {
    if (state is SettingsLoading) {
      return [const Center(child: CircularProgressIndicator())];
    } else if (state is SettingsLoaded) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DemoModeToggle(
              isDemoMode: state.isDemoMode,
              onToggle: (isDemo) {
                context.read<SettingsBloc>().add(ToggleDemoMode());
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BacktestingSettings(
              isBacktestingEnabled: state.isBacktestingEnabled,
              onToggleBacktesting: () {
                context.read<SettingsBloc>().add(ToggleBacktesting());
              },
              onRunBacktest: () {
                // Implement backtesting logic
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
        ),
      ];
    } else if (state is SettingsError) {
      return [Center(child: Text('Error: ${state.message}'))];
    }
    return [const Center(child: Text('Unknown state'))];
  }
}
