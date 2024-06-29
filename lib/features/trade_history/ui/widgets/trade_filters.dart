// lib/features/trade_history/ui/widgets/trade_filters.dart

import 'package:flutter/material.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Start Date'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                    controller: TextEditingController(
                      text: _startDate != null
                          ? '${_startDate!.toLocal()}'.split(' ')[0]
                          : '',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'End Date'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                    controller: TextEditingController(
                      text: _endDate != null
                          ? '${_endDate!.toLocal()}'.split(' ')[0]
                          : '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Asset Pair'),
              value: _selectedAssetPair,
              items: ['BTC/USDT', 'ETH/USDT', 'XRP/USDT']
                  .map((pair) =>
                      DropdownMenuItem(value: pair, child: Text(pair)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedAssetPair = value),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.onFilterApplied(
                  _startDate, _endDate, _selectedAssetPair),
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
