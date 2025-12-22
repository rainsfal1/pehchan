import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/pillkaboo_util.dart';
import '../../../app/tts/tts_service.dart';
import '../../../app/notification_service.dart';
import '../../../utils/reminder_calculator.dart';
import '../../styles/pillkaboo_theme.dart';
import '../../widgets/index.dart' as widgets;
import 'package:go_router/go_router.dart';

import 'my_medicines_page_model.dart';
export 'my_medicines_page_model.dart';

class MyMedicinesPageWidget extends StatefulWidget {
  const MyMedicinesPageWidget({super.key});

  @override
  State<MyMedicinesPageWidget> createState() => _MyMedicinesPageWidgetState();
}

class _MyMedicinesPageWidgetState extends State<MyMedicinesPageWidget> {
  late MyMedicinesPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _manualNameController = TextEditingController();
  final TextEditingController _manualCategoryController = TextEditingController();
  final TextEditingController _manualNoteController = TextEditingController();
  List<String> _categorySuggestions(PKBLocalizations loc) => [
        loc.getText('category_pain_relief').isNotEmpty
            ? loc.getText('category_pain_relief')
            : 'Pain relief',
        loc.getText('category_antibiotic').isNotEmpty
            ? loc.getText('category_antibiotic')
            : 'Antibiotic',
        loc.getText('category_cold_cough').isNotEmpty
            ? loc.getText('category_cold_cough')
            : 'Cold & cough',
        loc.getText('category_vitamin').isNotEmpty
            ? loc.getText('category_vitamin')
            : 'Vitamin',
        loc.getText('category_allergy').isNotEmpty
            ? loc.getText('category_allergy')
            : 'Allergy',
      ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyMedicinesPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    _manualNameController.dispose();
    _manualCategoryController.dispose();
    _manualNoteController.dispose();
    super.dispose();
  }

  String _formatDate(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  void _showDeleteConfirmation(int index, String medicineName) {
    final loc = PKBLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
            decoration: BoxDecoration(
              color: PKBAppState().tertiaryColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: PKBAppState().secondaryColor.withOpacity(0.4),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.getText('delete_medicine'),
                  style: TextStyle(
                    color: PKBAppState().secondaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  loc.getText('delete_medicine_confirm').replaceAll('{medicineName}', medicineName),
                  style: TextStyle(
                    color: PKBAppState().secondaryColor,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          highlightColor: PKBAppState().secondaryColor.withOpacity(0.1),
                          splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: PKBAppState().secondaryColor.withOpacity(0.6),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              loc.getText('cancel'),
                              style: TextStyle(
                                color: PKBAppState().secondaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: PKBAppState().primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          highlightColor: PKBAppState().tertiaryColor.withOpacity(0.1),
                          splashColor: PKBAppState().tertiaryColor.withOpacity(0.12),
                          onTap: () async {
                            final medicineId = PKBAppState().savedMedicines[index]['id'];
                            await NotificationService().cancelRemindersForMedicine(medicineId);

                            setState(() {
                              PKBAppState().removeMedicineAt(index);
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: PKBAppState().primaryColor,
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              loc.getText('delete'),
                              style: TextStyle(
                                color: PKBAppState().tertiaryColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showManualAddDialog() {
    final loc = PKBLocalizations.of(context);
    bool showDetails = false;
    String selectedCategory = '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                  decoration: BoxDecoration(
                    color: PKBAppState().tertiaryColor,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: PKBAppState().secondaryColor.withOpacity(0.4),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.getText('manual_add_header').isNotEmpty
                            ? loc.getText('manual_add_header')
                            : 'Add medicine',
                        style: TextStyle(
                          color: PKBAppState().secondaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _manualNameController,
                        autofocus: true,
                        style: TextStyle(color: PKBAppState().secondaryColor, fontSize: 20),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: PKBAppState().tertiaryColor,
                          labelText: loc.getText('manual_add_name').isNotEmpty
                              ? loc.getText('manual_add_name')
                              : 'Medicine name *',
                          labelStyle: TextStyle(color: PKBAppState().secondaryColor.withOpacity(0.7)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: PKBAppState().secondaryColor.withOpacity(0.4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: PKBAppState().secondaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        onTap: () => setStateDialog(() => showDetails = !showDetails),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              showDetails
                                  ? (loc.getText('manual_hide_details').isNotEmpty
                                      ? loc.getText('manual_hide_details')
                                      : 'Hide details')
                                  : (loc.getText('manual_add_details').isNotEmpty
                                      ? loc.getText('manual_add_details')
                                      : 'More details (optional)'),
                              style: TextStyle(
                                color: PKBAppState().secondaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            Icon(
                              showDetails ? Icons.expand_less : Icons.expand_more,
                              color: PKBAppState().secondaryColor.withOpacity(0.8),
                            ),
                          ],
                        ),
                      ),
                      if (showDetails) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _categorySuggestions(loc).map((c) {
                            final isSelected = selectedCategory == c;
                            final isDarkBg = PKBAppState().tertiaryColor.computeLuminance() < 0.5;
                            final bgColor = PKBAppState().tertiaryColor;
                            final accentColor = PKBAppState().secondaryColor;

                            // Selected state: adapt to background brightness
                            final selectedFill = isDarkBg
                                ? Color.lerp(bgColor, Colors.white, 0.2)! // Glowy white for dark backgrounds
                                : Color.lerp(bgColor, accentColor, 0.15)!; // Slightly darker for light backgrounds

                            // Base fill matches the actual background
                            final baseFill = bgColor;

                            return ChoiceChip(
                              label: Text(c),
                              selected: isSelected,
                              onSelected: (_) {
                                setStateDialog(() {
                                  selectedCategory = c;
                                  _manualCategoryController.text = c;
                                });
                              },
                              selectedColor: selectedFill,
                              backgroundColor: baseFill,
                              checkmarkColor: accentColor,
                              labelStyle: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w700,
                              ),
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: accentColor.withOpacity(isSelected ? 1.0 : 0.6),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _manualCategoryController,
                          style: TextStyle(color: PKBAppState().secondaryColor, fontSize: 20),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: PKBAppState().tertiaryColor,
                            labelText: loc.getText('category_label').isNotEmpty
                                ? loc.getText('category_label')
                                : 'Category (optional)',
                            labelStyle: TextStyle(color: PKBAppState().secondaryColor.withOpacity(0.7)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: PKBAppState().secondaryColor.withOpacity(0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: PKBAppState().secondaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _manualNoteController,
                          maxLines: 3,
                          style: TextStyle(color: PKBAppState().secondaryColor, fontSize: 20),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: PKBAppState().tertiaryColor,
                            labelText: loc.getText('manual_add_note').isNotEmpty
                                ? loc.getText('manual_add_note')
                                : 'Note (optional)',
                            labelStyle: TextStyle(color: PKBAppState().secondaryColor.withOpacity(0.7)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: PKBAppState().secondaryColor.withOpacity(0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: PKBAppState().secondaryColor),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10.0),
                                highlightColor: PKBAppState().secondaryColor.withOpacity(0.1),
                                splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                      color: PKBAppState().secondaryColor.withOpacity(0.6),
                                      width: 1.0,
                                    ),
                                  ),
                            child: Text(
                              loc.getText('cancel'),
                              style: TextStyle(
                                color: PKBAppState().secondaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                          child: Material(
                            color: PKBAppState().primaryColor,
                            borderRadius: BorderRadius.circular(10.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.0),
                              highlightColor: PKBAppState().tertiaryColor.withOpacity(0.1),
                              splashColor: PKBAppState().tertiaryColor.withOpacity(0.12),
                              onTap: () {
                                final name = _manualNameController.text.trim();
                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        loc.getText('manual_add_error').isNotEmpty
                                            ? loc.getText('manual_add_error')
                                            : 'Please enter a medicine name',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                final category = _manualCategoryController.text.trim().isEmpty
                                    ? (loc.getText('category_general').isNotEmpty
                                        ? loc.getText('category_general')
                                        : 'General')
                                    : _manualCategoryController.text.trim();
                                final note = _manualNoteController.text.trim();

                                PKBAppState().addMedicine(name, category, 'manual', note: note);

                                Navigator.of(context).pop();
                                _manualNameController.clear();
                                _manualCategoryController.clear();
                                _manualNoteController.clear();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      loc.getText('manual_added_snackbar').isNotEmpty
                                          ? loc.getText('manual_added_snackbar')
                                          : 'Medicine added. Add reminders?',
                                    ),
                                    action: SnackBarAction(
                                      label: loc.getText('manual_add_reminders').isNotEmpty
                                          ? loc.getText('manual_add_reminders')
                                          : 'Add reminders',
                                      textColor: PKBAppState().primaryColor,
                                      onPressed: () {
                                        context.push('/prescribedMedRecognitionPage');
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: PKBAppState().primaryColor,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  loc.getText('manual_save').isNotEmpty
                                      ? loc.getText('manual_save')
                                      : 'Save',
                                  style: TextStyle(
                                    color: PKBAppState().tertiaryColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    final loc = PKBLocalizations.of(context);
    context.watch<PKBAppState>();

    double appBarFontSize = 32.0 / 892.0 * MediaQuery.of(context).size.height;
    double medicineNameSize = 24.0 / 892.0 * MediaQuery.of(context).size.height;
    double secondaryTextSize = 16.0 / 892.0 * MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: PKBAppState().tertiaryColor,
        appBar: AppBar(
          backgroundColor: PKBAppState().tertiaryColor,
          automaticallyImplyLeading: false,
          title: Semantics(
            container: true,
            label: loc.getText('my_medicines'),
            child: ExcludeSemantics(
              excluding: true,
              child: Text(
                loc.getText('my_medicines'),
                style: PillKaBooTheme.of(context).headlineMedium.override(
                  fontFamily: PillKaBooTheme.of(context).headlineMediumFamily,
                  color: PKBAppState().secondaryColor,
                  fontSize: appBarFontSize,
                  fontWeight: FontWeight.bold,
                  useGoogleFonts: GoogleFonts.asMap().containsKey(
                    PillKaBooTheme.of(context).headlineMediumFamily,
                  ),
                ),
              ),
            ),
          ),
          actions: const [
            widgets.HomeButtonWidget(),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Material(
                  color: PKBAppState().tertiaryColor,
                  borderRadius: BorderRadius.circular(20.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    highlightColor: PKBAppState().secondaryColor.withOpacity(0.1),
                    splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
                    onTap: _showManualAddDialog,
                    onLongPress: _showManualAddDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: PKBAppState().secondaryColor.withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          loc.getText('add_medicine').isNotEmpty
                              ? loc.getText('add_medicine')
                              : 'Add medicine',
                          style: TextStyle(
                            color: PKBAppState().secondaryColor,
                            fontSize: medicineNameSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PKBAppState().savedMedicines.isEmpty
                    ? Center(
                        child: Semantics(
                          container: true,
                          label: loc.getText('no_medicines_yet'),
                          child: Text(
                            loc.getText('no_medicines_yet'),
                            style: TextStyle(
                              color: PKBAppState().secondaryColor.withOpacity(0.6),
                              fontSize: medicineNameSize,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12.0),
                        itemCount: PKBAppState().savedMedicines.length,
                        itemBuilder: (context, index) {
                          final medicine = PKBAppState().savedMedicines[index];
                          final medicineName = medicine['medicineName'] as String;
                          final addedDate = medicine['addedDate'] as int;

                          return Dismissible(
                            key: Key(medicine['id']),
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Icon(
                                Icons.delete,
                                color: PKBAppState().secondaryColor,
                                size: 30,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              _showDeleteConfirmation(index, medicineName);
                              return false;
                            },
                            child: Semantics(
                              container: true,
                              label: '$medicineName, ${PKBAppState().formatInstructions(medicine)}, added ${_formatDate(addedDate)}',
                              onTap: () {
                                if (!PKBAppState().useScreenReader && !PKBAppState().silentMode) {
                                  TtsService().stop();
                                  String spokenText = medicineName;
                                  if (PKBAppState().medicineHasInstructions(medicine)) {
                                    spokenText += '. Take ${PKBAppState().formatInstructions(medicine)}';
                                  } else {
                                    spokenText += '. No schedule set';
                                  }
                                  TtsService().speak(spokenText);
                                }
                              },
                              onLongPress: () {
                                _showDeleteConfirmation(index, medicineName);
                              },
                              child: InkWell(
                                onTap: () {
                                  if (!PKBAppState().useScreenReader && !PKBAppState().silentMode) {
                                    TtsService().stop();
                                    String spokenText = medicineName;
                                    if (PKBAppState().medicineHasInstructions(medicine)) {
                                      spokenText += '. Take ${PKBAppState().formatInstructions(medicine)}';
                                    } else {
                                      spokenText += '. No schedule set';
                                    }
                                    TtsService().speak(spokenText);
                                  }
                                },
                                onLongPress: () {
                                  _showDeleteConfirmation(index, medicineName);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: PKBAppState().secondaryColor,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ExcludeSemantics(
                                              excluding: true,
                                              child: Text(
                                                medicineName,
                                                style: TextStyle(
                                                  color: PKBAppState().secondaryColor,
                                                  fontSize: medicineNameSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      ExcludeSemantics(
                                        excluding: true,
                                        child: Text(
                                          PKBAppState().formatInstructions(medicine),
                                          style: TextStyle(
                                            color: PKBAppState().medicineHasInstructions(medicine)
                                                ? PKBAppState().primaryColor
                                                : PKBAppState().secondaryColor.withOpacity(0.6),
                                            fontSize: secondaryTextSize,
                                            fontWeight: PKBAppState().medicineHasInstructions(medicine)
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      // Next dose time (only show if reminder is enabled)
                                      if (PKBAppState().medicineHasInstructions(medicine) &&
                                          PKBAppState().isReminderEnabled(medicine['id']))
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: ExcludeSemantics(
                                            excluding: true,
                                            child: Builder(
                                              builder: (context) {
                                                final nextTime = ReminderCalculator.getNextReminderTime(medicine);
                                                if (nextTime != null) {
                                                  final timeUntil = ReminderCalculator.formatTimeUntil(nextTime);
                                                  return Text(
                                                    timeUntil == 'now' ? 'Dose due now' : 'Next dose in $timeUntil',
                                                    style: TextStyle(
                                                      color: timeUntil == 'now'
                                                          ? Colors.red
                                                          : PKBAppState().secondaryColor.withOpacity(0.8),
                                                      fontSize: secondaryTextSize - 1,
                                                      fontWeight: timeUntil == 'now' ? FontWeight.bold : FontWeight.w500,
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                        ),
                                      // Footer row: added date + reminder toggle
                                      if (PKBAppState().medicineHasInstructions(medicine))
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: ExcludeSemantics(
                                                  excluding: true,
                                                  child: Text(
                                                    'Added ${_formatDate(addedDate)}',
                                                    style: TextStyle(
                                                      color: PKBAppState().secondaryColor.withOpacity(0.5),
                                                      fontSize: secondaryTextSize - 2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Semantics(
                                                label:
                                                    'Reminder ${PKBAppState().isReminderEnabled(medicine['id']) ? 'enabled' : 'disabled'}',
                                                child: Material(
                                                  color: Colors.transparent,
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: InkWell(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    highlightColor: PKBAppState().secondaryColor.withOpacity(0.08),
                                                    splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
                                                    onTap: () async {
                                                      final newValue = !PKBAppState().isReminderEnabled(medicine['id']);
                                                      if (newValue) {
                                                        try {
                                                          await NotificationService().scheduleRemindersForMedicine(medicine);
                                                          setState(() {
                                                            PKBAppState().setReminderEnabled(medicine['id'], true);
                                                          });
                                                        } catch (e) {
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: Text('Failed to schedule reminders: $e'),
                                                                backgroundColor: Colors.red,
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      } else {
                                                        await NotificationService().cancelRemindersForMedicine(medicine['id']);
                                                        setState(() {
                                                          PKBAppState().setReminderEnabled(medicine['id'], false);
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        border: Border.all(
                                                          color: PKBAppState().secondaryColor,
                                                          width: 1.2,
                                                        ),
                                                        color: Colors.transparent,
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 40,
                                                            height: 24,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(6.0),
                                                              border: Border.all(
                                                                color: PKBAppState().secondaryColor,
                                                                width: 1.4,
                                                              ),
                                                              color: PKBAppState().isReminderEnabled(medicine['id'])
                                                                  ? PKBAppState().primaryColor.withOpacity(0.2)
                                                                  : Colors.transparent,
                                                            ),
                                                            alignment: PKBAppState().isReminderEnabled(medicine['id'])
                                                                ? Alignment.centerRight
                                                                : Alignment.centerLeft,
                                                            padding: const EdgeInsets.all(2.5),
                                                            child: Container(
                                                              width: 16,
                                                              height: 16,
                                                              decoration: BoxDecoration(
                                                                color: PKBAppState().isReminderEnabled(medicine['id'])
                                                                    ? PKBAppState().primaryColor
                                                                    : Colors.transparent,
                                                                borderRadius: BorderRadius.circular(4.0),
                                                                border: Border.all(
                                                                  color: PKBAppState().secondaryColor,
                                                                  width: 1.2,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            PKBAppState().isReminderEnabled(medicine['id'])
                                                                ? (loc.getText('toggle_on').isNotEmpty
                                                                    ? loc.getText('toggle_on')
                                                                    : 'On')
                                                                : (loc.getText('toggle_off').isNotEmpty
                                                                    ? loc.getText('toggle_off')
                                                                    : 'Off'),
                                                            style: TextStyle(
                                                              color: PKBAppState().secondaryColor,
                                                              fontSize: secondaryTextSize,
                                                              fontWeight: FontWeight.w700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
