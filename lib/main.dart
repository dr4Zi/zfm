import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'data/models/category.dart';
import 'data/models/expense.dart';
import 'data/models/finance_config.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/config_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'presentation/screens/category_screen.dart';
import 'presentation/screens/expense_input_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/viewmodels/finance_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(FinanceConfigAdapter());

  // Open boxes
  await Hive.openBox<Category>(AppConstants.boxCategories);
  await Hive.openBox<Expense>(AppConstants.boxExpenses);
  await Hive.openBox<FinanceConfig>(AppConstants.boxConfig);

  // Seed default config if not exists
  final cfgBox = Hive.box<FinanceConfig>(AppConstants.boxConfig);
  if (!cfgBox.containsKey(AppConstants.keyCurrentConfig)) {
    await cfgBox.put(
      AppConstants.keyCurrentConfig,
      const FinanceConfig(
        monthlyIncome: 0,
        groupPercent: {
          AppConstants.groupNeeds: 0.5,
          AppConstants.groupWants: 0.3,
          AppConstants.groupSavings: 0.2,
        },
      ),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FinanceViewModel(
            categoryRepo: CategoryRepository(),
            expenseRepo: ExpenseRepository(),
            configRepo: ConfigRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'zfm',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/categories': (_) => const CategoryScreen(),
          '/expense': (_) => const ExpenseInputScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
