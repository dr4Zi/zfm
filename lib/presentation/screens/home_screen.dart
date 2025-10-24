import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../core/constants.dart';
import '../viewmodels/finance_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceViewModel>(builder: (context, vm, _) {
      final colorScheme = Theme.of(context).colorScheme;

      return Scaffold(
        appBar: AppBar(
          title: const Text('💰 Personal Finance'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Income Card with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.account_balance_wallet_rounded,
                          color: colorScheme.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monthly Income',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            )),
                          const SizedBox(height: 4),
                          Text(Formatters.money(vm.config.monthlyIncome),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Spent & Remaining Row
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      label: 'Spent',
                      value: Formatters.money(vm.totalSpent),
                      icon: Icons.shopping_cart_rounded,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      label: 'Remaining',
                      value: Formatters.money(vm.totalRemaining),
                      icon: Icons.savings_rounded,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 50-30-20 Allocation Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pie_chart_rounded, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('50-30-20 Allocation',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      for (final g in AppConstants.groups)
                        _GroupRow(
                          label: AppConstants.groupLabels[g]!,
                          group: g,
                          planned: vm.plannedByGroup[g] ?? 0,
                          spent: vm.spentByGroup[g] ?? 0,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Daily Budget Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Daily Budget',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                              color: colorScheme.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text('${vm.daysLeft} days remaining this month',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DailyBudgetItem(
                        label: 'Total Daily',
                        amount: vm.avgDailyRemainingTotal,
                        icon: Icons.today_rounded,
                        isTotal: true,
                      ),
                      const SizedBox(height: 8),
                      for (final g in AppConstants.groups)
                        _DailyBudgetItem(
                          label: AppConstants.groupLabels[g]!,
                          amount: vm.avgDailyRemainingByGroup[g] ?? 0,
                          icon: _getGroupIcon(g),
                          isTotal: false,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'exp',
              onPressed: () => Navigator.pushNamed(context, '/expense'),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
            const SizedBox(height: 10),
            FloatingActionButton.extended(
              heroTag: 'cat',
              onPressed: () => Navigator.pushNamed(context, '/categories'),
              icon: const Icon(Icons.category),
              label: const Text('Categories'),
            ),
          ],
        ),
      );
    });
  }

  static IconData _getGroupIcon(String group) {
    switch (group) {
      case 'needs':
        return Icons.home_rounded;
      case 'wants':
        return Icons.celebration_rounded;
      case 'savings':
        return Icons.account_balance_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              )),
          ],
        ),
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  final String label;
  final String group;
  final double planned;
  final double spent;

  const _GroupRow({
    required this.label,
    required this.group,
    required this.planned,
    required this.spent,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = planned - spent;
    final percentage = planned > 0 ? (spent / planned).clamp(0.0, 1.0) : 0.0;
    final colorScheme = Theme.of(context).colorScheme;

    // Color based on group
    Color groupColor;
    IconData groupIcon;
    switch (group) {
      case 'needs':
        groupColor = Colors.blue;
        groupIcon = Icons.home_rounded;
        break;
      case 'wants':
        groupColor = Colors.purple;
        groupIcon = Icons.celebration_rounded;
        break;
      case 'savings':
        groupColor = Colors.green;
        groupIcon = Icons.account_balance_rounded;
        break;
      default:
        groupColor = Colors.grey;
        groupIcon = Icons.category_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: groupColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(groupIcon, color: groupColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              ),
              Text('${(percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: percentage > 0.9 ? Colors.red : groupColor,
                )),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: groupColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 0.9 ? Colors.red : groupColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spent: ${Formatters.money(spent)}',
                style: Theme.of(context).textTheme.bodySmall),
              Text('Left: ${Formatters.money(remaining)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: remaining < 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w600,
                )),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyBudgetItem extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final bool isTotal;

  const _DailyBudgetItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.isTotal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isTotal
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: isTotal
          ? Border.all(color: colorScheme.primary.withOpacity(0.3), width: 1.5)
          : null,
      ),
      child: Row(
        children: [
          Icon(icon,
            size: 20,
            color: isTotal ? colorScheme.primary : colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              )),
          ),
          Text(Formatters.money(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: amount < 0
                ? Colors.red
                : (isTotal ? colorScheme.primary : colorScheme.onSurface),
            )),
        ],
      ),
    );
  }
}
