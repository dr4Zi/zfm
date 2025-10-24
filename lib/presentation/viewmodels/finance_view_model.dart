import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/category.dart' as m;
import '../../data/models/expense.dart';
import '../../data/models/finance_config.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/config_repository.dart';
import '../../data/repositories/expense_repository.dart';

class FinanceViewModel extends ChangeNotifier {
  final CategoryRepository categoryRepo;
  final ExpenseRepository expenseRepo;
  final ConfigRepository configRepo;

  late final StreamSubscription _catSub;
  late final StreamSubscription _expSub;
  late final StreamSubscription _cfgSub;

  FinanceViewModel({
    required this.categoryRepo,
    required this.expenseRepo,
    required this.configRepo,
  }) {
    // Listen for changes in Hive boxes and notify listeners
    _catSub = Hive.box<m.Category>(AppConstants.boxCategories).watch().listen((_) => notifyListeners());
    _expSub = Hive.box<Expense>(AppConstants.boxExpenses).watch().listen((_) => notifyListeners());
    _cfgSub = Hive.box<FinanceConfig>(AppConstants.boxConfig).watch().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _catSub.cancel();
    _expSub.cancel();
    _cfgSub.cancel();
    super.dispose();
  }

  // Data accessors
  List<m.Category> get categories => categoryRepo.getAll();
  List<Expense> get expenses => expenseRepo.getAll()..sort((a, b) => b.date.compareTo(a.date));
  FinanceConfig get config => configRepo.current ?? const FinanceConfig(monthlyIncome: 0, groupPercent: {
        AppConstants.groupNeeds: 0.5,
        AppConstants.groupWants: 0.3,
        AppConstants.groupSavings: 0.2,
      });

  // Derived computations
  Map<String, double> get plannedByGroup => {
        for (final e in config.groupPercent.entries) e.key: (config.monthlyIncome * e.value),
      };

  Map<String, double> get spentByGroup {
    final map = {for (final g in AppConstants.groups) g: 0.0};
    final catIndex = {for (final c in categories) c.id: c};
    for (final e in expenses) {
      final cat = catIndex[e.categoryId];
      if (cat != null) {
        map[cat.group] = (map[cat.group] ?? 0) + e.amount;
      }
    }
    return map;
  }

  Map<String, double> get remainingByGroup {
    final plan = plannedByGroup;
    final spent = spentByGroup;
    return {
      for (final g in AppConstants.groups) g: (plan[g] ?? 0) - (spent[g] ?? 0),
    };
  }

  double get totalSpent => expenses.fold(0.0, (p, e) => p + e.amount);
  double get totalPlanned => plannedByGroup.values.fold(0.0, (p, v) => p + v);
  double get totalRemaining => totalPlanned - totalSpent;

  int get daysLeft => DateUtilsEx.daysRemainingInMonth(DateTime.now());

  Map<String, double> get avgDailyRemainingByGroup {
    final days = daysLeft;
    if (days <= 0) return {for (final g in AppConstants.groups) g: 0};
    final rem = remainingByGroup;
    return {for (final g in AppConstants.groups) g: (rem[g]! / days)};
  }

  double get avgDailyRemainingTotal {
    final days = daysLeft;
    if (days <= 0) return 0;
    return totalRemaining / days;
  }

  // Actions
  Future<void> setMonthlyIncome(double income) async {
    final cfg = config.copyWith(monthlyIncome: income);
    await configRepo.setCurrent(cfg);
  }

  Future<void> setGroupPercents(Map<String, double> map) async {
    final normalized = Map<String, double>.from(map);
    // Ensure groups exist
    for (final g in AppConstants.groups) {
      normalized[g] = (normalized[g] ?? 0).clamp(0.0, 1.0);
    }
    await configRepo.setCurrent(config.copyWith(groupPercent: normalized));
  }

  Future<void> resetDefaultPercents() async {
    await setGroupPercents(const {
      AppConstants.groupNeeds: 0.5,
      AppConstants.groupWants: 0.3,
      AppConstants.groupSavings: 0.2,
    });
  }

  Future<void> addOrUpdateCategory({String? id, required String name, required String group, required bool isFixed, double? plannedPercent}) async {
    final cat = m.Category(
      id: id ?? const Uuid().v4(),
      name: name,
      group: group,
      isFixed: isFixed,
      plannedPercent: plannedPercent,
    );
    await categoryRepo.upsert(cat);
  }

  Future<void> deleteCategory(String id) async {
    await categoryRepo.delete(id);
  }

  Future<void> addExpense({required String categoryId, required double amount, DateTime? date, String? note}) async {
    final expense = Expense(
      id: const Uuid().v4(),
      categoryId: categoryId,
      amount: amount,
      date: date ?? DateTime.now(),
      note: note,
    );
    await expenseRepo.add(expense);
  }

  Future<void> deleteExpense(String id) async {
    await expenseRepo.delete(id);
  }

  // Import categories from JSON (list)
  Future<void> importCategories(List<Map<String, dynamic>> jsonList) async {
    for (final j in jsonList) {
      final cat = m.Category.fromJson(j);
      await categoryRepo.upsert(cat);
    }
  }
}
