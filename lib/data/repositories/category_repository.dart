import 'package:hive/hive.dart';

import '../../core/constants.dart';
import '../models/category.dart';

class CategoryRepository {
  Box<Category> get _box => Hive.box<Category>(AppConstants.boxCategories);

  List<Category> getAll() => _box.values.toList();

  Future<void> upsert(Category category) async {
    await _box.put(category.id, category);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
