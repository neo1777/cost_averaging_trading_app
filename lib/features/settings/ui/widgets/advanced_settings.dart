// lib/features/settings/ui/widgets/advanced_settings.dart

import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/models/risk_management_settings.dart';

class AdvancedSettings extends StatelessWidget {
  final bool isAdvancedMode;
  final VoidCallback onToggleAdvancedMode;
  final RiskManagementSettings? riskManagementSettings;
  final Function(RiskManagementSettings)? onUpdateRiskManagement;

  const AdvancedSettings({
    super.key,
    required this.isAdvancedMode,
    required this.onToggleAdvancedMode,
    this.riskManagementSettings,
    this.onUpdateRiskManagement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Advanced Settings',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Advanced Mode'),
              value: isAdvancedMode,
              onChanged: (_) => onToggleAdvancedMode(),
            ),
            if (isAdvancedMode && riskManagementSettings != null) ...[
              const SizedBox(height: 16),
              Text('Risk Management',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildSlider(
                context,
                'Max Loss Percentage',
                riskManagementSettings!.maxLossPercentage,
                0,
                10,
                (value) => _updateRiskManagement(maxLossPercentage: value),
              ),
              _buildSlider(
                context,
                'Max Concurrent Trades',
                riskManagementSettings!.maxConcurrentTrades.toDouble(),
                1,
                10,
                (value) =>
                    _updateRiskManagement(maxConcurrentTrades: value.toInt()),
              ),
              _buildSlider(
                context,
                'Max Position Size (%)',
                riskManagementSettings!.maxPositionSizePercentage,
                1,
                100,
                (value) =>
                    _updateRiskManagement(maxPositionSizePercentage: value),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context, String label, double value,
      double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _updateRiskManagement({
    double? maxLossPercentage,
    int? maxConcurrentTrades,
    double? maxPositionSizePercentage,
  }) {
    if (onUpdateRiskManagement != null && riskManagementSettings != null) {
      onUpdateRiskManagement!(
        RiskManagementSettings(
          maxLossPercentage:
              maxLossPercentage ?? riskManagementSettings!.maxLossPercentage,
          maxConcurrentTrades: maxConcurrentTrades ??
              riskManagementSettings!.maxConcurrentTrades,
          maxPositionSizePercentage: maxPositionSizePercentage ??
              riskManagementSettings!.maxPositionSizePercentage,
          dailyExposureLimit: riskManagementSettings!.dailyExposureLimit,
          maxAllowedVolatility: riskManagementSettings!.maxAllowedVolatility,
          maxRebuyCount: riskManagementSettings!.maxRebuyCount,
        ),
      );
    }
  }
}
