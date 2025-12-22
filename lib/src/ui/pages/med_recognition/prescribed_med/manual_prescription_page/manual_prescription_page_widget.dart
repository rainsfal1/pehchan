import '../../../../../core/pillkaboo_util.dart';
import '../../../../styles/pillkaboo_theme.dart';
import '../../../../widgets/index.dart' as widgets;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'manual_prescription_page_model.dart';
export 'manual_prescription_page_model.dart';

class ManualPrescriptionPageWidget extends StatefulWidget {
  const ManualPrescriptionPageWidget({super.key});

  @override
  State<ManualPrescriptionPageWidget> createState() => _ManualPrescriptionPageWidgetState();
}

class _ManualPrescriptionPageWidgetState extends State<ManualPrescriptionPageWidget> {
  late ManualPrescriptionPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? _selectedMedicine;
  final Set<String> _selectedSlots = {};
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManualPrescriptionPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool get _isLightBackground => PKBAppState().tertiaryColor.computeLuminance() > 0.5;

  Color _chipFill(bool isSelected) {
    if (isSelected) {
      return PKBAppState().secondaryColor.withOpacity(_isLightBackground ? 0.14 : 0.2);
    }
    return (_isLightBackground ? Colors.white : Colors.black).withOpacity(0.08);
  }

  String _dateLabel(PKBLocalizations loc) {
    if (_selectedDate == null) {
      return loc.getText('manual_rx_date_label').isNotEmpty
          ? loc.getText('manual_rx_date_label')
          : 'Prescription date (optional)';
    }
    return DateFormat('yyyy-MM-dd').format(_selectedDate!);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    if (isiOS) {
      DateTime tempDate = _selectedDate ?? now;
      await showCupertinoModalPopup(
        context: context,
        builder: (ctx) => Container(
          height: 320,
          color: PKBAppState().tertiaryColor,
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: PKBAppState().secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: PKBAppState().primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: () {
                        setState(() => _selectedDate = tempDate);
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: _isLightBackground ? Brightness.light : Brightness.dark,
                    primaryColor: PKBAppState().primaryColor,
                    scaffoldBackgroundColor: PKBAppState().tertiaryColor,
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempDate,
                    minimumDate: DateTime(now.year - 2),
                    maximumDate: DateTime(now.year + 2),
                    onDateTimeChanged: (val) => tempDate = val,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? now,
        firstDate: DateTime(now.year - 2),
        lastDate: DateTime(now.year + 2),
      );
      if (picked != null) {
        setState(() {
          _selectedDate = picked;
        });
      }
    }
  }

  Future<void> _saveManualPrescription() async {
    if (_selectedMedicine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PKBLocalizations.of(context).getText('manual_rx_error_select_med').isNotEmpty
                ? PKBLocalizations.of(context).getText('manual_rx_error_select_med')
                : 'Select a medicine first',
          ),
        ),
      );
      return;
    }
    if (_selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PKBLocalizations.of(context).getText('manual_rx_error_pick_time').isNotEmpty
                ? PKBLocalizations.of(context).getText('manual_rx_error_pick_time')
                : 'Pick at least one time to take it',
          ),
        ),
      );
      return;
    }

    final dateStr = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '';

    await PKBAppState().updateMedicineInstructions(
      _selectedMedicine!['id'],
      _selectedSlots.toList(),
      null,
      dateStr.isNotEmpty ? dateStr : null,
    );
    PKBAppState().clearPrescriptionData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          (PKBLocalizations.of(context).getText('manual_rx_saved').isNotEmpty
                  ? PKBLocalizations.of(context).getText('manual_rx_saved')
                  : 'Prescription added for {name}')
              .replaceAll('{name}', _selectedMedicine!['medicineName'] as String),
        ),
      ),
    );
    context.pushReplacement('/myMedicinesPage');
  }

  Widget _medicineCard(Map<String, dynamic> medicine, double medicineNameSize) {
    final isSelected = _selectedMedicine?['id'] == medicine['id'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          highlightColor: PKBAppState().secondaryColor.withOpacity(0.08),
          splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
          onTap: () {
            setState(() {
              _selectedMedicine = medicine;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? PKBAppState().primaryColor.withOpacity(_isLightBackground ? 0.16 : 0.22)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? PKBAppState().primaryColor : PKBAppState().secondaryColor,
                width: isSelected ? 2.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    medicine['medicineName'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: PKBAppState().secondaryColor,
                      fontSize: medicineNameSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? PKBAppState().primaryColor : PKBAppState().secondaryColor,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _slotChip(String key, String label, double textSize) {
    final isSelected = _selectedSlots.contains(key);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        highlightColor: PKBAppState().secondaryColor.withOpacity(0.08),
        splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedSlots.remove(key);
            } else {
              _selectedSlots.add(key);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: _chipFill(isSelected),
            border: Border.all(
              color: PKBAppState().secondaryColor,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: PKBAppState().secondaryColor,
                  fontSize: textSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
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

    context.watch<PKBAppState>();
    final loc = PKBLocalizations.of(context);

    final height = MediaQuery.of(context).size.height;
    double appBarFontSize = 32.0 / 892.0 * height;
    double sectionTitleSize = 22.0 / 892.0 * height;
    double medicineNameSize = 20.0 / 892.0 * height;
    double bodyTextSize = 16.0 / 892.0 * height;

    final medicines = PKBAppState().savedMedicines;

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
            label: loc.getText('manual_rx_title').isNotEmpty
                ? loc.getText('manual_rx_title')
                : 'Add prescription',
            child: ExcludeSemantics(
              excluding: true,
              child: Text(
                loc.getText('manual_rx_title').isNotEmpty
                    ? loc.getText('manual_rx_title')
                    : 'Add prescription',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  loc.getText('manual_rx_subtitle').isNotEmpty
                      ? loc.getText('manual_rx_subtitle')
                      : 'Pick a medicine, then set when to take it.',
                  style: TextStyle(
                    color: PKBAppState().secondaryColor.withOpacity(0.8),
                    fontSize: sectionTitleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Text(
                      loc.getText('manual_rx_select_medicine').isNotEmpty
                          ? loc.getText('manual_rx_select_medicine')
                          : (loc.getText('select_medicine').isNotEmpty
                              ? loc.getText('select_medicine')
                              : 'Select medicine'),
                      style: TextStyle(
                        color: PKBAppState().secondaryColor,
                        fontSize: sectionTitleSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if (medicines.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: PKBAppState().secondaryColor.withOpacity(0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.getText('manual_rx_no_meds').isNotEmpty
                                  ? loc.getText('manual_rx_no_meds')
                                  : 'No medicines yet. Add one first, then attach a prescription.',
                              style: TextStyle(
                                color: PKBAppState().secondaryColor.withOpacity(0.7),
                                fontSize: bodyTextSize,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Material(
                              color: PKBAppState().primaryColor,
                              borderRadius: BorderRadius.circular(10.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10.0),
                                highlightColor: PKBAppState().tertiaryColor.withOpacity(0.08),
                                splashColor: PKBAppState().tertiaryColor.withOpacity(0.12),
                                onTap: () => context.pushReplacement('/myMedicinesPage'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                      color: PKBAppState().primaryColor,
                                    ),
                                  ),
                                  child: Text(
                                    loc.getText('add_medicine').isNotEmpty
                                        ? loc.getText('add_medicine')
                                        : 'Add medicine',
                                    style: TextStyle(
                                      color: PKBAppState().tertiaryColor,
                                      fontSize: bodyTextSize,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      for (final med in medicines) _medicineCard(med as Map<String, dynamic>, medicineNameSize),
                    ],
                    const SizedBox(height: 16.0),
                    Text(
                      loc.getText('manual_rx_schedule').isNotEmpty
                          ? loc.getText('manual_rx_schedule')
                          : 'Schedule',
                      style: TextStyle(
                        color: PKBAppState().secondaryColor,
                        fontSize: sectionTitleSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: PKBAppState().primaryColor.withOpacity(_isLightBackground ? 0.06 : 0.12),
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: PKBAppState().secondaryColor.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.getText('manual_rx_when').isNotEmpty
                                ? loc.getText('manual_rx_when')
                                : 'When should reminders ring?',
                            style: TextStyle(
                              color: PKBAppState().secondaryColor,
                              fontSize: bodyTextSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Wrap(
                            spacing: 12.0,
                            runSpacing: 12.0,
                            children: [
                              _slotChip(
                                  'morning',
                                  loc.getText('manual_rx_slot_morning').isNotEmpty
                                      ? loc.getText('manual_rx_slot_morning')
                                      : 'Morning',
                                  bodyTextSize),
                              _slotChip(
                                  'noon',
                                  loc.getText('manual_rx_slot_noon').isNotEmpty
                                      ? loc.getText('manual_rx_slot_noon')
                                      : 'Afternoon',
                                  bodyTextSize),
                              _slotChip(
                                  'night',
                                  loc.getText('manual_rx_slot_night').isNotEmpty
                                      ? loc.getText('manual_rx_slot_night')
                                      : 'Night',
                                  bodyTextSize),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            loc.getText('manual_rx_start_date').isNotEmpty
                                ? loc.getText('manual_rx_start_date')
                                : 'Start date (optional)',
                            style: TextStyle(
                              color: PKBAppState().secondaryColor,
                              fontSize: bodyTextSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.0),
                              highlightColor: PKBAppState().secondaryColor.withOpacity(0.08),
                              splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
                              onTap: _pickDate,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: (_isLightBackground ? Colors.white : Colors.black).withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: PKBAppState().secondaryColor.withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _dateLabel(loc),
                                      style: TextStyle(
                                        color: PKBAppState().secondaryColor,
                                        fontSize: bodyTextSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      color: PKBAppState().secondaryColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.0),
                              highlightColor: PKBAppState().secondaryColor.withOpacity(0.08),
                              splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
                              onTap: () => context.pop(),
                              child: Container(
                                height: 54,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: PKBAppState().secondaryColor.withOpacity(0.6),
                                  ),
                                ),
                                child: Text(
                                  loc.getText('manual_rx_back').isNotEmpty
                                      ? loc.getText('manual_rx_back')
                                      : 'Back',
                                  style: TextStyle(
                                    color: PKBAppState().secondaryColor,
                                    fontSize: bodyTextSize,
                                    fontWeight: FontWeight.w800,
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
                            borderRadius: BorderRadius.circular(12.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.0),
                              highlightColor: PKBAppState().tertiaryColor.withOpacity(0.08),
                              splashColor: PKBAppState().tertiaryColor.withOpacity(0.12),
                              onTap: _saveManualPrescription,
                              child: Container(
                                height: 54,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: PKBAppState().primaryColor,
                                  ),
                                ),
                                child: Text(
                                  loc.getText('manual_rx_save').isNotEmpty
                                      ? loc.getText('manual_rx_save')
                                      : 'Save prescription',
                                  style: TextStyle(
                                    color: PKBAppState().tertiaryColor,
                                    fontSize: bodyTextSize,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
