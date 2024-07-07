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
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _symbolController,
            decoration: const InputDecoration(
                labelText: 'Trading Symbol (e.g., BTCUSDT)'),
            onChanged: (_) => _updateParameters(),
          ),
          TextFormField(
            controller: _investmentAmountController,
            decoration: const InputDecoration(
                labelText: 'Investment Amount per Purchase'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateParameters(),
          ),
          TextFormField(
            controller: _purchaseFrequencyController,
            decoration: const InputDecoration(
                labelText: 'Purchase Frequency (in hours)'),
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
          SwitchListTile(
            title: const Text('Use Auto Minimum Trade Amount'),
            value: _useAutoMinTradeAmount,
            onChanged: (value) {
              setState(() {
                _useAutoMinTradeAmount = value;
              });
              _updateParameters();
            },
          ),
          SwitchListTile(
            title: const Text('Use Variable Investment Amount'),
            value: _isVariableInvestmentAmount,
            onChanged: (value) {
              setState(() {
                _isVariableInvestmentAmount = value;
              });
              _updateParameters();
            },
          ),
          SwitchListTile(
            title: const Text('Reinvest Profits'),
            value: _reinvestProfits,
            onChanged: (value) {
              setState(() {
                _reinvestProfits = value;
              });
              _updateParameters();
            },
          ),
        ],
      ),
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
      // Altri parametri rimangono invariati
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
