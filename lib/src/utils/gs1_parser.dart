import 'package:intl/intl.dart';

/// GS1 DataMatrix parser for Pakistani pharmaceutical packaging
///
/// Supports parsing of GS1 Application Identifiers commonly found on medicine boxes:
/// - (01) GTIN (Global Trade Item Number) - 14 digits
/// - (17) Expiry Date - YYMMDD format
/// - (10) Batch/Lot Number - Variable length
/// - (21) Serial Number - Variable length (optional)
///
/// Example DataMatrix string:
/// "(01)08961100513888(17)270330(10)B019"
///
/// This parser uses best-effort parsing and gracefully handles malformed data.
class GS1Parser {
  /// Parse GS1 DataMatrix raw value and extract structured data
  ///
  /// Returns a map with extracted fields:
  /// - gtin: 14-digit GTIN (from AI 01)
  /// - expiry: Formatted expiry date YYYY-MM-DD (from AI 17)
  /// - batch: Batch/lot number (from AI 10)
  /// - serial: Serial number (from AI 21, if present)
  /// - raw: Original raw value
  ///
  /// Returns null values for fields that couldn't be parsed.
  static Map<String, String?> parseDataMatrix(String raw) {
    final result = {
      'gtin': null,
      'expiry': null,
      'batch': null,
      'serial': null,
      'raw': raw,
    };

    if (raw.isEmpty) return result;

    try {
      // Parse GTIN (AI 01) - 14 digits
      final gtinMatch = RegExp(r'\(01\)(\d{14})').firstMatch(raw);
      if (gtinMatch != null) {
        result['gtin'] = gtinMatch.group(1);
      }

      // Parse Expiry Date (AI 17) - YYMMDD format
      final expiryMatch = RegExp(r'\(17\)(\d{6})').firstMatch(raw);
      if (expiryMatch != null) {
        final yymmdd = expiryMatch.group(1)!;
        result['expiry'] = _parseExpiryDate(yymmdd);
      }

      // Parse Batch Number (AI 10) - Variable length, ends at next ( or end of string
      final batchMatch = RegExp(r'\(10\)([^\(]+)').firstMatch(raw);
      if (batchMatch != null) {
        result['batch'] = batchMatch.group(1)!.trim();
      }

      // Parse Serial Number (AI 21) - Variable length (optional)
      final serialMatch = RegExp(r'\(21\)([^\(]+)').firstMatch(raw);
      if (serialMatch != null) {
        result['serial'] = serialMatch.group(1)!.trim();
      }
    } catch (e) {
      // Parsing failed, but we still have the raw value
      print('GS1Parser: Failed to parse DataMatrix - $e');
    }

    return result;
  }

  /// Parse YYMMDD expiry date to YYYY-MM-DD format
  ///
  /// Handles century detection:
  /// - 00-49 → 2000-2049
  /// - 50-99 → 1950-1999 (unlikely for medicines, but handled)
  ///
  /// Returns null if date is invalid.
  static String? _parseExpiryDate(String yymmdd) {
    if (yymmdd.length != 6) return null;

    try {
      final yy = int.parse(yymmdd.substring(0, 2));
      final mm = int.parse(yymmdd.substring(2, 4));
      final dd = int.parse(yymmdd.substring(4, 6));

      // Determine century (medicines typically have future expiry dates)
      final yyyy = yy < 50 ? 2000 + yy : 1900 + yy;

      // Validate month (1-12)
      if (mm < 1 || mm > 12) return null;

      // Validate day (1-31, basic validation)
      if (dd < 1 || dd > 31) return null;

      // Format as YYYY-MM-DD
      return '$yyyy-${mm.toString().padLeft(2, '0')}-${dd.toString().padLeft(2, '0')}';
    } catch (e) {
      print('GS1Parser: Invalid date format - $yymmdd');
      return null;
    }
  }

  /// Convert EAN-13 (13 digits) to GTIN-14 by adding leading zero
  ///
  /// Example: 8961101620684 → 08961101620684
  static String ean13ToGtin(String ean13) {
    if (ean13.length == 13) {
      return '0$ean13';
    }
    return ean13;
  }

  /// Extract GTIN from raw DataMatrix value
  ///
  /// Convenience method that returns just the GTIN string or null.
  static String? extractGtin(String raw) {
    return parseDataMatrix(raw)['gtin'];
  }

  /// Check if a raw barcode string looks like GS1 DataMatrix format
  ///
  /// Returns true if the string contains GS1 Application Identifiers (AI)
  /// in the format (01), (17), (10), etc.
  static bool isGS1Format(String raw) {
    return raw.contains(RegExp(r'\(\d{2}\)'));
  }

  /// Parse manufacture date (AI 11) - YYMMDD format
  ///
  /// Some Pakistani medicines may include manufacture date.
  /// Returns formatted date YYYY-MM-DD or null if not found.
  static String? parseManufactureDate(String raw) {
    final mfgMatch = RegExp(r'\(11\)(\d{6})').firstMatch(raw);
    if (mfgMatch != null) {
      return _parseExpiryDate(mfgMatch.group(1)!);
    }
    return null;
  }

  /// Format parsed data for display/logging
  ///
  /// Returns a human-readable string representation.
  static String formatParsedData(Map<String, String?> parsed) {
    final buffer = StringBuffer();

    if (parsed['gtin'] != null) {
      buffer.writeln('GTIN: ${parsed['gtin']}');
    }
    if (parsed['expiry'] != null) {
      buffer.writeln('Expiry: ${parsed['expiry']}');
    }
    if (parsed['batch'] != null) {
      buffer.writeln('Batch: ${parsed['batch']}');
    }
    if (parsed['serial'] != null) {
      buffer.writeln('Serial: ${parsed['serial']}');
    }

    return buffer.toString().trim();
  }
}
