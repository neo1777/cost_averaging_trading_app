import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';

class AssetList extends StatelessWidget {
  final Map<String, double> assets;

  const AssetList({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      title: 'Assets',
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets.entries.elementAt(index);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(asset.key[0]),
            ),
            title: Text(asset.key),
            trailing: Text(
              asset.value.toStringAsFixed(8),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}