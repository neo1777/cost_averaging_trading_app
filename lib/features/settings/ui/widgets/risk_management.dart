import 'package:flutter/material.dart';

class RiskManagement extends StatelessWidget {
  final double maxLossPercentage;
  final int maxConcurrentTrades;
  final double maxPositionSizePercentage;
  final double dailyExposureLimit;
  final double maxAllowedVolatility;
  final int maxRebuyCount;
  final Function(double, int, double, double, double, int)
      onUpdateRiskManagement;

  const RiskManagement({
    super.key,
    required this.maxLossPercentage,
    required this.maxConcurrentTrades,
    required this.maxPositionSizePercentage,
    required this.dailyExposureLimit,
    required this.maxAllowedVolatility,
    required this.maxRebuyCount,
    required this.onUpdateRiskManagement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Risk Management', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildSlider(
          context,
          'Max Loss Percentage',
          maxLossPercentage,
          0.0,
          10.0,
          (value) => onUpdateRiskManagement(
              value,
              maxConcurrentTrades,
              maxPositionSizePercentage,
              dailyExposureLimit,
              maxAllowedVolatility,
              maxRebuyCount),
        ),
        _buildSlider(
          context,
          'Max Concurrent Trades',
          maxConcurrentTrades.toDouble(),
          1,
          10,
          (value) => onUpdateRiskManagement(
              maxLossPercentage,
              value.toInt(),
              maxPositionSizePercentage,
              dailyExposureLimit,
              maxAllowedVolatility,
              maxRebuyCount),
        ),
        _buildSlider(
          context,
          'Max Position Size Percentage',
          maxPositionSizePercentage,
          1.0,
          100.0,
          (value) => onUpdateRiskManagement(
              maxLossPercentage,
              maxConcurrentTrades,
              value,
              dailyExposureLimit,
              maxAllowedVolatility,
              maxRebuyCount),
        ),
        _buildSlider(
          context,
          'Daily Exposure Limit',
          dailyExposureLimit,
          100.0,
          10000.0,
          (value) => onUpdateRiskManagement(
              maxLossPercentage,
              maxConcurrentTrades,
              maxPositionSizePercentage,
              value,
              maxAllowedVolatility,
              maxRebuyCount),
        ),
        _buildSlider(
          context,
          'Max Allowed Volatility',
          maxAllowedVolatility,
          0.0,
          1.0,
          (value) => onUpdateRiskManagement(
              maxLossPercentage,
              maxConcurrentTrades,
              maxPositionSizePercentage,
              dailyExposureLimit,
              value,
              maxRebuyCount),
        ),
        _buildSlider(
          context,
          'Max Rebuy Count',
          maxRebuyCount.toDouble(),
          1,
          10,
          (value) => onUpdateRiskManagement(
              maxLossPercentage,
              maxConcurrentTrades,
              maxPositionSizePercentage,
              dailyExposureLimit,
              maxAllowedVolatility,
              value.toInt()),
        ),
      ],
    );
  }

  Widget _buildSlider(BuildContext context, String label, double value,
      double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 100,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
