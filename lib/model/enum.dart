
/// 一周的枚举
enum WeekName {
  /// 周一
  monday(1),
  /// 周二
  tuesday(2),
  /// 周三
  wednesday(3),
  /// 周四
  thursday(4),
  /// 周五
  friday(5),
  /// 周六
  saturday(6),
  /// 周日
  sunday(7);

  final int state;
  const WeekName(this.state);

  static WeekName fromInt(int value) {
    for (WeekName status in WeekName.values) {
      if (status.state == value) {
        return status;
      }
    }
    return WeekName.monday;
  }
}