class AppConstants {
  static const String appName = 'zfm';

  // Groups
  static const String groupNeeds = 'needs';
  static const String groupWants = 'wants';
  static const String groupSavings = 'savings';

  static const List<String> groups = [groupNeeds, groupWants, groupSavings];

  static const Map<String, String> groupLabels = {
    groupNeeds: 'Needs',
    groupWants: 'Wants',
    groupSavings: 'Savings',
  };

  // Hive box names
  static const String boxCategories = 'categories';
  static const String boxExpenses = 'expenses';
  static const String boxConfig = 'config';

  // Config keys
  static const String keyCurrentConfig = 'current';
}
