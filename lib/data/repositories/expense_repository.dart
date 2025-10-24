import 'package:hive/hive.dart';

import '../../core/constants.dart';
import '../models/expense.dart';

class ExpenseRepository {
  Box<Expense> get _box => Hive.box<Expense>(AppConstants.boxExpenses);

  List<Expense> getAll() => _box.values.toList();

  Future<void> add(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
