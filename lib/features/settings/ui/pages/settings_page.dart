// lib/features/settings/ui/pages/settings_page.dart

import 'package:cost_averaging_trading_app/features/settings/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_bloc.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_state.dart';
import 'package:cost_averaging_trading_app/features/settings/blocs/settings_event.dart';
import 'package:cost_averaging_trading_app/features/settings/ui/widgets/api_settings.dart';
import 'package:cost_averaging_trading_app/features/settings/ui/widgets/advanced_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(
        RepositoryProvider.of<SettingsRepository>(context),
      )..add(LoadSettings()),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Settings',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    _buildSettingsContent(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, SettingsState state) {
    if (state is SettingsLoaded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildTile(
                  constraints,
                  ApiSettings(
                    apiKey: state.apiKey,
                    secretKey: state.secretKey,
                    onApiKeyChanged: (newKey) {
                      context.read<SettingsBloc>().add(UpdateApiKey(newKey));
                    },
                    onSecretKeyChanged: (newKey) {
                      context.read<SettingsBloc>().add(UpdateSecretKey(newKey));
                    },
                  )),
              _buildTile(
                  constraints,
                  AdvancedSettings(
                    isAdvancedMode: state.isAdvancedMode,
                    onToggleAdvancedMode: () {
                      context.read<SettingsBloc>().add(ToggleAdvancedMode());
                    },
                    riskManagementSettings: state.isAdvancedMode
                        ? state.riskManagementSettings
                        : null,
                    onUpdateRiskManagement: state.isAdvancedMode
                        ? (settings) {
                            context
                                .read<SettingsBloc>()
                                .add(UpdateRiskManagement(settings));
                          }
                        : null,
                  )),
            ],
          );
        },
      );
    }
    return const Center(child: CircularProgressIndicator());
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
}
