import 'package:hive/hive.dart';

import '../../core/constants.dart';
import '../models/finance_config.dart';

class ConfigRepository {
  Box<FinanceConfig> get _box => Hive.box<FinanceConfig>(AppConstants.boxConfig);

  FinanceConfig? get current => _box.get(AppConstants.keyCurrentConfig);

  Future<void> setCurrent(FinanceConfig config) async {
    await _box.put(AppConstants.keyCurrentConfig, config);
  }
}
