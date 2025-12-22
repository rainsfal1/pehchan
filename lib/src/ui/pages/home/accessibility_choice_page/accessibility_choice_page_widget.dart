import 'package:pillkaboo/src/app/tts/tts_service.dart';

import '../../../styles/pillkaboo_theme.dart';
import '../../../../core/pillkaboo_util.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'accessibility_choice_page_model.dart';
export 'accessibility_choice_page_model.dart';

class AccessibilityChoicePageWidget extends StatefulWidget {
  const AccessibilityChoicePageWidget({super.key});

  @override
  State<AccessibilityChoicePageWidget> createState() => _AccessibilityChoicePageWidgetState();
}

class _AccessibilityChoicePageWidgetState extends State<AccessibilityChoicePageWidget> {
  late AccessibilityChoicePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final text = "Tap the top half to use your screen reader. Tap the bottom half to use the app audio guidance.";

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AccessibilityChoicePageModel());
    TtsService().speak(text);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context, bool isYes) {
    final response = isYes ? "Screen reader ON" : "Use app audio";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Selected: $response")),
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


    double textSize = 30.0/892.0 * MediaQuery.of(context).size.height;

    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        final screenHeight = MediaQuery.of(context).size.height;
        final tapPosition = details.globalPosition.dy;
        if (tapPosition < screenHeight / 2) {
          _handleTap(context, true); // uses screen reader, hence NO tts
          PKBAppState().useScreenReader = true;
        } else {
          _handleTap(context, false); // doesn't use screen reader, hence TTS
          PKBAppState().useScreenReader = false;
        }
        PKBAppState().isFirstLaunch = false;
        context.push('/mainMenuPage');
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: PKBAppState().tertiaryColor,
        body: SafeArea(
          top: true,
            child: 
                Container(
                  color: PKBAppState().tertiaryColor,
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: ExcludeSemantics(
                            excluding: true,
                              child: Text(
                              'Use screen reader',
                              style: TextStyle(
                                fontSize: textSize,
                                color: PKBAppState().secondaryColor,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.white, 
                          child: Center(
                            child: ExcludeSemantics(
                              excluding: true,
                              child: Text(
                                'Use app audio',
                                style: TextStyle(
                                  fontSize: textSize,
                                  color: PKBAppState().tertiaryColor,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )

              ),
            ),
          );
  }
}
