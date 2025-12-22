import 'package:pillkaboo/src/app/tts/tts_service.dart';

import '../../../widgets/index.dart' as widgets;
import '../../../styles/pillkaboo_theme.dart';
import '../../../../core/pillkaboo_util.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


import 'help_page_model.dart';
export 'help_page_model.dart';


class HelpPageWidget extends StatefulWidget {
  const HelpPageWidget({super.key});
  @override
  State<HelpPageWidget> createState() => _HelpPageWidgetState();
}
class _HelpPageWidgetState extends State<HelpPageWidget> {
  late HelpPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool showMed = false;
  bool showRx = false;
  bool showAllergy = false;
  bool showAudio = false;
  bool showSource = false;
  bool showMyMeds = false;

  String howToRecognizeMedicine(BuildContext context) =>
      PKBLocalizations.of(context).getText('help_text_med');
  String howToRecognizePrescribed(BuildContext context) =>
      PKBLocalizations.of(context).getText('help_text_rx');
  String howToAddAllergies(BuildContext context) =>
      PKBLocalizations.of(context).getText('help_text_allergy');
  String howToUseAudio(BuildContext context) =>
      PKBLocalizations.of(context).getText('help_text_audio');
  String medCitation(BuildContext context) =>
      PKBLocalizations.of(context).getText('help_text_source').isNotEmpty
          ? PKBLocalizations.of(context).getText('help_text_source')
          : "Current medicine info is from the bundled database.";
  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HelpPageModel());
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
    final fontWeight =
        loc.languageCode == 'ur' ? FontWeight.w800 : FontWeight.bold;
    final screenHeight = MediaQuery.of(context).size.height;
    double imageContainerSize = (70.0/892.0 * screenHeight).clamp(46.0, 70.0);
    double appBarFontSize = (30.0/892.0 * screenHeight).clamp(20.0, 26.0);
    double textFontSize = (26.0/892.0 * screenHeight).clamp(20.0, 24.0);

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
            label: loc.getText('help_title').isNotEmpty ? loc.getText('help_title') : 'Help',
            child: ExcludeSemantics(
              excluding: true,
              child: Text(
                loc.getText('help_title').isNotEmpty ? loc.getText('help_title') : 'Help',
                style: PillKaBooTheme.of(context).headlineMedium.override(
                  fontFamily: PillKaBooTheme.of(context).headlineMediumFamily,
                  color: PKBAppState().secondaryColor,
                  fontSize: appBarFontSize,
                  fontWeight: fontWeight,
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
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.getText('help_subtitle').isNotEmpty
                          ? loc.getText('help_subtitle')
                          : 'Quick tips and guidance.',
                      style: TextStyle(
                        color: PKBAppState().secondaryColor.withOpacity(0.65),
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _helpTile(
                  context: context,
                  label: loc.getText('help_medicine').isNotEmpty
                      ? loc.getText('help_medicine')
                      : 'Medicine Scan',
                  content: howToRecognizeMedicine(context),
                  iconPath: 'assets/images/medicine.svg',
                  imageContainerSize: imageContainerSize,
                  textFontSize: textFontSize,
                  fontWeight: fontWeight,
                  expanded: showMed,
                  onToggle: () {
                    _speakAndMaybeNavigate(howToRecognizeMedicine(context));
                    setState(() => showMed = !showMed);
                  },
                ),
                _helpTile(
                  context: context,
                  label: loc.getText('help_prescription').isNotEmpty
                      ? loc.getText('help_prescription')
                      : 'Prescription Scan',
                  content: howToRecognizePrescribed(context),
                  iconPath: 'assets/images/prescription.svg',
                  imageContainerSize: imageContainerSize,
                  textFontSize: textFontSize,
                  fontWeight: fontWeight,
                  expanded: showRx,
                  onToggle: () {
                    _speakAndMaybeNavigate(howToRecognizePrescribed(context));
                    setState(() => showRx = !showRx);
                  },
                ),
                _helpTile(
                  context: context,
                  label: loc.getText('help_allergy').isNotEmpty
                      ? loc.getText('help_allergy')
                      : 'Allergy settings',
                  content: howToAddAllergies(context),
                  iconPath: 'assets/images/allergy.svg',
                  imageContainerSize: imageContainerSize,
                  textFontSize: textFontSize,
                  fontWeight: fontWeight,
                  expanded: showAllergy,
                  onToggle: () {
                    _speakAndMaybeNavigate(howToAddAllergies(context));
                    setState(() => showAllergy = !showAllergy);
                  },
                ),
                _helpTile(
                  context: context,
                  label: loc.getText('help_my_meds').isNotEmpty
                      ? loc.getText('help_my_meds')
                      : 'My medicines',
                  content: PKBLocalizations.of(context).getText('help_text_my_meds').isNotEmpty
                      ? PKBLocalizations.of(context).getText('help_text_my_meds')
                      : 'Save recognized medicines for quick access and reminders. You can review, edit, or remove them anytime.',
                  iconPath: 'assets/images/medicine.svg',
                  imageContainerSize: imageContainerSize,
                  textFontSize: textFontSize,
                  fontWeight: fontWeight,
                  expanded: showMyMeds,
                  onToggle: () {
                    _speakAndMaybeNavigate(
                      PKBLocalizations.of(context).getText('help_text_my_meds').isNotEmpty
                          ? PKBLocalizations.of(context).getText('help_text_my_meds')
                          : 'Save recognized medicines for quick access and reminders. You can review, edit, or remove them anytime.',
                    );
                    setState(() => showMyMeds = !showMyMeds);
                  },
                ),
                _helpTile(
                  context: context,
                  label: loc.getText('help_audio').isNotEmpty
                      ? loc.getText('help_audio')
                      : 'Audio settings',
                  content: howToUseAudio(context),
                  iconPath: 'assets/images/help.svg',
                  imageContainerSize: imageContainerSize,
                  textFontSize: textFontSize,
                  fontWeight: fontWeight,
                  expanded: showAudio,
                  onToggle: () {
                    _speakAndMaybeNavigate(howToUseAudio(context));
                    setState(() => showAudio = !showAudio);
                  },
                ),
                _buildHelpLinkTile(
                  context: context,
                  label: loc.getText('help_source').isNotEmpty
                      ? loc.getText('help_source')
                      : 'Medicine info source',
                  linkText: '',
                  iconPath: 'assets/images/setting.svg',
                  imageContainerSize: imageContainerSize,
                  textFontSize: textFontSize,
                  fontWeight: fontWeight,
                  onTap: () => launchUrl(Uri.parse('https://www.dra.gov.pk')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _speakAndMaybeNavigate(String text) {
    if (!PKBAppState().useScreenReader) {
      TtsService().stop();
      TtsService().speak(text);
    }
  }

  Widget _helpTile({
    required BuildContext context,
    required String label,
    required String content,
    required String iconPath,
    required double imageContainerSize,
    required double textFontSize,
    required FontWeight fontWeight,
    required bool expanded,
    required VoidCallback onToggle,
  }) {
    final secondary = PKBAppState().secondaryColor;
    return Semantics(
      container: true,
      label: content,
      child: ExcludeSemantics(
        excluding: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Material(
            color: PKBAppState().tertiaryColor,
            borderRadius: BorderRadius.circular(20.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20.0),
              highlightColor: secondary.withOpacity(0.1),
              splashColor: secondary.withOpacity(0.12),
              onTap: onToggle,
              onLongPress: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: secondary.withOpacity(0.45),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      iconPath,
                      width: imageContainerSize * 0.85,
                      height: imageContainerSize * 0.85,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PillKaBooTheme.of(context).titleMedium.override(
                                  fontFamily: PillKaBooTheme.of(context).titleMediumFamily,
                                  fontSize: textFontSize,
                                  color: secondary,
                                  fontWeight: fontWeight,
                                  useGoogleFonts: GoogleFonts.asMap().containsKey(
                                      PillKaBooTheme.of(context).titleMediumFamily),
                                ),
                          ),
                          if (expanded) ...[
                            const SizedBox(height: 10),
                            Text(
                              content,
                              style: TextStyle(
                                color: secondary,
                                fontSize: 18,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: secondary.withOpacity(0.85),
                      size: 22,
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

  Widget _buildHelpLinkTile({
    required BuildContext context,
    required String label,
    required String linkText,
    required String iconPath,
    required double imageContainerSize,
    required double textFontSize,
    required FontWeight fontWeight,
    required VoidCallback onTap,
  }) {
    final secondary = PKBAppState().secondaryColor;
    return Semantics(
      container: true,
      label: linkText,
      child: ExcludeSemantics(
        excluding: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Material(
            color: PKBAppState().tertiaryColor,
            borderRadius: BorderRadius.circular(20.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20.0),
              highlightColor: secondary.withOpacity(0.1),
              splashColor: secondary.withOpacity(0.12),
              onTap: onTap,
              onLongPress: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: secondary.withOpacity(0.45),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      iconPath,
                      width: imageContainerSize * 0.85,
                      height: imageContainerSize * 0.85,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            style: PillKaBooTheme.of(context).titleMedium.override(
                                  fontFamily: PillKaBooTheme.of(context).titleMediumFamily,
                                  fontSize: textFontSize,
                                  color: secondary,
                                  fontWeight: fontWeight,
                                  useGoogleFonts: GoogleFonts.asMap().containsKey(
                                      PillKaBooTheme.of(context).titleMediumFamily),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.open_in_new_rounded,
                      color: secondary.withOpacity(0.85),
                      size: 22,
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
