class DurationParser {
  // Regex patterns for duration extraction
  static final List<RegExp> _patterns = [
    RegExp(r'(\d+)\s*days?', caseSensitive: false),
    RegExp(r'(\d+)\s*weeks?', caseSensitive: false),
    RegExp(r'(\d+)\s*months?', caseSensitive: false),
  ];

  static String? extractDuration(String text) {
    // Try numeric patterns first
    for (var pattern in _patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final number = match.group(1);
        String unit;

        if (pattern.pattern.contains('week')) {
          unit = number == '1' ? 'week' : 'weeks';
        } else if (pattern.pattern.contains('month')) {
          unit = number == '1' ? 'month' : 'months';
        } else {
          unit = number == '1' ? 'day' : 'days';
        }

        return '$number $unit';
      }
    }

    // Try word-based patterns
    if (text.toLowerCase().contains('one week')) {
      return '1 week';
    }
    if (text.toLowerCase().contains('two week')) {
      return '2 weeks';
    }

    return null;
  }

  static bool hasDuration(String text) {
    return extractDuration(text) != null;
  }
}
