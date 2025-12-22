import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/pillkaboo_util.dart';
import '../../../../app/tts/tts_service.dart';
import '../../../styles/pillkaboo_theme.dart';
import '../../../widgets/index.dart' as widgets;
import 'font_size_page_model.dart';
export 'font_size_page_model.dart';

class FontSizePageWidget extends StatefulWidget {
  const FontSizePageWidget({super.key});

  @override
  State<FontSizePageWidget> createState() => _FontSizePageWidgetState();
}

class _FontSizePageWidgetState extends State<FontSizePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _model = FontSizePageModel();

  final List<double> _scales = [1.0, 1.2, 1.4];

  FontWeight _weightForLocale(PKBLocalizations loc) =>
      loc.languageCode == 'ur' ? FontWeight.w800 : FontWeight.bold;

  String _labelForScale(double scale, PKBLocalizations loc) {
    if (scale == 1.0) {
      return loc.getText('font_size_standard').isNotEmpty
          ? loc.getText('font_size_standard')
          : 'Standard';
    }
    if (scale == 1.2) {
      return loc.getText('font_size_large').isNotEmpty
          ? loc.getText('font_size_large')
          : 'Large';
    }
    return loc.getText('font_size_xlarge').isNotEmpty
        ? loc.getText('font_size_xlarge')
        : 'Extra large';
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

    final loc = PKBLocalizations.of(context);
    final appState = context.watch<PKBAppState>();
    final currentScale = appState.textScale;
    final screenHeight = MediaQuery.of(context).size.height;
    double appBarFontSize = (30.0 / 892.0 * screenHeight).clamp(20.0, 26.0);
    double textSize = (24.0 / 892.0 * screenHeight).clamp(18.0, 22.0);

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
            label: loc.getText('settings_font_size').isNotEmpty
                ? loc.getText('settings_font_size')
                : 'Text size',
            child: ExcludeSemantics(
              excluding: true,
              child: Text(
                loc.getText('settings_font_size').isNotEmpty
                    ? loc.getText('settings_font_size')
                    : 'Text size',
                style: PillKaBooTheme.of(context).headlineMedium.override(
                      fontFamily:
                          PillKaBooTheme.of(context).headlineMediumFamily,
                      color: PKBAppState().secondaryColor,
                      fontSize: appBarFontSize,
                      fontWeight: _weightForLocale(loc),
                      useGoogleFonts: GoogleFonts.asMap().containsKey(
                          PillKaBooTheme.of(context).headlineMediumFamily),
                    ),
              ),
            ),
          ),
          actions: const [widgets.HomeButtonWidget()],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    loc.getText('font_size_desc').isNotEmpty
                        ? loc.getText('font_size_desc')
                        : 'Pick a text size that is comfortable for you.',
                    style: TextStyle(
                      fontSize: 15.5,
                      color: PKBAppState().secondaryColor.withOpacity(0.7),
                      fontWeight: _weightForLocale(loc),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._scales.map((scale) {
                  final label = _labelForScale(scale, loc);
                  final isSelected = currentScale == scale;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: Material(
                      color: PKBAppState().tertiaryColor,
                      borderRadius: BorderRadius.circular(20.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20.0),
                        highlightColor: PKBAppState().secondaryColor.withOpacity(0.1),
                        splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
                        onTap: () {
                          Vibration.vibrate(duration: 40);
                          appState.textScale = scale;
                          TtsService().stop();
                          TtsService().speak(
                            loc.getVariableText(
                              enText: '$label selected.',
                              urText: '$label منتخب کیا گیا ہے۔',
                            ),
                          );
                          setState(() {});
                        },
                        onLongPress: () {
                          Vibration.vibrate(duration: 40);
                          appState.textScale = scale;
                          TtsService().stop();
                          TtsService().speak(
                            loc.getVariableText(
                              enText: '$label selected.',
                              urText: '$label منتخب کیا گیا ہے۔',
                            ),
                          );
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: isSelected
                                  ? PKBAppState().secondaryColor
                                  : PKBAppState().secondaryColor.withOpacity(0.5),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: textSize,
                                    color: PKBAppState().secondaryColor,
                                    fontWeight: _weightForLocale(loc),
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: PKBAppState().secondaryColor,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
