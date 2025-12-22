import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

/// Pakistani Medicine Ingredients Database Helper
class IngredientsDBHelper {
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
    String dbPath = join(path, 'ingredients.db');

    return await openDatabase(
      dbPath,
      version: 4, // Increment version for schema cleanup (remove interactions)
      onCreate: (Database db, int version) async {
        // New table with English column names
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ingredients_table (
            product_id TEXT PRIMARY KEY,
            active_ingredients TEXT NOT NULL,
            inactive_ingredients TEXT,
            strength TEXT,
            dosage_form TEXT,
            therapeutic_class TEXT,
            dosage_instructions TEXT,
            warnings TEXT,
            side_effects TEXT,
            created_at INTEGER DEFAULT (strftime('%s', 'now'))
          )
        ''');

        // Indexes for fast searching
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_product_id ON ingredients_table(product_id);'
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_active_ingredients ON ingredients_table(active_ingredients);'
        );
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // Migration from Korean to Pakistani schema
        if (oldVersion < 2) {
          // Drop old Korean table
          await db.execute('DROP TABLE IF EXISTS ingredients_table');

          // Create new table
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ingredients_table (
              product_id TEXT PRIMARY KEY,
              active_ingredients TEXT NOT NULL,
              inactive_ingredients TEXT,
              strength TEXT,
              dosage_form TEXT,
              therapeutic_class TEXT,
              dosage_instructions TEXT,
              warnings TEXT,
              side_effects TEXT,
              created_at INTEGER DEFAULT (strftime('%s', 'now'))
            )
          ''');

          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_product_id ON ingredients_table(product_id);'
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_active_ingredients ON ingredients_table(active_ingredients);'
          );
        }

        // Migration from v2 to v3 (add detailed medicine info columns)
        if (oldVersion < 3) {
          // Drop and recreate table with new columns
          await db.execute('DROP TABLE IF EXISTS ingredients_table');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS ingredients_table (
              product_id TEXT PRIMARY KEY,
              active_ingredients TEXT NOT NULL,
              inactive_ingredients TEXT,
              strength TEXT,
              dosage_form TEXT,
              therapeutic_class TEXT,
              dosage_instructions TEXT,
              warnings TEXT,
              side_effects TEXT,
              created_at INTEGER DEFAULT (strftime('%s', 'now'))
            )
          ''');

          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_product_id ON ingredients_table(product_id);'
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_active_ingredients ON ingredients_table(active_ingredients);'
          );
        }

        // Migration from v3 to v4 (remove interactions column)
        if (oldVersion < 4) {
          await db.execute('DROP TABLE IF EXISTS ingredients_table');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS ingredients_table (
              product_id TEXT PRIMARY KEY,
              active_ingredients TEXT NOT NULL,
              inactive_ingredients TEXT,
              strength TEXT,
              dosage_form TEXT,
              therapeutic_class TEXT,
              dosage_instructions TEXT,
              warnings TEXT,
              side_effects TEXT,
              created_at INTEGER DEFAULT (strftime('%s', 'now'))
            )
          ''');

          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_product_id ON ingredients_table(product_id);'
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_active_ingredients ON ingredients_table(active_ingredients);'
          );
        }
      },
    );
  }

  static Future<void> loadCsvData(Database db) async {
    try {
      // Clear existing data
      await db.delete('ingredients_table');

      // Load Pakistani medicine ingredients
      final String csvData = await rootBundle.loadString(
        'assets/data/medicine_details.csv'
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
      for (var row in csvTable.skip(1)) {
        if (row.length >= 2) {
          batch.insert('ingredients_table', {
            'product_id': row[0]?.toString() ?? '',
            'active_ingredients': row[1]?.toString() ?? '',
            'inactive_ingredients': row.length > 2 ? row[2]?.toString() : null,
            'strength': row.length > 3 ? row[3]?.toString() : null,
            'dosage_form': row.length > 4 ? row[4]?.toString() : null,
            'therapeutic_class': row.length > 5 ? row[5]?.toString() : null,
            'dosage_instructions': row.length > 6 ? row[6]?.toString() : null,
            'warnings': row.length > 7 ? row[7]?.toString() : null,
            'side_effects': row.length > 8 ? row[8]?.toString() : null,
          });
          rowCount++;
        }
      }

      await batch.commit(noResult: true);
    } catch (e) {
      print('Error loading ingredients data: $e');
      rethrow;
    }
  }

  /// Search ingredients by product ID
  static Future<List<Map<String, dynamic>>> searchIngredientsByProductId(
    String productId
  ) async {
    productId = productId.trim();

    if (productId.isEmpty) {
      return [];
    }

    final Database db = await database;
    return await db.query(
      'ingredients_table',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  /// Search for medicines containing specific allergens
  /// Returns list of product IDs that contain any of the user's allergies
  static Future<List<Map<String, dynamic>>> searchIngredientsByAllergies(
    List<String> userAllergies
  ) async {
    if (userAllergies.isEmpty) {
      return [];
    }

    final Database db = await database;

    // Build OR condition for each allergen (case-insensitive)
    final conditions = userAllergies.map((allergen) {
      return 'LOWER(active_ingredients) LIKE ? OR LOWER(inactive_ingredients) LIKE ?';
    }).join(' OR ');

    // Create argument list (each allergen appears twice for active and inactive)
    final args = userAllergies.expand((allergen) {
      final searchTerm = '%${allergen.toLowerCase()}%';
      return [searchTerm, searchTerm];
    }).toList();

    return await db.query(
      'ingredients_table',
      where: conditions,
      whereArgs: args,
    );
  }

  /// Parse ingredients string into list (handles | separator)
  static List<String> parseIngredients(String ingredientsString) {
    if (ingredientsString.isEmpty) {
      return [];
    }

    return ingredientsString
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Check if a medicine contains any allergen
  static Future<bool> containsAllergen(
    String productId,
    List<String> userAllergies
  ) async {
    if (userAllergies.isEmpty) {
      return false;
    }

    final results = await searchIngredientsByProductId(productId);

    if (results.isEmpty) {
      return false;
    }

    final activeIngredients = results.first['active_ingredients']?.toString().toLowerCase() ?? '';
    final inactiveIngredients = results.first['inactive_ingredients']?.toString().toLowerCase() ?? '';

    for (final allergen in userAllergies) {
      final allergenLower = allergen.toLowerCase();
      if (activeIngredients.contains(allergenLower) ||
          inactiveIngredients.contains(allergenLower)) {
        return true;
      }
    }

    return false;
  }

  /// Add a new ingredient entry
  static Future<int> addIngredients({
    required String productId,
    required String activeIngredients,
    String? inactiveIngredients,
    String? strength,
    String? dosageForm,
    String? therapeuticClass,
  }) async {
    final Database db = await database;
    return await db.insert('ingredients_table', {
      'product_id': productId,
      'active_ingredients': activeIngredients,
      'inactive_ingredients': inactiveIngredients,
      'strength': strength,
      'dosage_form': dosageForm,
      'therapeutic_class': therapeuticClass,
    });
  }

  /// Get all ingredients (for admin/debugging)
  static Future<List<Map<String, dynamic>>> getAllIngredients() async {
    final Database db = await database;
    return await db.query('ingredients_table', limit: 1000);
  }

  /// Delete all data and reset
  static Future<void> clearDatabase() async {
    final Database db = await database;
    await db.delete('ingredients_table');
  }
}
