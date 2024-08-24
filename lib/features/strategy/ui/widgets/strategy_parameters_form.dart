// lib/features/strategy/ui/widgets/strategy_parameters_form.dart

import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/features/strategy/models/strategy_parameters.dart';

class StrategyParametersForm extends StatefulWidget {
  final StrategyParameters initialParameters;
  final Function(StrategyParameters) onParametersChanged;

  const StrategyParametersForm({
    super.key,
    required this.initialParameters,
    required this.onParametersChanged,
  });

  @override
  StrategyParametersFormState createState() => StrategyParametersFormState();
}

class StrategyParametersFormState extends State<StrategyParametersForm> {
  late TextEditingController _symbolController;
  late TextEditingController _investmentAmountController;
  late TextEditingController _purchaseFrequencyController;
  late TextEditingController _targetProfitPercentageController;
  late TextEditingController _stopLossPercentageController;
  late bool _useAutoMinTradeAmount;
  late bool _isVariableInvestmentAmount;
  late bool _reinvestProfits;

  @override
  void initState() {
    super.initState();
    _symbolController =
        TextEditingController(text: widget.initialParameters.symbol);
    _investmentAmountController = TextEditingController(
        text: widget.initialParameters.investmentAmount.toString());
    _purchaseFrequencyController = TextEditingController(
        text: widget.initialParameters.purchaseFrequency.toString());
    _targetProfitPercentageController = TextEditingController(
        text: widget.initialParameters.targetProfitPercentage.toString());
    _stopLossPercentageController = TextEditingController(
        text: widget.initialParameters.stopLossPercentage.toString());
    _useAutoMinTradeAmount = widget.initialParameters.useAutoMinTradeAmount;
    _isVariableInvestmentAmount =
        widget.initialParameters.isVariableInvestmentAmount;
    _reinvestProfits = widget.initialParameters.reinvestProfits;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Strategy Parameters',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildTextField('Trading Symbol', _symbolController),
            _buildTextField('Investment Amount', _investmentAmountController,
                TextInputType.number),
            _buildTextField('Purchase Frequency (hours)',
                _purchaseFrequencyController, TextInputType.number),
            _buildTextField('Target Profit (%)',
                _targetProfitPercentageController, TextInputType.number),
            _buildTextField('Stop Loss (%)', _stopLossPercentageController,
                TextInputType.number),
            _buildSwitchListTile(
                'Use Auto Minimum Trade Amount', _useAutoMinTradeAmount,
                (value) {
              setState(() => _useAutoMinTradeAmount = value);
              _updateParameters();
            }),
            _buildSwitchListTile(
                'Use Variable Investment Amount', _isVariableInvestmentAmount,
                (value) {
              setState(() => _isVariableInvestmentAmount = value);
              _updateParameters();
            }),
            _buildSwitchListTile('Reinvest Profits', _reinvestProfits, (value) {
              setState(() => _reinvestProfits = value);
              _updateParameters();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      [TextInputType? keyboardType]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboardType,
        onChanged: (_) => _updateParameters(),
      ),
    );
  }

  Widget _buildSwitchListTile(
      String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  void _updateParameters() {
    final updatedParameters = StrategyParameters(
      symbol: _symbolController.text,
      investmentAmount: double.tryParse(_investmentAmountController.text) ?? 0,
      purchaseFrequency: int.tryParse(_purchaseFrequencyController.text) ?? 0,
      targetProfitPercentage:
          double.tryParse(_targetProfitPercentageController.text) ?? 0,
      stopLossPercentage:
          double.tryParse(_stopLossPercentageController.text) ?? 0,
      useAutoMinTradeAmount: _useAutoMinTradeAmount,
      isVariableInvestmentAmount: _isVariableInvestmentAmount,
      reinvestProfits: _reinvestProfits,
      intervalDays: widget.initialParameters.intervalDays,
      maxInvestmentSize: widget.initialParameters.maxInvestmentSize,
      manualMinTradeAmount: widget.initialParameters.manualMinTradeAmount,
      variableInvestmentPercentage:
          widget.initialParameters.variableInvestmentPercentage,
    );
    widget.onParametersChanged(updatedParameters);
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _investmentAmountController.dispose();
    _purchaseFrequencyController.dispose();
    _targetProfitPercentageController.dispose();
    _stopLossPercentageController.dispose();
    super.dispose();
  }
}
