# 🇵🇰 Pakistani Medicine Database Migration Guide

## 📋 Overview

This guide explains how to replace the Korean medicine database with Pakistani medicines.

---

## 🗄️ Database Schema Comparison

### **OLD (Korean):**
```
barcodes_table:
  - 한글상품명 (Korean Product Name)
  - 품목기준코드 (Product Standard Code)
  - 표준코드 (Barcode)

ingredients_table:
  - 품목일련번호 (Product Serial Number)
  - 주성분 (Active Ingredients)
```

### **NEW (Pakistani):**
```
barcodes_table:
  - product_name TEXT
  - product_id TEXT
  - barcode TEXT (PRIMARY KEY)
  - manufacturer TEXT
  - registration_number TEXT
  - created_at INTEGER

ingredients_table:
  - product_id TEXT (PRIMARY KEY)
  - active_ingredients TEXT
  - inactive_ingredients TEXT
  - strength TEXT
  - dosage_form TEXT
  - therapeutic_class TEXT
  - created_at INTEGER
```

---

## 🔄 Migration Steps

### **Step 1: Prepare Pakistani Medicine Data**

#### **A. Collect Barcode Data**
Create `assets/data/barcodes_pk.csv`:

```csv
product_name,product_id,barcode,manufacturer,registration_number
Panadol 500mg Tablets,PKM001,8964000000001,GlaxoSmithKline,REG-001-2020
Brufen 400mg Tablets,PKM002,8964000000002,Abbott Laboratories,REG-002-2019
```

**Where to get barcodes:**
1. **DRAP** (Drug Regulatory Authority of Pakistan) - Official registration database
2. **Pakistan Pharmacopoeia** - Official compendium
3. **Scan actual medicine packages** - Use barcode scanner
4. **Pharmaceutical companies** - Request from manufacturers
5. **NADRA eGovernment** - Integrated health databases

**Barcode format for Pakistan:**
- EAN-13: `8964XXXXXXXXX` (Pakistan country code: 896)
- UPC-A: `0XXXXXXXXXXX`

#### **B. Collect Ingredients Data**
Create `assets/data/ingredients_pk.csv`:

```csv
product_id,active_ingredients,inactive_ingredients,strength,dosage_form,therapeutic_class
PKM001,Paracetamol,Starch|Povidone|Magnesium Stearate,500mg,Tablet,Analgesic
PKM002,Ibuprofen,Microcrystalline Cellulose|Sodium Starch Glycolate,400mg,Tablet,NSAID
```

**Where to get ingredients:**
1. **Medicine package inserts** - Full ingredient list
2. **DRAP registration documents**
3. **Pakistan Pharmacopoeia**
4. **Manufacturer product information**

**Note:** Use `|` (pipe) to separate multiple ingredients.

---

### **Step 2: Replace Database Helper Files**

#### **A. Backup Old Files**
```bash
mv lib/src/data/local/database/barcode_db_helper.dart lib/src/data/local/database/barcode_db_helper_korean_backup.dart
mv lib/src/data/local/database/ingredients_db_helper.dart lib/src/data/local/database/ingredients_db_helper_korean_backup.dart
```

#### **B. Rename New Files**
```bash
mv lib/src/data/local/database/barcode_db_helper_pk.dart lib/src/data/local/database/barcode_db_helper.dart
mv lib/src/data/local/database/ingredients_db_helper_pk.dart lib/src/data/local/database/ingredients_db_helper.dart
```

---

### **Step 3: Update References in Code**

Search and replace in these files:

#### **File: `lib/src/data/local/database/barcode_db_helper.dart`**
- ✅ Already updated with new helper

#### **File: `lib/src/data/local/database/ingredients_db_helper.dart`**
- ✅ Already updated with new helper

#### **File: Any code using database:**

**OLD:**
```dart
final matches = await db.query(
  'barcodes_table',
  where: '표준코드 = ?',
  whereArgs: [barcode],
);
String productName = matches[0]['한글상품명'];
String productId = matches[0]['품목기준코드'];
```

**NEW:**
```dart
final matches = await BarcodeDBHelper.searchByBarcode(barcode);
String productName = matches[0]['product_name'];
String productId = matches[0]['product_id'];
String manufacturer = matches[0]['manufacturer'];
```

---

### **Step 4: Update Asset References**

#### **In `pubspec.yaml`:**
```yaml
flutter:
  assets:
    - assets/data/barcodes_pk.csv
    - assets/data/ingredients_pk.csv
    # Remove or keep as backup:
    # - assets/data/barcodes.csv
    # - assets/data/ingredients.csv
```

---

### **Step 5: Clear Old Database**

Add to app initialization (one-time migration):

```dart
// In main.dart after database initialization:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clear old Korean databases (one-time migration)
  await _clearOldDatabases();

  // Initialize new Pakistani databases
  await BarcodeDBHelper.database;
  await IngredientsDBHelper.database;

  runApp(MyApp());
}

Future<void> _clearOldDatabases() async {
  try {
    String path = await getDatabasesPath();
    await deleteDatabase(join(path, 'barcodes.db'));
    await deleteDatabase(join(path, 'ingredients.db'));
    print('Old databases cleared');
  } catch (e) {
    print('Error clearing old databases: $e');
  }
}
```

---

## 📝 Adding More Medicines

### **Method 1: CSV Bulk Import**

1. Add entries to CSV files:
```csv
product_name,product_id,barcode,manufacturer,registration_number
New Medicine,PKM999,8964000000999,Pharma Co,REG-999-2024
```

2. Delete app data (to reload CSV):
```bash
flutter clean
flutter run
```

### **Method 2: Programmatic Addition**

```dart
// Add barcode entry
await BarcodeDBHelper.addMedicine(
  productName: 'Calpol 120mg/5ml Suspension',
  productId: 'PKM100',
  barcode: '8964000000100',
  manufacturer: 'GlaxoSmithKline',
  registrationNumber: 'REG-100-2023',
);

// Add ingredients
await IngredientsDBHelper.addIngredients(
  productId: 'PKM100',
  activeIngredients: 'Paracetamol',
  inactiveIngredients: 'Sorbitol|Glycerol|Propylene Glycol',
  strength: '120mg/5ml',
  dosageForm: 'Oral Suspension',
  therapeuticClass: 'Analgesic',
);
```

### **Method 3: Admin Panel (Future Enhancement)**

Create an admin screen in the app to add medicines:

```dart
// Example admin page
class AdminAddMedicinePage extends StatelessWidget {
  Future<void> _addMedicine() async {
    await BarcodeDBHelper.addMedicine(
      productName: productNameController.text,
      productId: productIdController.text,
      barcode: barcodeController.text,
      manufacturer: manufacturerController.text,
      registrationNumber: regNumberController.text,
    );

    await IngredientsDBHelper.addIngredients(
      productId: productIdController.text,
      activeIngredients: activeIngredientsController.text,
      inactiveIngredients: inactiveIngredientsController.text,
      strength: strengthController.text,
      dosageForm: dosageFormController.text,
      therapeuticClass: therapeuticClassController.text,
    );
  }
}
```

---

## 🔍 Testing Migration

### **Test Checklist:**

1. **Database Creation:**
```bash
flutter clean
flutter run
# Check logs for: "Loaded X Pakistani medicine barcodes"
```

2. **Barcode Scanning:**
   - Scan a Pakistani medicine barcode
   - Verify correct product name displays
   - Verify manufacturer shows

3. **Ingredient Search:**
   - Add user allergies
   - Scan medicine containing allergen
   - Verify allergy warning appears

4. **Data Integrity:**
```dart
// Run in app or debug console
final barcodes = await BarcodeDBHelper.getAllMedicines();
final ingredients = await IngredientsDBHelper.getAllIngredients();
print('Total medicines: ${barcodes.length}');
print('Total ingredient records: ${ingredients.length}');
```

---

## 📊 Data Sources for Pakistani Medicines

### **Official Sources:**

1. **DRAP (Drug Regulatory Authority of Pakistan)**
   - Website: https://www.dra.gov.pk
   - Registered medicines database
   - Product registration details

2. **Pakistan Pharmacopoeia**
   - Official compendium of medicines
   - Standards and specifications

3. **National Database (NADRA)**
   - eGovernment health portals
   - Integrated medicine databases

4. **Pharmaceutical Manufacturers:**
   - GlaxoSmithKline Pakistan
   - Abbott Laboratories Pakistan
   - Sanofi Pakistan
   - Getz Pharma
   - Searle Pakistan
   - Novartis Pakistan

### **Data Collection Methods:**

1. **Manual Data Entry:**
   - Purchase common medicines
   - Scan barcodes with barcode scanner app
   - Extract information from package inserts
   - Enter into CSV

2. **Pharmacy Collaboration:**
   - Partner with pharmacies
   - Request barcode database
   - Verify accuracy

3. **Crowdsourcing:**
   - Build admin panel in app
   - Let pharmacists add medicines
   - Review and approve submissions

4. **Web Scraping (if legal):**
   - Scrape DRAP website
   - Extract medicine information
   - Validate and clean data

---

## 🚨 Important Notes

### **Barcode Format:**
- Pakistan uses EAN-13 (13 digits)
- Country code: `896` or `8964`
- Some medicines may have UPC-A format

### **Ingredient Names:**
- Use **International Nonproprietary Names (INN)**
- Example: Use "Paracetamol" not "Acetaminophen" (for Pakistan)
- Be consistent with naming

### **Database Size:**
- Current: ~50,000 Korean medicines
- Target: Start with top 500-1000 Pakistani medicines
- Expand based on usage data

### **Updates:**
- Plan quarterly updates
- Add new medicines as registered
- Remove discontinued medicines
- Update ingredient information

---

## 🔧 Troubleshooting

### **Issue: CSV not loading**
```
Error: Unable to load asset: assets/data/barcodes_pk.csv
```
**Solution:**
1. Check `pubspec.yaml` has correct asset path
2. Run `flutter clean && flutter pub get`
3. Verify CSV file exists in `assets/data/`

### **Issue: No medicines found**
```
Loaded 0 Pakistani medicine barcodes
```
**Solution:**
1. Check CSV file is not empty
2. Verify CSV has header row
3. Check CSV encoding (should be UTF-8)

### **Issue: Barcode scanning not working**
**Solution:**
1. Verify barcode in database matches scanned code
2. Check barcode format (remove spaces, check digits)
3. Test with `searchByBarcode()` directly

---

## 📈 Scaling for Large Database

For 10,000+ medicines:

```dart
// Add pagination
static Future<List<Map<String, dynamic>>> getAllMedicinesPaged({
  required int page,
  int pageSize = 100,
}) async {
  final Database db = await database;
  return await db.query(
    'barcodes_table',
    limit: pageSize,
    offset: page * pageSize,
  );
}

// Add full-text search index
await db.execute('''
  CREATE VIRTUAL TABLE IF NOT EXISTS barcodes_fts
  USING fts5(product_name, manufacturer);
''');
```

---

## ✅ Migration Checklist

- [ ] Collect Pakistani medicine data (barcodes + ingredients)
- [ ] Create `barcodes_pk.csv` with minimum 100 medicines
- [ ] Create `ingredients_pk.csv` with matching entries
- [ ] Replace database helper files
- [ ] Update `pubspec.yaml` assets
- [ ] Test barcode scanning
- [ ] Test ingredient/allergy search
- [ ] Verify database loads correctly
- [ ] Add migration code to clear old database
- [ ] Test on fresh install
- [ ] Document medicine addition process
- [ ] Plan regular updates

---

## 🎯 Next Steps

1. **Phase 1:** Collect top 500 Pakistani medicines (most commonly prescribed)
2. **Phase 2:** Add ingredient data for all 500
3. **Phase 3:** Test with real users
4. **Phase 4:** Expand to 2,000+ medicines
5. **Phase 5:** Build admin panel for continuous updates
6. **Phase 6:** Partner with pharmacies for data validation

---

## 📞 Support

For questions about migration:
1. Check this guide
2. Review database helper code
3. Test with sample data provided
4. Contact development team

**Last Updated:** December 2024
**Version:** 2.0 (Pakistani Medicine Database)
