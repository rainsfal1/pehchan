import '../../../widgets/index.dart' as widgets;
import '../../../styles/pillkaboo_theme.dart';
import '../../../../core/pillkaboo_util.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibration/vibration.dart';
import 'package:pillkaboo/src/app/tts/tts_service.dart';

import 'settings_menu_page_model.dart';
export 'settings_menu_page_model.dart';



class SettingsMenuPageWidget extends StatefulWidget {
  const SettingsMenuPageWidget({super.key});

  @override
  State<SettingsMenuPageWidget> createState() => _SettingsMenuPageWidgetState();
}

class _SettingsMenuPageWidgetState extends State<SettingsMenuPageWidget> {
  late SettingsMenuPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsMenuPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = PKBLocalizations.of(context);
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    context.watch<PKBAppState>();

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    double containerHeight = (111.0/892.0 * screenHeight).clamp(92.0, 126.0);
    double containerWidth = screenWidth - 40.0;
    double iconSize = (70.0/892.0 * screenHeight).clamp(44.0, 64.0);
    double smallerIconSize = (60.0/892.0 * screenHeight).clamp(40.0, 56.0);
    double textSize = (22.0/892.0 * screenHeight).clamp(16.0, 20.0);
    double appBarFontSize = (30.0/892.0 * screenHeight).clamp(20.0, 26.0);

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
            label: loc.getText('menu_settings').isNotEmpty ? loc.getText('menu_settings') : 'Settings',
            child: ExcludeSemantics(
              excluding: true,
              child: Text(
                loc.getText('menu_settings').isNotEmpty ? loc.getText('menu_settings') : 'Settings',
                style: PillKaBooTheme.of(context).headlineMedium.override(
                  fontFamily: PillKaBooTheme.of(context).headlineMediumFamily,
                  color: PKBAppState().secondaryColor,
                  fontSize: appBarFontSize,
                  fontWeight: FontWeight.bold,
                  useGoogleFonts: GoogleFonts.asMap().containsKey(PillKaBooTheme.of(context).headlineMediumFamily),
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
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.getText('settings_subtitle').isNotEmpty
                          ? loc.getText('settings_subtitle')
                          : 'Customize how Pehchan speaks and looks.',
                     style: TextStyle(
                       color: PKBAppState().secondaryColor.withOpacity(0.6),
                       fontSize: 15.5,
                     ),
                   ),
                 ),
                ),
                const SizedBox(height: 10),
                _settingsTile(
                  context: context,
                  label: loc.getText('settings_language').isNotEmpty
                      ? loc.getText('settings_language')
                      : 'Language',
                  iconPath: 'assets/images/globe-language.svg',
                  iconSize: smallerIconSize,
                  onTap: () => _handleTap(
                    label: loc.getText('settings_language').isNotEmpty
                        ? loc.getText('settings_language')
                        : 'Language',
                    route: '/languagePage',
                  ),
                  containerWidth: containerWidth,
                  containerHeight: containerHeight,
                  textSize: textSize,
                ),
                _settingsTile(
                  context: context,
                  label: loc.getText('settings_allergy').isNotEmpty
                      ? loc.getText('settings_allergy')
                      : 'Allergy settings',
                  iconPath: 'assets/images/allergy.svg',
                  iconSize: iconSize,
                  onTap: () => _handleTap(
                    label: loc.getText('settings_allergy').isNotEmpty
                        ? loc.getText('settings_allergy')
                        : 'Allergy settings',
                    route: '/allergyListPage',
                  ),
                  containerWidth: containerWidth,
                  containerHeight: containerHeight,
                  textSize: textSize,
                ),
                _settingsTile(
                  context: context,
                  label: loc.getText('settings_color').isNotEmpty
                      ? loc.getText('settings_color')
                      : 'Color settings',
                  iconPath: 'assets/images/color-palette.svg',
                  iconSize: iconSize,
                  onTap: () => _handleTap(
                    label: loc.getText('settings_color').isNotEmpty
                        ? loc.getText('settings_color')
                        : 'Color settings',
                    route: '/pickColorPage',
                  ),
                  containerWidth: containerWidth,
                  containerHeight: containerHeight,
                  textSize: textSize,
                ),
                _settingsTile(
                  context: context,
                  label: loc.getText('settings_audio').isNotEmpty
                      ? loc.getText('settings_audio')
                      : 'Audio settings',
                  iconPath: 'assets/images/speaker.svg',
                  iconSize: smallerIconSize,
                  onTap: () => _handleTap(
                    label: loc.getText('settings_audio').isNotEmpty
                        ? loc.getText('settings_audio')
                        : 'Audio settings',
                    route: '/controlTTSPage',
                  ),
                  containerWidth: containerWidth,
                  containerHeight: containerHeight,
                  textSize: textSize,
                ),
                _settingsTile(
                  context: context,
                  label: loc.getText('settings_font_size').isNotEmpty
                      ? loc.getText('settings_font_size')
                      : 'Text size',
                  iconPath: 'assets/images/text-font-size.svg',
                  iconSize: iconSize,
                  onTap: () => _handleTap(
                    label: loc.getText('settings_font_size').isNotEmpty
                        ? loc.getText('settings_font_size')
                        : 'Text size',
                    route: '/fontSizePage',
                  ),
                  containerWidth: containerWidth,
                  containerHeight: containerHeight,
                  textSize: textSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap({required String label, required String route}) {
    if (!PKBAppState().useScreenReader && !PKBAppState().silentMode) {
      Vibration.vibrate(duration: 40);
      TtsService().stop();
      TtsService().speak(label);
    }
    context.pushReplacement(route);
  }

  Widget _settingsTile({
    required BuildContext context,
    required String label,
    required String iconPath,
    required double iconSize,
    required VoidCallback onTap,
    required double containerWidth,
    required double containerHeight,
    required double textSize,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Semantics(
        container: true,
        label: label,
        explicitChildNodes: false,
        child: ExcludeSemantics(
          excluding: true,
          child: Material(
            color: PKBAppState().tertiaryColor,
            borderRadius: BorderRadius.circular(22.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(22.0),
              highlightColor: PKBAppState().secondaryColor.withOpacity(0.1),
              splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
              onTap: onTap,
              child: Container(
                width: containerWidth,
                height: containerHeight,
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(
                    color: PKBAppState().secondaryColor.withOpacity(0.5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      iconPath,
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        PKBAppState().secondaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
