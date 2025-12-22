# CSV Data Format Guide - Pakistani Medicine Database

## 📋 Overview

This app uses **2 CSV files** to store all Pakistani medicine data:

1. **`barcodes.csv`** - Product identification and basic info
2. **`ingredients.csv`** - Detailed medical information

---

## 📦 File 1: barcodes.csv

### Purpose:
Maps medicine barcodes to product information. Used when scanning a barcode to identify the medicine.

### Location:
`assets/data/barcodes.csv`

### Format:
```csv
product_name,product_id,barcode,manufacturer,registration_number,description
```

### Column Definitions:

| Column | Type | Required | Description | Example |
|--------|------|----------|-------------|---------|
| `product_name` | TEXT | ✅ YES | Full product name including strength and form | `Panadol 500mg Tablets` |
| `product_id` | TEXT | ✅ YES | Unique identifier (format: PKM###) | `PKM001` |
| `barcode` | TEXT | ✅ YES | EAN-13 or UPC barcode (13 digits) | `8961101620684` |
| `manufacturer` | TEXT | ✅ YES | Manufacturer/company name | `GlaxoSmithKline` |
| `registration_number` | TEXT | ⚠️ OPTIONAL | DRAP registration number | `REG-001-2020` |
| `description` | TEXT | ✅ YES | 1-2 sentence description of what the medicine does | See examples below |

### Rules:
- ✅ **Header row required** (first line must be column names)
- ✅ **No commas in values** (use `|` for separators if needed)
- ✅ **Use quotes** for descriptions with commas: `"A pain reliever, fever reducer"`
- ✅ **Product IDs must be unique** (PKM001, PKM002, PKM003...)
- ✅ **Barcodes must be unique** (no duplicates)
- ⚠️ **Empty optional fields** leave blank or use `N/A`

### Example Row:
```csv
Pulmonol Cough Syrup 120ml,PKM001,8961101620684,Nexpharm Healthcare (Pvt.) Ltd,000874,"A combination cough syrup containing dextromethorphan (cough suppressant) and guaifenesin (expectorant) for relief of cough and chest congestion."
```

### Description Field Guidelines:
**Format:** 1-2 sentences describing what the medicine is and what it treats.

**Good Examples:**
- `"Paracetamol is a pain reliever and fever reducer used to treat mild to moderate pain including headaches, muscle aches, and to reduce fever."`
- `"Ibuprofen is a nonsteroidal anti-inflammatory drug (NSAID) used to reduce fever and treat pain or inflammation."`
- `"A combination antibiotic containing amoxicillin and clavulanic acid, used to treat bacterial infections."`

**Bad Examples:**
- ❌ Too short: `"For pain"`
- ❌ Too vague: `"A medicine"`
- ❌ Too long: Multiple paragraphs of information

---

## 💊 File 2: ingredients.csv

### Purpose:
Contains detailed medical information for each medicine including ingredients, dosage, warnings, interactions, and side effects.

### Location:
`assets/data/ingredients.csv`

### Format:
```csv
product_id,active_ingredients,inactive_ingredients,strength,dosage_form,therapeutic_class,dosage_instructions,warnings,interactions,side_effects
```

### Column Definitions:

| Column | Type | Required | Description | Example |
|--------|------|----------|-------------|---------|
| `product_id` | TEXT | ✅ YES | Links to barcodes.csv (must match!) | `PKM001` |
| `active_ingredients` | TEXT | ✅ YES | Active ingredients (use `\|` separator for multiple) | `Paracetamol` or `Amoxicillin\|Clavulanic Acid` |
| `inactive_ingredients` | TEXT | ⚠️ OPTIONAL | Inactive ingredients (use `\|` separator) | `Starch\|Povidone\|Magnesium Stearate` |
| `strength` | TEXT | ✅ YES | Dosage strength | `500mg` or `120ml` or `625mg` |
| `dosage_form` | TEXT | ✅ YES | Form of medicine | `Tablet`, `Syrup`, `Capsule`, `Suspension` |
| `therapeutic_class` | TEXT | ✅ YES | Drug classification | `Analgesic`, `Antibiotic`, `NSAID`, `Antitussive` |
| `dosage_instructions` | TEXT | ✅ YES | How to take the medicine | See guidelines below |
| `warnings` | TEXT | ✅ YES | Precautions and warnings | See guidelines below |
| `interactions` | TEXT | ✅ YES | Drug/food/alcohol interactions | See guidelines below |
| `side_effects` | TEXT | ✅ YES | Common and rare side effects | See guidelines below |

### Rules:
- ✅ **Header row required**
- ✅ **Product ID must match** an entry in barcodes.csv
- ✅ **Use `|` (pipe) separator** for multiple items in same field
- ✅ **Use quotes** for fields with commas
- ⚠️ **No line breaks** in CSV fields (use periods or semicolons instead)

### Example Row:
```csv
PKM002,Paracetamol,Starch|Povidone|Magnesium Stearate,500mg,Tablet,Analgesic,"Adults and children over 12: 1-2 tablets every 4-6 hours. Maximum 8 tablets per day. Take with water.","Do not exceed recommended dose. Consult doctor if pregnant or breastfeeding. Not for use with severe liver disease.","Avoid alcohol. May interact with warfarin and isoniazid. Consult pharmacist if taking other medications.","Rare: Allergic reactions (rash, swelling). Liver damage possible with overdose. Generally well tolerated at recommended doses."
```

---

## 📝 Field Writing Guidelines

### 1. Active Ingredients
**What to include:** Generic drug names (INN - International Nonproprietary Names)

**Format:**
- Single ingredient: `Paracetamol`
- Multiple ingredients: `Amoxicillin|Clavulanic Acid`
- Use `|` (pipe) to separate

**Examples:**
- ✅ `Paracetamol`
- ✅ `Ibuprofen`
- ✅ `Dextromethorphan|Guaifenesin`
- ❌ `Panadol` (brand name, not generic)

---

### 2. Inactive Ingredients
**What to include:** Fillers, binders, preservatives, colorings

**Format:** Separate with `|`

**Examples:**
- `Starch|Povidone|Magnesium Stearate`
- `Glycerin|Sorbitol|Sodium Benzoate`
- `Microcrystalline Cellulose|Sodium Starch Glycolate`

**If unknown:** Leave blank or use `Not specified`

---

### 3. Dosage Instructions
**What to include:**
- Adult dose
- Child dose (if applicable)
- Frequency (every X hours)
- Maximum daily dose
- How to take (with food, with water, etc.)

**Format:** 2-4 sentences, clear and specific

**Good Examples:**
```
"Adults: 10ml every 4-6 hours. Children 6-12 years: 5ml every 4-6 hours. Not for children under 6."

"Adults and children over 12: 1-2 tablets every 4-6 hours. Maximum 8 tablets per day. Take with water."

"Adults: 1 tablet every 8-12 hours with meals for 7-14 days as prescribed. Complete the full course."
```

**Include:**
- ✅ Specific doses for age groups
- ✅ Time intervals
- ✅ Maximum doses
- ✅ Special instructions (with food, etc.)

**Avoid:**
- ❌ Vague: "Take as directed"
- ❌ Missing maximums
- ❌ No age groups

---

### 4. Warnings
**What to include:**
- Who should NOT take it
- When to consult a doctor
- Pregnancy/breastfeeding warnings
- Medical condition warnings
- Duration warnings

**Format:** 2-4 sentences

**Good Examples:**
```
"Do not exceed recommended dose. Consult doctor if pregnant or breastfeeding. Not for use with severe liver disease."

"Do not use if allergic to any ingredient. Consult doctor if cough persists for more than 7 days. Not recommended during pregnancy without medical advice."

"Not for children under 16 due to risk of Reye's syndrome. Do not use if you have stomach ulcers or bleeding disorders."
```

**Include:**
- ✅ Allergy warnings
- ✅ Age restrictions
- ✅ Medical condition contraindications
- ✅ Pregnancy/breastfeeding warnings
- ✅ Duration limits ("more than 7 days")

---

### 5. Interactions
**What to include:**
- Drug interactions
- Food interactions
- Alcohol interactions
- Vitamin/supplement interactions

**Format:** 1-2 sentences

**Good Examples:**
```
"May interact with MAO inhibitors and SSRIs. Avoid alcohol consumption."

"Avoid alcohol. May interact with warfarin and isoniazid. Consult pharmacist if taking other medications."

"May interact with aspirin, blood thinners, and blood pressure medications. Avoid alcohol."

"Severe reaction with alcohol. May interact with warfarin, lithium, and phenytoin."
```

**Include:**
- ✅ Specific drug names
- ✅ Alcohol warnings if applicable
- ✅ Food restrictions if any
- ✅ General advice ("consult pharmacist")

**If no known interactions:**
- Use: `"No significant interactions known. Consult your pharmacist."`

---

### 6. Side Effects
**What to include:**
- Common side effects
- Rare but serious side effects
- When to seek medical attention

**Format:** 2-3 sentences, separate common vs rare

**Good Examples:**
```
"Common: Drowsiness, dizziness, nausea. Rare: Allergic reactions, stomach upset."

"Rare: Allergic reactions (rash, swelling). Liver damage possible with overdose. Generally well tolerated at recommended doses."

"Common: Stomach upset, heartburn, nausea. Rare: Stomach bleeding, kidney problems, allergic reactions."

"Common: Diarrhea, nausea, skin rash. Rare: Severe allergic reactions, liver problems."
```

**Format:**
- Start with `"Common: "` then list common side effects
- Follow with `"Rare: "` for serious/rare side effects
- Optional: Add general tolerability note

**Include:**
- ✅ Frequency (common vs rare)
- ✅ Severity indicators
- ✅ What to watch for

**If minimal side effects:**
- Use: `"Generally well tolerated. Rare: Allergic reactions. Consult doctor if any unusual symptoms occur."`

---

## 🔗 How the Two Files Work Together

### Data Flow:
```
1. User scans barcode: 8961101620684
   ↓
2. App looks in barcodes.csv
   → Finds: product_id = "PKM001", product_name = "Pulmonol Cough Syrup 120ml"
   ↓
3. App looks in ingredients.csv using product_id = "PKM001"
   → Finds: all medical details (ingredients, dosage, warnings, etc.)
   ↓
4. App displays medicine info page with all 8 sections
```

### Important:
- **Product IDs MUST match** between the two files
- Each `product_id` in ingredients.csv should have a matching entry in barcodes.csv
- Product IDs should be unique and sequential (PKM001, PKM002, PKM003...)

---

## 📊 Complete Example: Adding a New Medicine

Let's add "Calpol 120mg/5ml Suspension"

### Step 1: Add to barcodes.csv
```csv
Calpol 120mg/5ml Suspension,PKM007,8964000000007,GlaxoSmithKline,REG-007-2023,"Paracetamol oral suspension for children, used to reduce fever and relieve mild to moderate pain."
```

### Step 2: Add to ingredients.csv
```csv
PKM007,Paracetamol,Sorbitol|Glycerol|Propylene Glycol,120mg/5ml,Oral Suspension,Analgesic,"Children 3 months-1 year: 2.5-5ml every 4-6 hours. Children 1-6 years: 5-10ml every 4-6 hours. Maximum 4 doses in 24 hours.","Do not exceed recommended dose. Consult doctor before use in infants under 3 months. Not for use if child has liver disease.","Avoid other paracetamol-containing products. May interact with warfarin. Consult pharmacist.","Rare: Allergic reactions (rash, swelling). Very safe when used as directed. Seek medical help if overdose suspected."
```

### Result:
- Barcode `8964000000007` now recognized
- Medicine name: "Calpol 120mg/5ml Suspension"
- All 8 info sections will be populated
- Allergy detection works (checks for Paracetamol)

---

## ✅ Validation Checklist

Before adding a new medicine, verify:

### barcodes.csv:
- [ ] Product ID is unique (not used before)
- [ ] Barcode is unique (13 digits, no duplicates)
- [ ] Product name includes strength and form
- [ ] Description is 1-2 sentences
- [ ] All required fields filled

### ingredients.csv:
- [ ] Product ID matches entry in barcodes.csv
- [ ] Active ingredients use generic names
- [ ] Multiple items separated by `|`
- [ ] Dosage instructions include age groups and maximums
- [ ] Warnings include contraindications
- [ ] Interactions mention alcohol if relevant
- [ ] Side effects separate common vs rare
- [ ] All fields filled (no completely blank fields)

---

## 🚫 Common Mistakes to Avoid

1. ❌ **Using commas without quotes**
   - Wrong: `Panadol 500mg, pain reliever`
   - Right: `"Panadol 500mg, pain reliever"`

2. ❌ **Mismatched product IDs**
   - barcodes.csv has PKM001, ingredients.csv has PKM002 → Won't work!

3. ❌ **Using brand names instead of generic names**
   - Wrong: `Panadol`
   - Right: `Paracetamol`

4. ❌ **Forgetting the header row**
   - First line MUST be column names

5. ❌ **Line breaks in fields**
   - CSV fields cannot contain line breaks
   - Use periods or semicolons instead

6. ❌ **Empty required fields**
   - All fields marked ✅ YES must have values

7. ❌ **Duplicate barcodes or product IDs**
   - Each must be unique

8. ❌ **Missing `|` separator for multiple items**
   - Wrong: `Starch, Povidone, Talc`
   - Right: `Starch|Povidone|Talc`

---

## 📈 Tips for Bulk Data Entry

### Use a spreadsheet editor (Excel, Google Sheets):
1. Open CSV in spreadsheet app
2. Each column = one field
3. Fill in rows
4. Export as CSV (UTF-8 encoding)
5. Verify quotes around fields with commas

### Maintain consistency:
- Use same therapeutic class names (e.g., always "Analgesic" not "Pain Reliever")
- Use same dosage form names (e.g., always "Tablet" not "Tablets")
- Follow same structure for dosage instructions

### Quality check:
- Sort by product_id to verify sequence
- Check for duplicate barcodes
- Verify all product_ids in ingredients.csv exist in barcodes.csv

---

## 🎯 Quick Reference

### Product ID Format:
`PKM001`, `PKM002`, `PKM003`... (sequential)

### Barcode Format:
13-digit EAN-13: `8961101620684`

### Multiple Items Separator:
`|` (pipe character)

### Text with Commas:
Use quotes: `"Text, with, commas"`

### Required Files:
- `assets/data/barcodes.csv` ✅
- `assets/data/ingredients.csv` ✅

---

**Last Updated:** December 2024
**For:** PillKaBoo Pakistani Medicine Database
