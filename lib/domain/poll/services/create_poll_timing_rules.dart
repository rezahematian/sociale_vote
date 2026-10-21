/// Calendar-day rule shared by the create form and its controller.
/// A Vote from 1 October through 31 October lasts 31 calendar days.
class CreatePollTimingRules {
  const CreatePollTimingRules._();

  static const int maxCalendarDays = 31;

  static int inclusiveDays(DateTime start, DateTime end) {
    final first = DateTime.utc(start.year, start.month, start.day);
    final last = DateTime.utc(end.year, end.month, end.day);
    return last.difference(first).inDays + 1;
  }

  static bool isOverLimit(DateTime start, DateTime end) =>
      inclusiveDays(start, end) > maxCalendarDays;

  static DateTime lastAllowedEndDate(DateTime start) =>
      DateTime(start.year, start.month, start.day + maxCalendarDays - 1);
}
