import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/utils/formatters.dart';
import '../viewmodels/finance_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _incomeController = TextEditingController();
  final _jsonController = TextEditingController();
  Map<String, double> _percents = const {
    AppConstants.groupNeeds: 0.5,
    AppConstants.groupWants: 0.3,
    AppConstants.groupSavings: 0.2,
  };

  @override
  void initState() {
    super.initState();
    final vm = context.read<FinanceViewModel>();
    _incomeController.text = vm.config.monthlyIncome.toStringAsFixed(0);
    _percents = Map.of(vm.config.groupPercent);
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Monthly income', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _incomeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: Formatters.money(vm.config.monthlyIncome),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  final val = double.tryParse(_incomeController.text.trim());
                  if (val == null || val < 0) return;
                  await vm.setMonthlyIncome(val);
                },
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Group percentages', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final g in AppConstants.groups)
            _PercentRow(
              label: AppConstants.groupLabels[g]!,
              value: _percents[g] ?? 0,
              onChanged: (v) => setState(() => _percents[g] = v),
            ),
          const SizedBox(height: 8),
          Text('Total: ${((_percents.values.fold(0.0, (p, v) => p + v)) * 100).toStringAsFixed(0)}%'),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton(
                onPressed: () => setState(() => _percents = const {
                      AppConstants.groupNeeds: 0.5,
                      AppConstants.groupWants: 0.3,
                      AppConstants.groupSavings: 0.2,
                    }),
                child: const Text('Reset 50-30-20'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () => vm.setGroupPercents(_percents),
                child: const Text('Save Percentages'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Import categories (JSON array)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _jsonController,
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '[{"id":"...","name":"Food","group":"needs","isFixed":false}]',
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              try {
                final decoded = json.decode(_jsonController.text.trim());
                if (decoded is List) {
                  final list = decoded.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
                  await vm.importCategories(list);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imported categories')));
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid JSON: $e')));
              }
            },
            child: const Text('Import'),
          )
        ],
      ),
    );
  }
}

class _PercentRow extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _PercentRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 96, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(0, 1),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 60,
          child: Text('${(value * 100).toStringAsFixed(0)}%'),
        )
      ],
    );
  }
}
