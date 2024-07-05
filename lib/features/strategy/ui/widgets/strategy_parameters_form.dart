// lib/features/strategy/ui/widgets/strategy_parameters_form.dart

import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

class StrategyParametersForm extends StatefulWidget {
  final StrategyParameters? initialParameters;
  final Function(StrategyParameters) onParametersChanged;

  const StrategyParametersForm({
    super.key,
    this.initialParameters,
    required this.onParametersChanged,
  });

  @override
  StrategyParametersFormState createState() => StrategyParametersFormState();
}

class StrategyParametersFormState extends State<StrategyParametersForm> {
  late TextEditingController _symbolController;
  late TextEditingController _investmentAmountController;
  late TextEditingController _intervalDaysController;
  late TextEditingController _targetProfitPercentageController;
  late TextEditingController _stopLossPercentageController;
  late TextEditingController _purchaseFrequencyController;
  late TextEditingController _maxInvestmentSizeController;

  @override
  void initState() {
    super.initState();
    _symbolController =
        TextEditingController(text: widget.initialParameters?.symbol ?? '');
    _investmentAmountController = TextEditingController(
        text: widget.initialParameters?.investmentAmount.toString() ?? '');
    _intervalDaysController = TextEditingController(
        text: widget.initialParameters?.intervalDays.toString() ?? '');
    _targetProfitPercentageController = TextEditingController(
        text:
            widget.initialParameters?.targetProfitPercentage.toString() ?? '');
    _stopLossPercentageController = TextEditingController(
        text: widget.initialParameters?.stopLossPercentage.toString() ?? '');
    _purchaseFrequencyController = TextEditingController(
        text: widget.initialParameters?.purchaseFrequency.toString() ?? '');
    _maxInvestmentSizeController = TextEditingController(
        text: widget.initialParameters?.maxInvestmentSize.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Symbol'),
            initialValue: widget.initialParameters?.symbol ?? '',
            onChanged: (value) => _updateParameters(symbol: value),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Investment Amount'),
            initialValue:
                widget.initialParameters?.investmentAmount.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                _updateParameters(investmentAmount: double.tryParse(value)),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Interval (days)'),
            initialValue:
                widget.initialParameters?.intervalDays.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                _updateParameters(intervalDays: int.tryParse(value)),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Target Profit (%)'),
            initialValue:
                widget.initialParameters?.targetProfitPercentage.toString() ??
                    '',
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateParameters(
                targetProfitPercentage: double.tryParse(value)),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Stop Loss (%)'),
            initialValue:
                widget.initialParameters?.stopLossPercentage.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                _updateParameters(stopLossPercentage: double.tryParse(value)),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Purchase Frequency (days)'),
            initialValue:
                widget.initialParameters?.purchaseFrequency.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                _updateParameters(purchaseFrequency: int.tryParse(value)),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Max Investment Size'),
            initialValue:
                widget.initialParameters?.maxInvestmentSize.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                _updateParameters(maxInvestmentSize: double.tryParse(value)),
          ),
        ],
      ),
    );
  }

  void _updateParameters({
    String? symbol,
    double? investmentAmount,
    int? intervalDays,
    double? targetProfitPercentage,
    double? stopLossPercentage,
    int? purchaseFrequency,
    double? maxInvestmentSize,
  }) {
    final updatedParameters = StrategyParameters(
      symbol: symbol ?? widget.initialParameters!.symbol,
      investmentAmount:
          investmentAmount ?? widget.initialParameters!.investmentAmount,
      intervalDays: intervalDays ?? widget.initialParameters!.intervalDays,
      targetProfitPercentage: targetProfitPercentage ??
          widget.initialParameters!.targetProfitPercentage,
      stopLossPercentage:
          stopLossPercentage ?? widget.initialParameters!.stopLossPercentage,
      purchaseFrequency:
          purchaseFrequency ?? widget.initialParameters!.purchaseFrequency,
      maxInvestmentSize:
          maxInvestmentSize ?? widget.initialParameters!.maxInvestmentSize,
    );
    widget.onParametersChanged(updatedParameters);
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _investmentAmountController.dispose();
    _intervalDaysController.dispose();
    _targetProfitPercentageController.dispose();
    _stopLossPercentageController.dispose();
    _purchaseFrequencyController.dispose();
    _maxInvestmentSizeController.dispose();
    super.dispose();
  }
}
