/// Lightweight date formatters (no intl dependency needed yet).
class Formatters {
  Formatters._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// 2026-06-12T... → "12 Jun 2026"
  static String date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
}
