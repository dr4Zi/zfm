import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/category.dart';
import '../viewmodels/finance_view_model.dart';

class ExpenseInputScreen extends StatefulWidget {
  const ExpenseInputScreen({super.key});

  @override
  State<ExpenseInputScreen> createState() => _ExpenseInputScreenState();
}

class _ExpenseInputScreenState extends State<ExpenseInputScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _categoryId;
  String _amountStr = '';
  DateTime _date = DateTime.now();
  String _note = '';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final categories = vm.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _categoryId,
                items: [
                  for (final c in categories) DropdownMenuItem(value: c.id, child: Text(_categoryLabel(c)))
                ],
                onChanged: (v) => setState(() => _categoryId = v),
                validator: (v) => v == null ? 'Select category' : null,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => _amountStr = v,
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) return 'Enter positive amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_date)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(_date.year - 1),
                      lastDate: DateTime(_date.year + 1),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                onChanged: (v) => _note = v,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() != true) return;
                  final amount = double.parse(_amountStr);
                  await vm.addExpense(categoryId: _categoryId!, amount: amount, date: _date, note: _note.trim().isEmpty ? null : _note.trim());
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(Category c) => '${c.name} (${c.group})';
}
