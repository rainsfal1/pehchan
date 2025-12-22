import '../../../widgets/index.dart' as widgets;
import '../../../styles/pillkaboo_theme.dart';
import '../../../../core/pillkaboo_util.dart';
import 'main_menu_page_model.dart';
export 'main_menu_page_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:pillkaboo/src/app/tts/tts_service.dart';
import '../../../../utils/reminder_calculator.dart';

class MainMenuPageWidget extends StatefulWidget {
  const MainMenuPageWidget({super.key});

  @override
  State<MainMenuPageWidget> createState() => _MainMenuPageWidgetState();
}

class _MainMenuPageWidgetState extends State<MainMenuPageWidget> {
  late MainMenuPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainMenuPageModel());

    // Auto-speak next dose reminder on app open
    Future.delayed(Duration.zero, () {
      if (mounted && !PKBAppState().useScreenReader && !PKBAppState().silentMode) {
        final nextDose = _getNextUpcomingDose();
        if (nextDose != null) {
          final medicine = nextDose['medicine'] as Map<String, dynamic>;
          final reminderTime = nextDose['time'] as DateTime;
          final medicineName = medicine['medicineName'];
          final timeUntil = ReminderCalculator.formatTimeUntil(reminderTime);

          String message;
          if (timeUntil == 'now') {
            message = 'Dose due now for $medicineName';
          } else {
            message = 'Next dose in $timeUntil for $medicineName';
          }

          TtsService().stop();
          TtsService().speak(message);
        }
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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

    // Primary button dimensions (larger)
    final primaryContainerHeight = 135.0 / 892.0 * MediaQuery.of(context).size.height;
    final primaryContainerWidth = 353.0 / 412.0 * MediaQuery.of(context).size.width;
    final primaryIconSize = 90.0 / 892.0 * MediaQuery.of(context).size.height;
    final primaryTextSize = 26.0 / 892.0 * MediaQuery.of(context).size.height;

    // Secondary button dimensions (smaller)
    final secondaryContainerHeight = 80.0 / 892.0 * MediaQuery.of(context).size.height;
    final secondaryContainerWidth = 170.0 / 412.0 * MediaQuery.of(context).size.width;
    final secondaryIconSize = 50.0 / 892.0 * MediaQuery.of(context).size.height;
    final secondaryTextSize = 18.0 / 892.0 * MediaQuery.of(context).size.height;

    // Status text size (larger for accessibility)
    final statusTextSize = 28.0 / 892.0 * MediaQuery.of(context).size.height;

    // Medicine count status and next dose reminder
    final medicineCount = PKBAppState().savedMedicines.length;
    final medicinesWithInstructions = PKBAppState().getMedicinesWithInstructionsCount();
    final nextDose = _getNextUpcomingDose();

    String statusText;
    String? statusSubtext;
    if (medicineCount == 0) {
      statusText = loc.getText('no_medicines_yet');
    } else if (nextDose != null) {
      // Show next dose reminder - two lines for elderly
      final medicine = nextDose['medicine'] as Map<String, dynamic>;
      final reminderTime = nextDose['time'] as DateTime;
      final medicineName = medicine['medicineName'];
      final timeUntil = ReminderCalculator.formatTimeUntil(reminderTime);

      if (timeUntil == 'now') {
        statusText = loc.getText('status_take_now').isNotEmpty
            ? loc.getText('status_take_now')
            : 'Take medicine now';
      } else {
        final template = loc.getText('status_next_dose').isNotEmpty
            ? loc.getText('status_next_dose')
            : 'Next dose: {time}';
        statusText = template.replaceAll('{time}', timeUntil);
      }
      statusSubtext = medicineName;
    } else if (medicinesWithInstructions == 0) {
      final template = loc.getText('status_saved').isNotEmpty
          ? loc.getText('status_saved')
          : '{count} saved';
      statusText = template.replaceAll('{count}', medicineCount.toString());
    } else {
      final template = loc.getText('status_saved_scheduled').isNotEmpty
          ? loc.getText('status_saved_scheduled')
          : '{countSaved} saved, {countSched} scheduled';
      statusText = template
          .replaceAll('{countSaved}', medicineCount.toString())
          .replaceAll('{countSched}', medicinesWithInstructions.toString());
    }

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: PKBAppState().tertiaryColor,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Text (Medicine Schedule)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Semantics(
                  container: true,
                  label: statusSubtext != null ? '$statusText: $statusSubtext' : statusText,
                  child: ExcludeSemantics(
                    excluding: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      decoration: BoxDecoration(
                        color: PKBAppState().primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: PKBAppState().primaryColor.withOpacity(0.3),
                          width: 2.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            statusText,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: PKBAppState().secondaryColor,
                              fontSize: statusTextSize,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          if (statusSubtext != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              statusSubtext,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: PKBAppState().secondaryColor.withOpacity(0.85),
                                fontSize: statusTextSize * 0.7,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Primary Buttons
              _menuTile(
                label: loc.getText('identify_medicine'),
                iconPath: 'assets/images/scan_medicine.svg',
                onTap: () => context.pushReplacement('/medRecognitionPage'),
                containerWidth: primaryContainerWidth,
                containerHeight: primaryContainerHeight,
                iconSize: primaryIconSize,
                textSize: primaryTextSize,
                isPrimary: true,
              ),
              _menuTile(
                label: loc.getText('add_prescription'),
                iconPath: 'assets/images/prescription.svg',
                onTap: () => context.pushReplacement('/prescribedMedRecognitionPage'),
                containerWidth: primaryContainerWidth,
                containerHeight: primaryContainerHeight,
                iconSize: primaryIconSize,
                textSize: primaryTextSize,
                isPrimary: true,
              ),
              _menuTile(
                label: loc.getText('my_medicines'),
                iconPath: 'assets/images/medicine.svg',
                onTap: () => context.pushReplacement('/myMedicinesPage'),
                containerWidth: primaryContainerWidth,
                containerHeight: primaryContainerHeight,
                iconSize: primaryIconSize,
                textSize: primaryTextSize,
                isPrimary: true,
              ),

              // Secondary Buttons Row
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 32.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _menuTile(
                      label: loc.getText('menu_settings'),
                      iconPath: 'assets/images/setting.svg',
                      onTap: () => context.pushReplacement('/settingsMenuPage'),
                      containerWidth: secondaryContainerWidth,
                      containerHeight: secondaryContainerHeight,
                      iconSize: secondaryIconSize,
                      textSize: secondaryTextSize,
                      isPrimary: false,
                    ),
                    SizedBox(width: 13.0 / 412.0 * MediaQuery.of(context).size.width),
                    _menuTile(
                      label: loc.getText('menu_help'),
                      iconPath: 'assets/images/help.svg',
                      onTap: () => context.pushReplacement('/helpPage'),
                      containerWidth: secondaryContainerWidth,
                      containerHeight: secondaryContainerHeight,
                      iconSize: secondaryIconSize,
                      textSize: secondaryTextSize,
                      isPrimary: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile({
    required String label,
    required String iconPath,
    required VoidCallback onTap,
    required double containerWidth,
    required double containerHeight,
    required double iconSize,
    required double textSize,
    bool isPrimary = true,
  }) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: isPrimary
            ? const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 32.0)
            : EdgeInsets.zero,
        child: Semantics(
          label: label,
          container: true,
          child: Material(
            color: PKBAppState().tertiaryColor,
            borderRadius: BorderRadius.circular(26.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(26.0),
              highlightColor: PKBAppState().secondaryColor.withOpacity(0.1),
              splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
              onTap: () {
                if (!PKBAppState().useScreenReader && !PKBAppState().silentMode) {
                  Vibration.vibrate(duration: 40);
                  TtsService().stop();
                  TtsService().speak(label);
                }
                onTap();
              },
              onLongPress: () {
                if (!PKBAppState().useScreenReader && !PKBAppState().silentMode) {
                  Vibration.vibrate(duration: 40);
                  TtsService().stop();
                  TtsService().speak(label);
                }
                onTap();
              },
              child: Container(
                width: containerWidth,
                height: containerHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26.0),
                  border: Border.all(
                    color: PKBAppState().secondaryColor,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          isPrimary ? 30.0 : 15.0, 0.0, 0.0, 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: SvgPicture.asset(
                          iconPath,
                          width: iconSize,
                          height: iconSize,
                          fit: BoxFit.fitHeight,
                          colorFilter: ColorFilter.mode(
                            PKBAppState().secondaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          label,
                          maxLines: isPrimary ? 2 : 1,
                          softWrap: isPrimary,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: PillKaBooTheme.of(context)
                              .titleMedium
                              .override(
                                fontFamily: PillKaBooTheme.of(context)
                                    .titleMediumFamily,
                                color: PKBAppState().secondaryColor,
                                fontSize: textSize,
                                fontWeight: FontWeight.w900,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    PillKaBooTheme.of(context)
                                        .titleMediumFamily),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Find the next upcoming dose across all medicines with active reminders
  /// Returns null if no upcoming doses found
  Map<String, dynamic>? _getNextUpcomingDose() {
    DateTime? earliestTime;
    Map<String, dynamic>? earliestMedicine;

    for (final medicine in PKBAppState().savedMedicines) {
      // Skip if reminders are disabled
      if (!PKBAppState().isReminderEnabled(medicine['id'])) {
        continue;
      }

      // Get next reminder time for this medicine
      final nextTime = ReminderCalculator.getNextReminderTime(medicine);
      if (nextTime != null) {
        if (earliestTime == null || nextTime.isBefore(earliestTime)) {
          earliestTime = nextTime;
          earliestMedicine = medicine;
        }
      }
    }

    if (earliestTime != null && earliestMedicine != null) {
      return {
        'time': earliestTime,
        'medicine': earliestMedicine,
      };
    }

    return null;
  }
}
