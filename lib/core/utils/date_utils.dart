class DateUtilsEx {
  static int daysInMonth(DateTime date) {
    final firstDayThisMonth = DateTime(date.year, date.month, 1);
    final firstDayNextMonth = DateTime(date.year, date.month + 1, 1);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  static int daysRemainingInMonth(DateTime date) {
    final total = daysInMonth(date);
    return total - date.day + 1; // include today
  }
}
