import 'package:flutter/material.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_card.dart';
import 'package:cost_averaging_trading_app/core/widgets/custom_text_field.dart';

class ApiSettings extends StatelessWidget {
  final String apiKey;
  final String secretKey;
  final Function(String) onApiKeyChanged;
  final Function(String) onSecretKeyChanged;

  const ApiSettings({
    super.key,
    required this.apiKey,
    required this.secretKey,
    required this.onApiKeyChanged,
    required this.onSecretKeyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      title: 'API Settings',
      child: Column(
        children: [
          CustomTextField(
            label: 'API Key',
            value: apiKey,
            onChanged: onApiKeyChanged,
            icon: Icons.vpn_key,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Secret Key',
            value: secretKey,
            onChanged: onSecretKeyChanged,
            icon: Icons.lock,
            obscureText: true,
          ),
        ],
      ),
    );
  }
}