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
            controller: _symbolController,
            decoration: const InputDecoration(labelText: 'Symbol'),
            onChanged: (_) => _updateParameters(),
          ),
          TextFormField(
            controller: _investmentAmountController,
            decoration: const InputDecoration(labelText: 'Investment Amount'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateParameters(),
          ),
          TextFormField(
            controller: _intervalDaysController,
            decoration: const InputDecoration(labelText: 'Interval (days)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateParameters(),
          ),
          TextFormField(
            controller: _targetProfitPercentageController,
            decoration: const InputDecoration(labelText: 'Target Profit (%)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateParameters(),
          ),
          TextFormField(
            controller: _stopLossPercentageController,
            decoration: const InputDecoration(labelText: 'Stop Loss (%)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateParameters(),
          ),
          TextFormField(
            controller: _purchaseFrequencyController,
            decoration:
                const InputDecoration(labelText: 'Purchase Frequency (days)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateParameters(),
          ),
          TextFormField(
            controller: _maxInvestmentSizeController,
            decoration: const InputDecoration(labelText: 'Max Investment Size'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateParameters(),
          ),
        ],
      ),
    );
  }

  void _updateParameters() {
    final parameters = StrategyParameters(
      symbol: _symbolController.text,
      investmentAmount: double.tryParse(_investmentAmountController.text) ?? 0,
      intervalDays: int.tryParse(_intervalDaysController.text) ?? 0,
      targetProfitPercentage:
          double.tryParse(_targetProfitPercentageController.text) ?? 0,
      stopLossPercentage:
          double.tryParse(_stopLossPercentageController.text) ?? 0,
      purchaseFrequency: int.tryParse(_purchaseFrequencyController.text) ?? 0,
      maxInvestmentSize:
          double.tryParse(_maxInvestmentSizeController.text) ?? 0,
    );
    widget.onParametersChanged(parameters);
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
