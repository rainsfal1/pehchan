import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/pillkaboo_util.dart';
import '../../../../../app/tts/tts_service.dart';
import '../../../../styles/pillkaboo_theme.dart';
import '../../../../widgets/index.dart' as widgets;

import 'select_medicine_page_model.dart';
export 'select_medicine_page_model.dart';

class SelectMedicinePageWidget extends StatefulWidget {
  const SelectMedicinePageWidget({super.key});

  @override
  State<SelectMedicinePageWidget> createState() => _SelectMedicinePageWidgetState();
}

class _SelectMedicinePageWidgetState extends State<SelectMedicinePageWidget> {
  late SelectMedicinePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SelectMedicinePageModel());

    // Read initial instructions
    Future.delayed(Duration.zero, () {
      if (mounted && !PKBAppState().useScreenReader && !PKBAppState().silentMode) {
        TtsService().stop();
        TtsService().speak('Which medicine is this prescription for? Tap a medicine to attach instructions.');
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _linkInstructions(Map<String, dynamic> medicine) async {
    final appState = PKBAppState();

    // Build slotOfDay list
    List<String> slots = [];
    if (appState.slotOfDay.isNotEmpty) {
      slots.add(appState.slotOfDay);
    }

    // Update medicine with instructions (now async - schedules reminders)
    await appState.updateMedicineInstructions(
      medicine['id'],
      slots,
      appState.extractedDuration.isNotEmpty ? appState.extractedDuration : null,
      appState.infoPrescribedDate.isNotEmpty ? appState.infoPrescribedDate : null,
    );

    // Clear temporary data
    appState.clearPrescriptionData();

    // Navigate to My Medicines page
    context.pushReplacement('/myMedicinesPage');
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
    double instructionTextSize = 18.0 / 892.0 * MediaQuery.of(context).size.height;

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
            label: loc.getText('select_medicine'),
            child: ExcludeSemantics(
              excluding: true,
              child: Text(
                loc.getText('select_medicine'),
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
              // Instruction preview at top
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: PKBAppState().primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: PKBAppState().primaryColor,
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.getText('extracted_instructions'),
                        style: TextStyle(
                          color: PKBAppState().secondaryColor,
                          fontSize: instructionTextSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        _buildInstructionPreview(),
                        style: TextStyle(
                          color: PKBAppState().primaryColor,
                          fontSize: instructionTextSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Medicine list
              Expanded(
                child: PKBAppState().savedMedicines.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            loc.getText('no_medicines_to_link'),
                            textAlign: TextAlign.center,
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

                          return Semantics(
                            container: true,
                            label: '$medicineName, tap to attach instructions',
                            child: InkWell(
                              onTap: () {
                                if (!PKBAppState().useScreenReader && !PKBAppState().silentMode) {
                                  TtsService().stop();
                                  TtsService().speak('Attaching instructions to $medicineName');
                                }
                                _linkInstructions(medicine);
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
                                child: Row(
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
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: PKBAppState().secondaryColor,
                                      size: 20,
                                    ),
                                  ],
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

  String _buildInstructionPreview() {
    final parts = <String>[];

    if (PKBAppState().slotOfDay.isNotEmpty) {
      parts.add(PKBAppState().slotOfDay);
    }

    if (PKBAppState().extractedDuration.isNotEmpty) {
      parts.add(PKBAppState().extractedDuration);
    }

    if (PKBAppState().infoPrescribedDate.isNotEmpty) {
      parts.add('from ${PKBAppState().infoPrescribedDate}');
    }

    return parts.isEmpty ? 'No instructions extracted' : parts.join(' • ');
  }
}
