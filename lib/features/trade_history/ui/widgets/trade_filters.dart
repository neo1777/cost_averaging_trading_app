import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_text_field.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_button.dart';

class TradeFilters extends StatefulWidget {
  final Function(DateTime?, DateTime?, String?) onFilterApplied;

  const TradeFilters({super.key, required this.onFilterApplied});

  @override
  TradeFiltersState createState() => TradeFiltersState();
}

class TradeFiltersState extends State<TradeFilters> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedAssetPair;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      title: 'Filters',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Start Date',
                  readOnly: true,
                  onTap: () => _selectDate(context, true),
                  value: _startDate != null ? _formatDate(_startDate!) : '',
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'End Date',
                  readOnly: true,
                  onTap: () => _selectDate(context, false),
                  value: _endDate != null ? _formatDate(_endDate!) : '',
                  icon: Icons.calendar_today,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Asset Pair',
              border: OutlineInputBorder(),
            ),
            value: _selectedAssetPair,
            items: ['BTC/USDT', 'ETH/USDT', 'XRP/USDT']
                .map((pair) => DropdownMenuItem(value: pair, child: Text(pair)))
                .toList(),
            onChanged: (value) => setState(() => _selectedAssetPair = value),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Apply Filters',
            onPressed: () => widget.onFilterApplied(_startDate, _endDate, _selectedAssetPair),
            icon: Icons.filter_list,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}