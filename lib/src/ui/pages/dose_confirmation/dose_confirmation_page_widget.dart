import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/pillkaboo_util.dart';
import '../../../app/tts/tts_service.dart';
import '../../styles/pillkaboo_theme.dart';
import '../../widgets/index.dart' as widgets;

import 'dose_confirmation_page_model.dart';
export 'dose_confirmation_page_model.dart';

class DoseConfirmationPageWidget extends StatefulWidget {
  final String medicineId;
  final String medicineName;
  final String slot;
  final int scheduledTime;

  const DoseConfirmationPageWidget({
    super.key,
    required this.medicineId,
    required this.medicineName,
    required this.slot,
    required this.scheduledTime,
  });

  @override
  State<DoseConfirmationPageWidget> createState() => _DoseConfirmationPageWidgetState();
}

class _DoseConfirmationPageWidgetState extends State<DoseConfirmationPageWidget> {
  late DoseConfirmationPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = DoseConfirmationPageModel();

    // Auto-speak the reminder message
    Future.delayed(Duration.zero, () {
      if (mounted && !PKBAppState().useScreenReader && !PKBAppState().silentMode) {
        TtsService().stop();
        TtsService().speak('Time to take ${widget.medicineName}. Your ${widget.slot} dose is ready.');
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _markAsTaken() {
    // Record dose as taken
    final scheduledDateTime = DateTime.fromMillisecondsSinceEpoch(widget.scheduledTime);
    PKBAppState().recordDoseTaken(
      widget.medicineId,
      widget.medicineName,
      scheduledDateTime,
      widget.slot,
    );

    // Speak confirmation
    if (!PKBAppState().useScreenReader && !PKBAppState().silentMode) {
      TtsService().stop();
      TtsService().speak('${widget.medicineName} dose marked as taken');
    }

    // Navigate back to home
    context.pushReplacement('/mainMenuPage');
  }

  void _skipDose() {
    // Speak skip message
    if (!PKBAppState().useScreenReader && !PKBAppState().silentMode) {
      TtsService().stop();
      TtsService().speak('Dose skipped');
    }

    // Navigate back to home
    context.pushReplacement('/mainMenuPage');
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
    double titleFontSize = 28.0 / 892.0 * MediaQuery.of(context).size.height;
    double bodyFontSize = 20.0 / 892.0 * MediaQuery.of(context).size.height;
    double buttonFontSize = 22.0 / 892.0 * MediaQuery.of(context).size.height;

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
            label: loc.getText('dose_reminder'),
            child: ExcludeSemantics(
              excluding: true,
              child: Text(
                loc.getText('dose_reminder'),
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Medicine icon
                  Icon(
                    Icons.medication,
                    size: 100,
                    color: PKBAppState().primaryColor,
                  ),
                  const SizedBox(height: 32.0),

                  // Title message
                  Semantics(
                    container: true,
                    label: 'Time to take ${widget.medicineName}',
                    child: ExcludeSemantics(
                      excluding: true,
                      child: Text(
                        'Time to take',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: PKBAppState().secondaryColor,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Medicine name
                  Semantics(
                    container: true,
                    label: widget.medicineName,
                    child: ExcludeSemantics(
                      excluding: true,
                      child: Text(
                        widget.medicineName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: PKBAppState().primaryColor,
                          fontSize: titleFontSize + 4,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Slot info
                  Semantics(
                    container: true,
                    label: '${widget.slot} dose',
                    child: ExcludeSemantics(
                      excluding: true,
                      child: Text(
                        '${widget.slot} dose',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: PKBAppState().secondaryColor.withOpacity(0.8),
                          fontSize: bodyFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48.0),

                  // Mark as taken button
                  Semantics(
                    label: 'Mark as taken',
                    button: true,
                    child: ExcludeSemantics(
                      excluding: true,
                      child: ElevatedButton(
                        onPressed: _markAsTaken,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PKBAppState().primaryColor,
                          foregroundColor: PKBAppState().tertiaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48.0,
                            vertical: 20.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          loc.getText('mark_as_taken'),
                          style: TextStyle(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Skip button
                  Semantics(
                    label: 'Skip this dose',
                    button: true,
                    child: ExcludeSemantics(
                      excluding: true,
                      child: TextButton(
                        onPressed: _skipDose,
                        child: Text(
                          loc.getText('skip_dose'),
                          style: TextStyle(
                            color: PKBAppState().secondaryColor.withOpacity(0.7),
                            fontSize: bodyFontSize,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }
}
