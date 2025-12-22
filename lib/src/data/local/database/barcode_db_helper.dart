import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../../../utils/gs1_parser.dart';

/// Pakistani Medicine Barcode Database Helper
///
/// Supports multiple barcode formats:
/// - EAN-13 (13-digit linear barcodes)
/// - GS1 DataMatrix (2D barcodes with encoded GTIN, expiry, batch)
/// - Code-128, QR codes
class BarcodeDBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db == null) {
      _db = await initializeDB();
      await loadCsvData(_db!);
    }
    return _db!;
  }

  static Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'barcodes.db');

    return await openDatabase(
      dbPath,
      version: 5, // Version 5: Add DataMatrix/GS1 support
      onCreate: (Database db, int version) async {
        // New table with GS1 DataMatrix support
        await db.execute('''
          CREATE TABLE IF NOT EXISTS barcodes_table (
            product_name TEXT NOT NULL,
            product_id TEXT NOT NULL,
            barcode TEXT PRIMARY KEY,
            barcode_format TEXT DEFAULT 'EAN13',
            gtin TEXT,
            batch TEXT,
            mfg_date TEXT,
            expiry_date TEXT,
            manufacturer TEXT,
            registration_number TEXT,
            description TEXT,
            mrp TEXT,
            created_at INTEGER DEFAULT (strftime('%s', 'now'))
          )
        ''');

        // Indexes for fast searching
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_barcode ON barcodes_table(barcode);'
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_gtin ON barcodes_table(gtin);'
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_product_id ON barcodes_table(product_id);'
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_product_name ON barcodes_table(product_name);'
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_batch ON barcodes_table(batch);'
        );
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // Migration from Korean to Pakistani schema
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS barcodes_table');
        }

        // Migration to v5 (add GS1/DataMatrix columns)
        if (oldVersion < 5) {
          // Drop and recreate with new schema
          await db.execute('DROP TABLE IF EXISTS barcodes_table');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS barcodes_table (
              product_name TEXT NOT NULL,
              product_id TEXT NOT NULL,
              barcode TEXT PRIMARY KEY,
              barcode_format TEXT DEFAULT 'EAN13',
              gtin TEXT,
              batch TEXT,
              mfg_date TEXT,
              expiry_date TEXT,
              manufacturer TEXT,
              registration_number TEXT,
              description TEXT,
              mrp TEXT,
              created_at INTEGER DEFAULT (strftime('%s', 'now'))
            )
          ''');

          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_barcode ON barcodes_table(barcode);'
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_gtin ON barcodes_table(gtin);'
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_product_id ON barcodes_table(product_id);'
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_product_name ON barcodes_table(product_name);'
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_batch ON barcodes_table(batch);'
          );
        }
      },
    );
  }

  static Future<void> loadCsvData(Database db) async {
    try {
      // Clear existing data
      await db.delete('barcodes_table');

      // Load Pakistani medicine data
      final String csvData = await rootBundle.loadString(
        'assets/data/barcodes.csv'
      );

      // Force LF line endings since our asset CSVs use \n, otherwise everything gets read as one row
      List<List<dynamic>> csvTable = const CsvToListConverter(
        eol: '\n',
      ).convert(csvData);

      if (csvTable.isEmpty) {
        return;
      }

      Batch batch = db.batch();
      int rowCount = 0;

      // Skip header row
      // CSV columns: product_name,product_id,barcode,barcode_format,gtin,batch,mfg_date,expiry_date,manufacturer,registration_number,description,mrp
      for (var row in csvTable.skip(1)) {
        if (row.length >= 3) {
          batch.insert('barcodes_table', {
            'product_name': row[0]?.toString() ?? '',
            'product_id': row[1]?.toString() ?? '',
            'barcode': row[2]?.toString() ?? '',
            'barcode_format': row.length > 3 ? row[3]?.toString() : 'EAN13',
            'gtin': row.length > 4 ? row[4]?.toString() : null,
            'batch': row.length > 5 ? row[5]?.toString() : null,
            'mfg_date': row.length > 6 ? row[6]?.toString() : null,
            'expiry_date': row.length > 7 ? row[7]?.toString() : null,
            'manufacturer': row.length > 8 ? row[8]?.toString() : null,
            'registration_number': row.length > 9 ? row[9]?.toString() : null,
            'description': row.length > 10 ? row[10]?.toString() : null,
            'mrp': row.length > 11 ? row[11]?.toString() : null,
          });
          rowCount++;
        }
      }

      await batch.commit(noResult: true);
    } catch (e) {
      print('Error loading barcode data: $e');
      rethrow;
    }
  }

  /// Search by barcode (supports EAN-13, DataMatrix, Code-128, etc.)
  ///
  /// Search strategy:
  /// 1. Try exact match on barcode column
  /// 2. If DataMatrix/GS1 format, extract GTIN and search by GTIN
  /// 3. Try GTIN column match
  /// 4. For EAN-13, try without check digit (partial match)
  static Future<List<Map<String, dynamic>>> searchByBarcode(String inputBarcode) async {
    inputBarcode = inputBarcode.trim();

    if (inputBarcode.isEmpty) {
      return [];
    }

    final Database db = await database;
    List<Map<String, dynamic>> matches = [];

    // Step 1: Try exact match on barcode column
    matches = await db.query(
      'barcodes_table',
      where: 'barcode = ?',
      whereArgs: [inputBarcode],
    );

    if (matches.isNotEmpty) return matches;

    // Step 2: If GS1 format, extract GTIN and search
    if (GS1Parser.isGS1Format(inputBarcode)) {
      final parsed = GS1Parser.parseDataMatrix(inputBarcode);
      if (parsed['gtin'] != null) {
        matches = await db.query(
          'barcodes_table',
          where: 'gtin = ? OR barcode = ?',
          whereArgs: [parsed['gtin'], parsed['gtin']],
        );
        if (matches.isNotEmpty) return matches;
      }
    }

    // Step 3: Try GTIN column match (for direct GTIN input)
    matches = await db.query(
      'barcodes_table',
      where: 'gtin = ?',
      whereArgs: [inputBarcode],
    );

    if (matches.isNotEmpty) return matches;

    // Step 4: For EAN-13, try without check digit (Pakistani barcode fallback)
    if (inputBarcode.startsWith('8') && inputBarcode.length == 13) {
      String withoutCheckDigit = inputBarcode.substring(0, 12);
      matches = await db.query(
        'barcodes_table',
        where: 'barcode LIKE ?',
        whereArgs: ['$withoutCheckDigit%'],
      );
    }

    return matches;
  }

  /// Search by product name
  static Future<List<Map<String, dynamic>>> searchByName(String productName) async {
    if (productName.trim().isEmpty) {
      return [];
    }

    final Database db = await database;
    return await db.query(
      'barcodes_table',
      where: 'product_name LIKE ?',
      whereArgs: ['%$productName%'],
      limit: 50,
    );
  }

  /// Get all medicines (for admin/debugging)
  static Future<List<Map<String, dynamic>>> getAllMedicines() async {
    final Database db = await database;
    return await db.query('barcodes_table', limit: 1000);
  }

  /// Add a new medicine entry
  static Future<int> addMedicine({
    required String productName,
    required String productId,
    required String barcode,
    String barcodeFormat = 'EAN13',
    String? gtin,
    String? batch,
    String? mfgDate,
    String? expiryDate,
    String? manufacturer,
    String? registrationNumber,
    String? description,
    String? mrp,
  }) async {
    final Database db = await database;
    return await db.insert('barcodes_table', {
      'product_name': productName,
      'product_id': productId,
      'barcode': barcode,
      'barcode_format': barcodeFormat,
      'gtin': gtin,
      'batch': batch,
      'mfg_date': mfgDate,
      'expiry_date': expiryDate,
      'manufacturer': manufacturer,
      'registration_number': registrationNumber,
      'description': description,
      'mrp': mrp,
    });
  }

  /// Delete all data and reset
  static Future<void> clearDatabase() async {
    final Database db = await database;
    await db.delete('barcodes_table');
  }
}
