class StringHelper {
  /// Safely get the first character of a string
  /// Returns 'U' if string is null or empty
  static String getFirstChar(String? text) {
    if (text == null || text.isEmpty) {
      return 'U';
    }
    return text[0].toUpperCase();
  }
}