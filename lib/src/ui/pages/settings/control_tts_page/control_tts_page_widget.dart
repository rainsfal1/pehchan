import 'package:pillkaboo/src/app/tts/tts_service.dart';

import '../../../styles/pillkaboo_theme.dart';
import '../../../../core/pillkaboo_util.dart';
import '../../../widgets/index.dart' as widgets;
import '../../../../app/global_audio_player.dart';

import 'package:vibration/vibration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'control_tts_page_model.dart';
export 'control_tts_page_model.dart';

class ControlTTSPageWidget extends StatefulWidget {
  const ControlTTSPageWidget({super.key});

  @override
  State<ControlTTSPageWidget> createState() => _ControlTTSPageWidgetState();
}

class _ControlTTSPageWidgetState extends State<ControlTTSPageWidget> {
  late ControlTTSPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ControlTTSPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = PKBLocalizations.of(context);
    final weight = loc.languageCode == 'ur' ? FontWeight.w800 : FontWeight.bold;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    double appBarFontSize = 32.0 / 892.0 * MediaQuery.of(context).size.height;
    double sliderValue = PKBAppState().ttsSpeed;
    final double textSize = 24.0 / 892.0 * MediaQuery.of(context).size.height;
    final List<double> values = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
    int selectedIndex = values.indexOf(sliderValue);
    String controlTxt = loc.getText('audio_toggle_sr_on').isNotEmpty
        ? loc.getText('audio_toggle_sr_on')
        : "You are using the screen reader. Tap to switch to app audio.";
    if (!PKBAppState().useScreenReader) {
      controlTxt = loc.getText('audio_toggle_sr_off').isNotEmpty
          ? loc.getText('audio_toggle_sr_off')
          : "You are using app audio. Tap to switch to screen reader.";
    }

    void handleSliderChange(double value) {
      setState(() {
        sliderValue = value;
        PKBAppState().ttsSpeed = value;
        TtsService().stop();
        TtsService().speak("Speed set to ${value.toStringAsFixed(1)}");
        TtsService().setTtsSpeed(value);
      });
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Close the keyboard when tapping outside
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: PKBAppState().tertiaryColor,
        appBar: AppBar(
          backgroundColor: PKBAppState().tertiaryColor,
          automaticallyImplyLeading: false, // prevent default back button from appearing
          title: Semantics(
            container: true,
            label: loc.getText('audio_settings').isNotEmpty
                ? loc.getText('audio_settings')
                : 'Audio settings',
            child: ExcludeSemantics(
              excluding: true,
              child: Text(
                loc.getText('audio_settings').isNotEmpty
                    ? loc.getText('audio_settings')
                    : 'Audio settings',
                style: PillKaBooTheme.of(context).headlineMedium.override(
                  fontFamily: PillKaBooTheme.of(context).headlineMediumFamily,
                  color: PKBAppState().secondaryColor,
                  fontSize: appBarFontSize,
                  fontWeight: weight,
                  useGoogleFonts: GoogleFonts.asMap().containsKey(PillKaBooTheme.of(context).headlineMediumFamily),
                ),
              ),
            ),
          ),
          actions: [
            widgets.HomeButtonWidget(),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20.0),
                Semantics(
                  label: controlTxt,
                  container: true,
                  child: ExcludeSemantics(
                    excluding: true,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          PKBAppState().useScreenReader = !PKBAppState().useScreenReader;
                          if (!PKBAppState().useScreenReader) {
                            TtsService().stop();
                            TtsService().speak("Using app audio.");
                          } else {
                            TtsService().stop();
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.getText('audio_use_screen_reader').isNotEmpty
                                ? loc.getText('audio_use_screen_reader')
                                : 'Use screen reader',
                            style: TextStyle(
                              fontSize: 27,
                              color: PKBAppState().secondaryColor,
                              fontWeight: weight,
                            ),
                          ),
                            Switch(
                              value: PKBAppState().useScreenReader,
                              focusColor: PKBAppState().primaryColor,
                              activeColor: PKBAppState().primaryColor,
                              onChanged: (bool value) {
                                setState(() {
                                  PKBAppState().useScreenReader = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                if (!PKBAppState().useScreenReader)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Semantics(
                              container: true,
                              child: Text(
                                loc.getText('audio_mute').isNotEmpty
                                    ? loc.getText('audio_mute')
                                    : 'Mute app voice',
                                style: TextStyle(
                                  fontSize: 27,
                                  color: PKBAppState().secondaryColor,
                                  fontWeight: weight,
                                ),
                              ),
                            ),
                            Switch(
                              value: PKBAppState().silentMode,
                              focusColor: PKBAppState().primaryColor,
                              activeColor: PKBAppState().primaryColor,
                              onChanged: (bool value) {
                                setState(() {
                                  PKBAppState().silentMode = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Semantics(
                        container: true,
                        label: 'Adjust audio speed. Disable screen reader to use this.',
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Optional padding
                          child: Text(
                            (loc.getText('audio_speed_label').isNotEmpty
                                    ? loc.getText('audio_speed_label')
                                    : 'Current audio speed: {value}')
                                .replaceAll('{value}', sliderValue.toStringAsFixed(1)),
                            style: TextStyle(
                              fontSize: textSize,
                              color: PKBAppState().secondaryColor,
                              fontWeight: weight,
                            ),
                          ),
                        ),
                      ),
                      ExcludeSemantics(
                        excluding: true,
                        child: Slider(
                          value: selectedIndex.toDouble(),
                          min: 0,
                          max: values.length - 1.toDouble(),
                          divisions: values.length - 1,
                          label: values[selectedIndex].toString(),
                          activeColor: PKBAppState().primaryColor,
                          onChanged: (double value) {
                            setState(() {
                              selectedIndex = value.toInt();
                              handleSliderChange(values[selectedIndex]);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
