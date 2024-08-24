// lib/features/portfolio/ui/widgets/asset_list.dart

import 'package:flutter/material.dart';

class AssetList extends StatelessWidget {
  final Map<String, double> assets;

  const AssetList({Key? key, required this.assets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assets', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets.entries.elementAt(index);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(asset.key[0],
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                  title: Text(asset.key),
                  trailing: Text(
                    asset.value.toStringAsFixed(8),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
