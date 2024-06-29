// lib/features/portfolio/ui/widgets/asset_list.dart

import 'package:flutter/material.dart';

class AssetList extends StatelessWidget {
  final Map<String, double> assets;

  const AssetList({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assets',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...assets.entries
                .map((entry) => _buildAssetItem(entry.key, entry.value))
                ,
          ],
        ),
      ),
    );
  }

  Widget _buildAssetItem(String asset, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(asset),
          Text(amount.toStringAsFixed(8)),
        ],
      ),
    );
  }
}
