import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_bloc.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_state.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_event.dart';
import 'package:cost_averaging_trading_app/features/settings/ui/widgets/api_settings.dart';
import 'package:cost_averaging_trading_app/features/settings/ui/widgets/backtesting_settings.dart';
import 'package:cost_averaging_trading_app/features/settings/ui/widgets/demo_mode_toggle.dart';
import 'package:cost_averaging_trading_app/features/settings/ui/widgets/risk_management.dart';
import 'package:cost_averaging_trading_app/ui/layouts/custom_page_layout.dart';

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
        return CustomPageLayout(
          title: 'Settings',
          useSliver: false,
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 16),
            _buildApiSettings(context, state),
            const SizedBox(height: 16),
            _buildDemoModeToggle(context, state),
            const SizedBox(height: 16),
            _buildBacktestingSettings(context, state),
            const SizedBox(height: 16),
            _buildRiskManagement(context, state),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Search settings...',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // Implement search functionality
          },
        ),
      ),
    );
  }

  Widget _buildApiSettings(BuildContext context, SettingsState state) {
    if (state is SettingsLoaded) {
      return ApiSettings(
        apiKey: state.apiKey,
        secretKey: state.secretKey,
        onApiKeyChanged: (newKey) {
          context.read<SettingsBloc>().add(UpdateApiKey(newKey));
        },
        onSecretKeyChanged: (newKey) {
          context.read<SettingsBloc>().add(UpdateSecretKey(newKey));
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDemoModeToggle(BuildContext context, SettingsState state) {
    if (state is SettingsLoaded) {
      return DemoModeToggle(
        isDemoMode: state.isDemoMode,
        onToggle: (isDemo) {
          context.read<SettingsBloc>().add(ToggleDemoMode());
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBacktestingSettings(BuildContext context, SettingsState state) {
    if (state is SettingsLoaded) {
      return BacktestingSettings(
        isBacktestingEnabled: state.isBacktestingEnabled,
        onToggleBacktesting: () {
          context.read<SettingsBloc>().add(ToggleBacktesting());
        },
        onRunBacktest: () {
          // Implement backtesting logic
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRiskManagement(BuildContext context, SettingsState state) {
    if (state is SettingsLoaded) {
      return RiskManagement(
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
      );
    }
    return const SizedBox.shrink();
  }
}
