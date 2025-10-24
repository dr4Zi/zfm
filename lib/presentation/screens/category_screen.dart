import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../data/models/category.dart' as m;
import '../viewmodels/finance_view_model.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceViewModel>(builder: (context, vm, _) {
      final grouped = {
        for (final g in AppConstants.groups) g: vm.categories.where((c) => c.group == g).toList()
      };
      return Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            for (final g in AppConstants.groups)
              _GroupSection(
                groupKey: g,
                title: AppConstants.groupLabels[g]!,
                items: grouped[g] ?? const [],
              ),
            const SizedBox(height: 100),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCategoryDialog(context, vm),
          child: const Icon(Icons.add),
        ),
      );
    });
  }

  Future<void> _showCategoryDialog(BuildContext context, FinanceViewModel vm, {m.Category? category}) async {
    final formKey = GlobalKey<FormState>();
    String name = category?.name ?? '';
    String group = category?.group ?? AppConstants.groupNeeds;
    bool isFixed = category?.isFixed ?? false;
    String plannedStr = category?.plannedPercent?.toString() ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                    onChanged: (v) => name = v,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: group,
                    items: [
                      for (final g in AppConstants.groups)
                        DropdownMenuItem(value: g, child: Text(AppConstants.groupLabels[g]!))
                    ],
                    onChanged: (v) => group = v ?? AppConstants.groupNeeds,
                    decoration: const InputDecoration(labelText: 'Group'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: isFixed,
                    onChanged: (v) => isFixed = v,
                    title: const Text('Fixed expense?'),
                  ),
                  TextFormField(
                    initialValue: plannedStr,
                    decoration: const InputDecoration(labelText: 'Planned % (optional, 0-100)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => plannedStr = v,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              final pp = double.tryParse(plannedStr);
              await vm.addOrUpdateCategory(
                id: category?.id,
                name: name.trim(),
                group: group,
                isFixed: isFixed,
                plannedPercent: pp != null ? (pp / 100.0) : null,
              );
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  final String groupKey;
  final String title;
  final List<m.Category> items;
  const _GroupSection({required this.groupKey, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<FinanceViewModel>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => CategoryScreen()._showCategoryDialog(context, vm, category: null),
                ),
              ],
            ),
            const Divider(height: 1),
            for (final c in items)
              Dismissible(
                key: Key(c.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete?'),
                          content: Text('Delete category "${c.name}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (_) => vm.deleteCategory(c.id),
                child: ListTile(
                  title: Text(c.name),
                  subtitle: Text('${AppConstants.groupLabels[c.group]} • ' + (c.isFixed ? 'Fixed' : 'Variable')),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => CategoryScreen()._showCategoryDialog(context, vm, category: c),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
