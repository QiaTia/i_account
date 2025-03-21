// 手动格式化日期为"YYYY-MM-DD"字符串（避免依赖intl包）[5](@ref)
String formatDate(DateTime date, { int showLen = 3 }) {
  return [date.year.toString(), date.month.toString().padLeft(2, '0'), date.day.toString().padLeft(2, '0')].sublist(0, showLen).join('-');
  // return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

/// 获取某个月份的周列表，仅包含属于该月的周
List<(String, String, int)> getWeeksOfMonth(DateTime inputDate) {
  final year = inputDate.year;
  final month = inputDate.month;

  // 计算当前月的第一天和最后一天
  final firstDayOfMonth = DateTime(year, month, 1).subtract(Duration(days: DateTime(year, month, 1).weekday - 1));
  final lastDayOfMonth =
      DateTime(year, month + 1, 1).subtract(const Duration(days: 1));

  // 找到当前月的第一个周一（若首日不是周一，则向前推算）
  final firstDayWeekday = firstDayOfMonth.weekday;
  final daysToFirstMonday = (DateTime.monday - firstDayWeekday + 7) % 7;
  DateTime currentMonday =
      firstDayOfMonth.add(Duration(days: daysToFirstMonday));

  final List<(String, String, int)> weeks = [];
  var weekNumber = 1;
  // 遍历每周，直到超出月末
  while (currentMonday.isBefore(lastDayOfMonth)) {
    // 若当前周一已跨月，终止循环
    // if (currentMonday.month != month) break;

    final startDate = currentMonday;
    DateTime endDate = startDate.add(const Duration(days: 6));

    // 确保结束日期不超过月末
    if (endDate.isAfter(lastDayOfMonth)) {
      endDate = lastDayOfMonth;
    }

    weeks.add((formatDate(startDate), formatDate(endDate), weekNumber++));

    currentMonday = currentMonday.add(const Duration(days: 7));
  }

  return weeks;
}

/// 获取某个月份的所有月份的范围，包括当月
List<(String, String, int)> getMonthlyRanges(DateTime inputDate) {
  final year = inputDate.year;
  final targetMonth = inputDate.month;
  final List<(String, String, int)> ranges = [];

  // 遍历从1月到目标月份的所有月份
  for (int month = 1; month <= targetMonth; month++) {
    // 计算当月第一天
    final firstDay = DateTime(year, month, 1);
    // 计算当月最后一天（下个月第一天减1天）
    final lastDay =
        DateTime(year, month + 1, 1).subtract(const Duration(days: 1));

    ranges.add((formatDate(firstDay), formatDate(lastDay), month));
  }
  return ranges;
}
/// 获取某个年份的所有年份的范围，包括当年
List<(String, String, int)> getYearlyRanges(DateTime inputDate) {
  final year = inputDate.year;
  const lastYear = 2020;
  final List<(String, String, int)> ranges = [];
  // 遍历从1月到目标月份的所有月份
  for (int i = lastYear; i <= year; i++) {
    // 计算当月第一天
    final firstDay = DateTime(i, 1, 1);
    // 计算当月最后一天（下个月第一天减1天）
    final lastDay =
        DateTime(i + 1, 1, 1).subtract(const Duration(days: 1));
    ranges.add((formatDate(firstDay), formatDate(lastDay), i));
  }
  return ranges;
}
