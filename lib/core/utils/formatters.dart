import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat currency = NumberFormat.currency(symbol: '₫', decimalDigits: 0, locale: 'vi_VN');
  static final NumberFormat number = NumberFormat.decimalPattern('vi_VN');

  static String money(num value) => currency.format(value);
}
