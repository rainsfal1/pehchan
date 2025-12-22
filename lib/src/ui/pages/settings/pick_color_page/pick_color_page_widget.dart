import '../../../styles/pillkaboo_theme.dart';
import '../../../../core/pillkaboo_util.dart';
import '../../../widgets/index.dart' as widgets;
import '../../../../app/global_audio_player.dart';

import 'package:vibration/vibration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pick_color_page_model.dart';
export 'pick_color_page_model.dart';


class PickColorPageWidget extends StatefulWidget {
  const PickColorPageWidget({super.key});

  @override
  State<PickColorPageWidget> createState() => _PickColorPageWidgetState();
}

class _PickColorPageWidgetState extends State<PickColorPageWidget> {
  late PickColorPageModel _model;
  Color selectedPrimary = PKBAppState().primaryColor; // Emphasis color
  Color selectedSecondary = PKBAppState().secondaryColor; // Contrast color
  Color selectedTertiary = PKBAppState().tertiaryColor; // Background color

  final scaffoldKey = GlobalKey<ScaffoldState>();
  FontWeight _weightForLocale(PKBLocalizations loc) =>
      loc.languageCode == 'ur' ? FontWeight.w800 : FontWeight.bold;
  Alignment _headingAlign(PKBLocalizations loc) =>
      loc.languageCode == 'ur' ? Alignment.centerRight : Alignment.centerLeft;
  EdgeInsets _headingPadding(PKBLocalizations loc) => loc.languageCode == 'ur'
      ? const EdgeInsets.only(right: 20.0)
      : const EdgeInsets.only(left: 20.0);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PickColorPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    double appBarFontSize = 32.0/892.0 * MediaQuery.of(context).size.height;
    final loc = PKBLocalizations.of(context);

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
            label: loc.getText('color_settings').isNotEmpty
                ? loc.getText('color_settings')
                : 'Color settings',
            child: ExcludeSemantics(
              excluding: true,
              child: Text(
                loc.getText('color_settings').isNotEmpty
                    ? loc.getText('color_settings')
                    : 'Color settings',
                style: PillKaBooTheme.of(context).headlineMedium.override(
                  fontFamily: PillKaBooTheme.of(context).headlineMediumFamily,
                  color: PKBAppState().secondaryColor,
                  fontSize: appBarFontSize,
                  fontWeight: _weightForLocale(loc),
                  useGoogleFonts: GoogleFonts.asMap().containsKey(PillKaBooTheme.of(context).headlineMediumFamily),
                ),
              ),
            ),
          ),
          actions:  [
            widgets.HomeButtonWidget(),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 130.0,
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: PKBAppState().tertiaryColor,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: _headingAlign(loc),
                        child: Padding(
                          padding: _headingPadding(loc),
                          child: Text(
                            loc.getText('color_background').isNotEmpty
                                ? loc.getText('color_background')
                                : 'Background color',
                            style: PillKaBooTheme.of(context).headlineMedium.override(
                              fontFamily: PillKaBooTheme.of(context).headlineMediumFamily,
                              color: PKBAppState().secondaryColor,
                              fontSize: 25.0,
                              fontWeight: _weightForLocale(loc),
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  PillKaBooTheme.of(context).headlineMediumFamily),
                            ),
                          ),
                        ),
                      ),
                      buildColorRow(0, ['Black', 'White'], 2),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250.0,
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: PKBAppState().tertiaryColor,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: _headingAlign(loc),
                        child: Padding(
                          padding: _headingPadding(loc),
                          child: Text(
                            loc.getText('color_contrast').isNotEmpty
                                ? loc.getText('color_contrast')
                                : 'Contrast color',
                            style: PillKaBooTheme.of(context).headlineMedium.override(
                              fontFamily: PillKaBooTheme.of(context).headlineMediumFamily,
                              color: PKBAppState().secondaryColor,
                              fontSize: 25.0,
                              fontWeight: _weightForLocale(loc),
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  PillKaBooTheme.of(context).headlineMediumFamily),
                            ),
                          ),
                        ),
                      ),
                      buildColorRow(0, ['Black', 'White', 'Gray'], 1),
                      buildColorRow(3, ['Blue', 'Red', 'Yellow'], 1),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250.0,
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: PKBAppState().tertiaryColor,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: _headingAlign(loc),
                        child: Padding(
                          padding: _headingPadding(loc),
                          child: Text(
                            loc.getText('color_accent').isNotEmpty
                                ? loc.getText('color_accent')
                                : 'Accent color',
                            style: PillKaBooTheme.of(context).headlineMedium.override(
                              fontFamily: PillKaBooTheme.of(context).headlineMediumFamily,
                              color: PKBAppState().secondaryColor,
                              fontSize: 25.0,
                              fontWeight: _weightForLocale(loc),
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  PillKaBooTheme.of(context).headlineMediumFamily),
                            ),
                          ),
                        ),
                      ),
                      buildColorRow(0, ['Black', 'White', 'Gray'], 0),
                      buildColorRow(3, ['Blue', 'Red', 'Yellow'],0),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildColorRow(int startIndex, List<String> colors, int appColorIndex) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(colors.length, (index) {
          Color containerColor = getColorFromName(colors[index]);

          bool isSelected;
          if (appColorIndex == 0) {
            isSelected = containerColor == PKBAppState().primaryColor;
          } else if (appColorIndex == 1) {
            isSelected = containerColor == PKBAppState().secondaryColor;
          } else { // appColorIndex == 2
            isSelected = containerColor == PKBAppState().tertiaryColor;
          }

          return GestureDetector(
            onTap: () {
              Vibration.vibrate();
              setState(() {
                if (appColorIndex == 0) {
                  GlobalAudioPlayer().playOnce();
                  PKBAppState().primaryColor = containerColor;
                } else if (appColorIndex == 1) {
                  GlobalAudioPlayer().playOnce();
                  PKBAppState().secondaryColor = containerColor;
                } else if (appColorIndex == 2) {
                  GlobalAudioPlayer().playOnce();
                  PKBAppState().tertiaryColor = containerColor;
                }
              });
            },
            child: Container(
              width: 90.0,
              height: 75.0,
              margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(26.0),
                border: isSelected ? Border.all(color: Colors.greenAccent, width: 4.0) : null,
              ),
              alignment: Alignment.center,
              child: Builder(builder: (context) {
                final loc = PKBLocalizations.of(context);
                String key = colors[index].toLowerCase();
                String label = colors[index];
                switch (key) {
                  case 'black':
                    label = loc.getText('color_black').isNotEmpty ? loc.getText('color_black') : 'Black';
                    break;
                  case 'white':
                    label = loc.getText('color_white').isNotEmpty ? loc.getText('color_white') : 'White';
                    break;
                  case 'gray':
                    label = loc.getText('color_gray').isNotEmpty ? loc.getText('color_gray') : 'Gray';
                    break;
                  case 'blue':
                    label = loc.getText('color_blue').isNotEmpty ? loc.getText('color_blue') : 'Blue';
                    break;
                  case 'red':
                    label = loc.getText('color_red').isNotEmpty ? loc.getText('color_red') : 'Red';
                    break;
                  case 'yellow':
                    label = loc.getText('color_yellow').isNotEmpty ? loc.getText('color_yellow') : 'Yellow';
                    break;
                }
                return Text(
                  label,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: _weightForLocale(loc),
                    color: colors[index].toLowerCase() == 'black' ? Colors.white : Colors.black,
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }


  Color getColorFromName(String colorName) {
    switch (colorName) {
      case 'Black':
        return Colors.black;
      case 'White':
        return Colors.white;
      case 'Gray':
        return const Color(0xFF797676);
      case 'Blue':
        return const Color(0xFF4285F4);
      case 'Red':
        return const Color(0xFFFF0132);
      case 'Yellow':
        return const Color(0xFFF9E000);
      default:
        return Colors.transparent; // Fallback color
    }
  }

}
