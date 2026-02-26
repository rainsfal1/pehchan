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
      version: 7, // Version 7: Force database reload for Surbex barcode fix
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

        // Migration to v6: Just reload CSV data (Surbex barcode value updated)
        if (oldVersion < 6) {
          // Data will be reloaded by loadCsvData() which is called after migration
        }

        // Migration to v7: Force reload to fix Surbex barcode
        if (oldVersion < 7) {
          print('BarcodeDB: Upgrading to v7, will reload CSV data');
          // Data will be reloaded by loadCsvData() which is called after migration
        }
      },
    );
  }

  static Future<void> loadCsvData(Database db) async {
    try {
      // Clear existing data
      print('BarcodeDB: Clearing existing data...');
      await db.delete('barcodes_table');
      print('BarcodeDB: Data cleared');

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
          final barcodeValue = row[2]?.toString().trim() ?? '';
          final productName = row[0]?.toString().trim() ?? '';

          // Skip empty rows (important: prevents PRIMARY KEY constraint violations)
          if (barcodeValue.isEmpty || productName.isEmpty) {
            print('BarcodeDB: Skipping empty row');
            continue;
          }

          batch.insert('barcodes_table', {
            'product_name': productName,
            'product_id': row[1]?.toString() ?? '',
            'barcode': barcodeValue,
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

          print('BarcodeDB: Inserting $productName with barcode: "$barcodeValue"');
          rowCount++;
        }
      }

      // Commit with error handling (changed from noResult: true to capture errors)
      final results = await batch.commit();
      print('BarcodeDB: Loaded $rowCount medicines from CSV');
      print('BarcodeDB: Batch commit returned ${results.length} results');
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
  /// 4. Try batch number match (for medicines with batch-based DataMatrix)
  /// 5. For EAN-13, try without check digit (partial match)
  static Future<List<Map<String, dynamic>>> searchByBarcode(String inputBarcode) async {
    inputBarcode = inputBarcode.trim();

    // Remove GS1 control characters that may prefix DataMatrix barcodes
    // ASCII 29 (0x1D) = GS (Group Separator) - common in GS1 DataMatrix
    if (inputBarcode.isNotEmpty && inputBarcode.codeUnitAt(0) == 29) {
      inputBarcode = inputBarcode.substring(1);
      print('BarcodeDB: Stripped GS1 control character from barcode');
    }

    if (inputBarcode.isEmpty) {
      return [];
    }

    final Database db = await database;
    List<Map<String, dynamic>> matches = [];

    // Debug: Check total records in database
    final allRecords = await db.query('barcodes_table');
    print('BarcodeDB: Total records in database: ${allRecords.length}');
    if (allRecords.isNotEmpty) {
      print('BarcodeDB: ALL barcodes in DB:');
      for (var record in allRecords) {
        final barcode = record['barcode'] as String;
        print('  - "$barcode" (${record['product_name']}) [length: ${barcode.length}]');

        // Show bytes for Surbex barcode to compare with input
        if (barcode.contains('0108002660023')) {
          print('    Surbex barcode bytes: ${barcode.codeUnits}');
        }
      }
    }

    // Step 1: Try exact match on barcode column
    print('BarcodeDB: Searching for exact match: "$inputBarcode"');
    print('BarcodeDB: Input barcode length: ${inputBarcode.length}');
    print('BarcodeDB: Input barcode bytes: ${inputBarcode.codeUnits}');

    matches = await db.query(
      'barcodes_table',
      where: 'barcode = ?',
      whereArgs: [inputBarcode],
    );

    print('BarcodeDB: Exact match query returned ${matches.length} results');

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

    // Step 4: Try batch number match (for medicines with batch-based DataMatrix)
    matches = await db.query(
      'barcodes_table',
      where: 'batch = ?',
      whereArgs: [inputBarcode],
    );

    if (matches.isNotEmpty) return matches;

    // Step 5: For EAN-13, try without check digit (Pakistani barcode fallback)
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
