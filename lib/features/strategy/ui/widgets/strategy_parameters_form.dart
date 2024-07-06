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
  // Nuovi controller
  late TextEditingController _manualMinTradeAmountController;
  late TextEditingController _variableInvestmentPercentageController;

  late bool _useAutoMinTradeAmount;
  late bool _isVariableInvestmentAmount;
  late bool _reinvestProfits;

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
    // Inizializzazione dei nuovi controller
    _manualMinTradeAmountController = TextEditingController(
        text: widget.initialParameters?.manualMinTradeAmount.toString() ?? '');
    _variableInvestmentPercentageController = TextEditingController(
        text:
            widget.initialParameters?.variableInvestmentPercentage.toString() ??
                '');

    _useAutoMinTradeAmount =
        widget.initialParameters?.useAutoMinTradeAmount ?? true;
    _isVariableInvestmentAmount =
        widget.initialParameters?.isVariableInvestmentAmount ?? false;
    _reinvestProfits = widget.initialParameters?.reinvestProfits ?? false;
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
          // Nuovi campi
          SwitchListTile(
            title: const Text('Use Auto Min Trade Amount'),
            value: _useAutoMinTradeAmount,
            onChanged: (value) {
              setState(() {
                _useAutoMinTradeAmount = value;
              });
              _updateParameters();
            },
          ),
          Visibility(
            visible: !_useAutoMinTradeAmount,
            child: TextFormField(
              controller: _manualMinTradeAmountController,
              decoration:
                  const InputDecoration(labelText: 'Manual Min Trade Amount'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateParameters(),
            ),
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
          Visibility(
            visible: _isVariableInvestmentAmount,
            child: TextFormField(
              controller: _variableInvestmentPercentageController,
              decoration: const InputDecoration(
                  labelText: 'Variable Investment Percentage (%)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateParameters(),
            ),
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
      intervalDays: int.tryParse(_intervalDaysController.text) ?? 0,
      targetProfitPercentage:
          double.tryParse(_targetProfitPercentageController.text) ?? 0,
      stopLossPercentage:
          double.tryParse(_stopLossPercentageController.text) ?? 0,
      purchaseFrequency: int.tryParse(_purchaseFrequencyController.text) ?? 0,
      maxInvestmentSize:
          double.tryParse(_maxInvestmentSizeController.text) ?? 0,
      // Nuovi parametri
      useAutoMinTradeAmount: _useAutoMinTradeAmount,
      manualMinTradeAmount:
          double.tryParse(_manualMinTradeAmountController.text) ?? 0,
      isVariableInvestmentAmount: _isVariableInvestmentAmount,
      variableInvestmentPercentage:
          double.tryParse(_variableInvestmentPercentageController.text) ?? 0,
      reinvestProfits: _reinvestProfits,
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
    // Dispose dei nuovi controller
    _manualMinTradeAmountController.dispose();
    _variableInvestmentPercentageController.dispose();
    super.dispose();
  }
}
