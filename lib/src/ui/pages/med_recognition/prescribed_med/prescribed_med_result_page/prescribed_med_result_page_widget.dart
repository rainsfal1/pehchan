import 'package:pehchan/src/app/tts/tts_service.dart';

import '../../../../styles/pehchan_theme.dart';
import '../../../../../core/pehchan_util.dart';
import '../../../../widgets/index.dart' as widgets;
import '../../../../../app/global_audio_player.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'prescribed_med_result_page_model.dart';
export 'prescribed_med_result_page_model.dart';


class PrescribedMedResultPageWidget extends StatefulWidget {
  const PrescribedMedResultPageWidget({super.key});

  @override
  State<PrescribedMedResultPageWidget> createState() =>
      _CheckRestResultPageWidgetState();
}

class _CheckRestResultPageWidgetState extends State<PrescribedMedResultPageWidget> {
  late PrescribedMedResultPageModel _model;
  late String imgPath;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    GlobalAudioPlayer().playOnce();
    _model = createModel(context, () => PrescribedMedResultPageModel());
    TtsService().stop();
    if (PKBAppState().slotOfDay == "morning") {
      imgPath = 'assets/images/morning.png';
    } else if (PKBAppState().slotOfDay == "noon") {
      imgPath = 'assets/images/lunch.png';
    } else if (PKBAppState().slotOfDay == "night") {
      imgPath = 'assets/images/night.png';
    } else {
      imgPath = 'assets/images/warning.svg';
    }
    if (!PKBAppState().useScreenReader && !PKBAppState().silentMode) {
      final loc = PKBLocalizations.of(context);
      TtsService().speak(_buildPrescriptionTts(loc));
    }
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
          statusBarBrightness: Theme
              .of(context)
              .brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }


    double appBarFontSize = 32.0/892.0 * MediaQuery.of(context).size.height;
    double buttonFontSize = 24.0/892.0 * MediaQuery.of(context).size.height;

    context.watch<PKBAppState>();
    final loc = PKBLocalizations.of(context);

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
            label: 'Prescription time result',
            child: ExcludeSemantics(
              excluding: true,
              child: Text(
                'Prescription Result',
                style: PehchanTheme.of(context).headlineMedium.override(
                  fontFamily: PehchanTheme.of(context).headlineMediumFamily,
                  color: PKBAppState().secondaryColor,
                  fontSize: appBarFontSize,
                  fontWeight: FontWeight.bold,
                  useGoogleFonts: GoogleFonts.asMap().containsKey(PehchanTheme.of(context).headlineMediumFamily),
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
            child: Semantics(
              container: true,
              explicitChildNodes: false,
              child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Take ',
                      style: TextStyle(
                        color: PKBAppState().secondaryColor,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    TextSpan(
                      text: PKBAppState().slotOfDay,
                      style: TextStyle(
                        color: PKBAppState().primaryColor,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ExcludeSemantics(
                excluding: true,
                child: Image.asset(
                imgPath,
                height: 164.41,
                fit: BoxFit.contain,
              ),),
              const SizedBox(
                height: 30,
              ),

              // Duration (if extracted)
              if (PKBAppState().extractedDuration.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'For ${PKBAppState().extractedDuration}',
                    style: TextStyle(
                      color: PKBAppState().primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),

              // Prescribed date
              if (PKBAppState().infoPrescribedDate.isNotEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      PKBAppState().infoPrescribedDate,
                      style: TextStyle(
                        color: PKBAppState().primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    Text(
                      'Prescription date',
                      style: TextStyle(
                        color: PKBAppState().secondaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 40),

              // Attach to Medicine button
              Semantics(
                label: loc.getText('attach_to_medicine'),
                child: ElevatedButton(
                  onPressed: () {
                    context.pushReplacement('/selectMedicinePage');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PKBAppState().primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: ExcludeSemantics(
                    excluding: true,
                    child: Text(
                      loc.getText('attach_to_medicine'),
                      style: TextStyle(
                        color: PKBAppState().tertiaryColor,
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),),
          ),
        ),
      ),
    );
  }

  String _buildPrescriptionTts(PKBLocalizations loc) {
    final slot = _localizedSlot(loc, PKBAppState().slotOfDay);
    final takeTemplate = loc.getText('tts_prescription_take_slot').isNotEmpty
        ? loc.getText('tts_prescription_take_slot')
        : 'Take {slot}';
    String message = takeTemplate.replaceAll('{slot}', slot);

    if (PKBAppState().extractedDuration.isNotEmpty) {
      final durationTemplate = loc.getText('tts_prescription_for_duration').isNotEmpty
          ? loc.getText('tts_prescription_for_duration')
          : 'for {duration}';
      message += ' ${durationTemplate.replaceAll('{duration}', PKBAppState().extractedDuration)}';
    }
    if (PKBAppState().infoPrescribedDate.isNotEmpty) {
      final dateTemplate = loc.getText('tts_prescription_date').isNotEmpty
          ? loc.getText('tts_prescription_date')
          : 'Prescribed on {date}';
      message += '. ${dateTemplate.replaceAll('{date}', PKBAppState().infoPrescribedDate)}';
    }
    return message;
  }

  String _localizedSlot(PKBLocalizations loc, String slot) {
    switch (slot.toLowerCase()) {
      case 'morning':
        return loc.getText('manual_rx_slot_morning').isNotEmpty
            ? loc.getText('manual_rx_slot_morning')
            : slot;
      case 'noon':
        return loc.getText('manual_rx_slot_noon').isNotEmpty
            ? loc.getText('manual_rx_slot_noon')
            : slot;
      case 'night':
        return loc.getText('manual_rx_slot_night').isNotEmpty
            ? loc.getText('manual_rx_slot_night')
            : slot;
      default:
        return slot;
    }
  }
}
