import 'package:pillkaboo/main.dart';
import 'package:pillkaboo/src/core/pillkaboo_util.dart';
import 'package:go_router/go_router.dart';
import '../../../styles/pillkaboo_theme.dart';
import '../../../widgets/index.dart' as widgets;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'language_page_model.dart';
export 'language_page_model.dart';

class LanguagePageWidget extends StatefulWidget {
  const LanguagePageWidget({super.key});

  @override
  State<LanguagePageWidget> createState() => _LanguagePageWidgetState();
}

class _LanguagePageWidgetState extends State<LanguagePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _model = LanguagePageModel();

  FontWeight _weightForLocale(BuildContext context) =>
      PKBLocalizations.of(context).languageCode == 'ur'
          ? FontWeight.w800
          : FontWeight.bold;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  void _setLanguage(String code) {
    MyApp.of(context).setLocale(code);
    context.go('/settingsMenuPage');
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
    final screenHeight = MediaQuery.of(context).size.height;
    double appBarFontSize = (30.0 / 892.0 * screenHeight).clamp(20.0, 26.0);
    double textSize = (26.0 / 892.0 * screenHeight).clamp(18.0, 22.0);

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
          label: loc.getText('language_title').isNotEmpty
              ? loc.getText('language_title')
              : 'Language',
          child: ExcludeSemantics(
            excluding: true,
            child: Text(
              loc.getText('language_title').isNotEmpty
                  ? loc.getText('language_title')
                  : 'Language',
              style: PillKaBooTheme.of(context).headlineMedium.override(
                    fontFamily:
                        PillKaBooTheme.of(context).headlineMediumFamily,
                    color: PKBAppState().secondaryColor,
                    fontSize: appBarFontSize,
                    fontWeight: _weightForLocale(context),
                    useGoogleFonts: GoogleFonts.asMap().containsKey(
                        PillKaBooTheme.of(context).headlineMediumFamily),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                      child: Text(
                        loc.getText('language_subtitle').isNotEmpty
                            ? loc.getText('language_subtitle')
                            : 'Choose the language for Pehchan.',
                      style: TextStyle(
                        color: PKBAppState().secondaryColor.withOpacity(0.65),
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _languageTile(
                  context: context,
                  label: loc.getText('language_en').isNotEmpty
                      ? loc.getText('language_en')
                      : 'English',
                  code: 'en',
                  textSize: textSize,
                ),
                _languageTile(
                  context: context,
                  label: loc.getText('language_ur').isNotEmpty
                      ? loc.getText('language_ur')
                      : 'اردو',
                  code: 'ur',
                  textSize: textSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _languageTile({
    required BuildContext context,
    required String label,
    required String code,
    required double textSize,
  }) {
    final secondary = PKBAppState().secondaryColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Material(
        color: PKBAppState().tertiaryColor,
        borderRadius: BorderRadius.circular(22.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(22.0),
          highlightColor: secondary.withOpacity(0.1),
          splashColor: secondary.withOpacity(0.12),
          onTap: () => _setLanguage(code),
          onLongPress: () => _setLanguage(code),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.0),
              border: Border.all(
                color: secondary.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: textSize,
                      color: secondary,
                      fontWeight: _weightForLocale(context),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
