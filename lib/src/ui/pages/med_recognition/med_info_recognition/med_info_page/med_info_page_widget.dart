import 'package:pillkaboo/src/app/tts/tts_service.dart';
import '../../../../../app/global_audio_player.dart';
import '../../../../../core/pillkaboo_util.dart';
import '../../../../styles/pillkaboo_icon_button.dart';
import '../../../../styles/pillkaboo_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'med_info_page_model.dart';
export 'med_info_page_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_svg/flutter_svg.dart';
class MedInfoPageWidget extends StatefulWidget {
  const MedInfoPageWidget({super.key});
  @override
  State<MedInfoPageWidget> createState() => _MedInfoPageWidgetState();
}
class _MedInfoPageWidgetState extends State<MedInfoPageWidget> {
  late MedInfoPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool showChildText = false;  
  bool showExprDateText = false;
  bool showIngredientText = false;
  bool showHowToTakeText = false;
  bool showWarningText = false;
  bool showSideEffectText = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MedInfoPageModel());
    TtsService().stop();
    GlobalAudioPlayer().playOnce();
  }
  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
  void clearAndNavigate(BuildContext context) {
    TtsService().stop();
    while (context.canPop() == true) {
      context.pop();
    }
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
    context.watch<PKBAppState>();
    String childText = '', exprDateText = '', ingredientText = '', howToTakeText = '', warningText = '', sideEffectText = '';
    
    if (PKBAppState().foundAllergies == '') {
      childText = 'No registered allergens found in this medicine.';
    } else {
      childText = 'Caution: ${PKBAppState().foundAllergies} allergen(s) detected.';
    }
    if (PKBAppState().infoExprDate == '') {
      exprDateText = 'No expiry information available.';
    } else {
      exprDateText = 'Use by ${PKBAppState().infoExprDate}';
    }
    if (PKBAppState().infoIngredient == '') {
      ingredientText = 'No ingredient information available.';
    } else {
      ingredientText = 'Ingredient: ${PKBAppState().infoIngredient}';
    }
    if (PKBAppState().infoHowToTake == '') {
      howToTakeText = 'No dosage instructions available.';
    } else {
      howToTakeText = 'How to take: ${PKBAppState().infoHowToTake}';
    }
    if (PKBAppState().infoWarning == '') {
      warningText = 'No warnings available.';
    } else {
      warningText = 'Warning: ${PKBAppState().infoWarning}';
    }
    if (PKBAppState().infoSideEffect == '') {
      sideEffectText = 'No side-effect info available.';
    } else {
      sideEffectText = 'Side effects: ${PKBAppState().infoSideEffect}';
    }

    final screenHeight = MediaQuery.of(context).size.height;
    double imageContainerSize = 65.0/892.0 * screenHeight;
    double backIconSize = 30.0/892.0 * screenHeight;
    double appBarFontSize = (30.0/892.0 * screenHeight).clamp(20.0, 26.0);
    double textFontSize = (28.0/892.0 * screenHeight).clamp(18.0, 24.0);

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
              label: 'Medicine information',
              child: ExcludeSemantics(
                excluding: true,
                child: Text(
                  'Medicine information',
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
            actions: [
              Semantics(
                            label: 'Go to home. Double tap to activate.',
                child: ExcludeSemantics(
                  excluding: true,
                  child: PillKaBooIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 60.0,
                    icon: Icon(
                      Icons.home,
                      color: PKBAppState().secondaryColor,
                      size: backIconSize,
                    ),
                    onPressed: () async {
                      setState(() {
                        PKBAppState().infoMedName = "";
                        PKBAppState().infoExprDate = "";
                        PKBAppState().infoHowToTake = "";
                        PKBAppState().infoWarning = "";
                        PKBAppState().infoSideEffect = "";
                        PKBAppState().infoIngredient = "";
                        PKBAppState().infoChild = "";
                        PKBAppState().foundAllergies = "";
                      });
                      clearAndNavigate(context);
                    },
                  ),
                ),
              ),
            ],
            centerTitle: false,
            elevation: 2.0,
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                    child: Semantics(
                      label: 'Medicine name ${PKBAppState().infoMedName}',
                      child: ExcludeSemantics(
                        excluding: true,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          decoration: BoxDecoration(
                            color: PKBAppState().primaryColor.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(18.0),
                            border: Border.all(color: PKBAppState().secondaryColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            PKBAppState().infoMedName.isEmpty
                                ? 'Unknown medicine'
                                : PKBAppState().infoMedName,
                            textAlign: TextAlign.center,
                            style: PillKaBooTheme.of(context).headlineMedium.override(
                              fontFamily: PillKaBooTheme.of(context).headlineMediumFamily,
                              color: PKBAppState().secondaryColor,
                              fontSize: appBarFontSize,
                              fontWeight: FontWeight.w800,
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                PillKaBooTheme.of(context).headlineMediumFamily,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildInfoTile(
                    context: context,
                    title: 'Allergies',
                    content: childText,
                    iconAsset: 'assets/images/allergy.svg',
                    expanded: showChildText,
                    onToggle: () => setState(() => showChildText = !showChildText),
                    semanticsLabel: childText,
                    imageContainerSize: imageContainerSize,
                    textFontSize: textFontSize,
                  ),
                  _buildInfoTile(
                    context: context,
                    title: 'Expiry',
                    content: exprDateText,
                    iconAsset: 'assets/images/date.svg',
                    expanded: showExprDateText,
                    onToggle: () => setState(() => showExprDateText = !showExprDateText),
                    semanticsLabel: exprDateText,
                    imageContainerSize: imageContainerSize,
                    textFontSize: textFontSize,
                  ),
                  _buildInfoTile(
                    context: context,
                    title: 'Ingredients',
                    content: ingredientText,
                    iconAsset: 'assets/images/ing.svg',
                    expanded: showIngredientText,
                    onToggle: () => setState(() => showIngredientText = !showIngredientText),
                    semanticsLabel: ingredientText,
                    imageContainerSize: imageContainerSize,
                    textFontSize: textFontSize,
                  ),
                  _buildInfoTile(
                    context: context,
                    title: 'How to take',
                    content: howToTakeText,
                    iconAsset: 'assets/images/howeat.svg',
                    expanded: showHowToTakeText,
                    onToggle: () => setState(() => showHowToTakeText = !showHowToTakeText),
                    semanticsLabel: howToTakeText,
                    imageContainerSize: imageContainerSize,
                    textFontSize: textFontSize,
                  ),
                  _buildInfoTile(
                    context: context,
                    title: 'Warnings',
                    content: warningText,
                    iconAsset: 'assets/images/warning.svg',
                    expanded: showWarningText,
                    onToggle: () => setState(() => showWarningText = !showWarningText),
                    semanticsLabel: warningText,
                    imageContainerSize: imageContainerSize,
                    textFontSize: textFontSize,
                  ),
                  _buildInfoTile(
                    context: context,
                    title: 'Side effects',
                    content: sideEffectText,
                    iconAsset: 'assets/images/sideef.svg',
                    expanded: showSideEffectText,
                    onToggle: () => setState(() => showSideEffectText = !showSideEffectText),
                    semanticsLabel: sideEffectText,
                    imageContainerSize: imageContainerSize,
                    textFontSize: textFontSize,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Semantics(
                      container: true,
                      label: PKBLocalizations.of(context).getText('save_to_my_medicines'),
                      child: Material(
                      color: PKBAppState().primaryColor,
                      borderRadius: BorderRadius.circular(26.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(26.0),
                        highlightColor: PKBAppState().tertiaryColor.withOpacity(0.1),
                        splashColor: PKBAppState().tertiaryColor.withOpacity(0.12),
                        onTap: _showSaveConfirmation,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 60.0,
                          alignment: Alignment.center,
                          child: ExcludeSemantics(
                            excluding: true,
                            child: Text(
                              PKBLocalizations.of(context).getText('save_to_my_medicines'),
                              style: TextStyle(
                                color: PKBAppState().tertiaryColor,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required String title,
    required String content,
    required String iconAsset,
    required bool expanded,
    required VoidCallback onToggle,
    required String semanticsLabel,
    required double imageContainerSize,
    required double textFontSize,
  }) {
    final secondary = PKBAppState().secondaryColor;
    final baseColor = Colors.transparent;
    final overlayColor = secondary.withOpacity(0.12);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      child: Semantics(
        container: true,
        label: semanticsLabel,
        hint: 'Tap to expand or collapse',
        child: ExcludeSemantics(
          excluding: true,
          child: Material(
            color: baseColor,
            borderRadius: BorderRadius.circular(18.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(18.0),
              highlightColor: overlayColor,
              splashColor: overlayColor,
              onTap: () {
                if (!PKBAppState().useScreenReader) {
                  TtsService().stop();
                  TtsService().speak(content);
                }
                onToggle();
              },
              onLongPress: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(color: secondary.withOpacity(0.22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: imageContainerSize,
                          height: imageContainerSize,
                          child: Center(
                            child: SvgPicture.asset(
                              iconAsset,
                              width: imageContainerSize * 0.7,
                              height: imageContainerSize * 0.7,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                secondary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: PillKaBooTheme.of(context).titleMedium.override(
                              fontFamily:
                                  PillKaBooTheme.of(context).titleMediumFamily,
                              fontSize: textFontSize,
                              color: secondary,
                              fontWeight: FontWeight.bold,
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  PillKaBooTheme.of(context).titleMediumFamily),
                            ),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: secondary.withOpacity(0.85),
                      size: 22,
                    ),
                  ],
                ),
                    if (expanded) ...[
                      const SizedBox(height: 12),
                      Text(
                        content,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSaveConfirmation() {
    final loc = PKBLocalizations.of(context);
    final medicineName = PKBAppState().infoMedName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
            decoration: BoxDecoration(
              color: PKBAppState().tertiaryColor,
              borderRadius: BorderRadius.circular(22.0),
              border: Border.all(
                color: PKBAppState().secondaryColor.withOpacity(0.4),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.getText('confirm_medicine'),
                  style: TextStyle(
                    color: PKBAppState().secondaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  loc.getText('confirm_medicine_text').replaceAll('{medicineName}', medicineName),
                  style: TextStyle(
                    color: PKBAppState().secondaryColor,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.0),
                          highlightColor: PKBAppState().secondaryColor.withOpacity(0.1),
                          splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: PKBAppState().secondaryColor.withOpacity(0.6),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              loc.getText('cancel'),
                              style: TextStyle(
                                color: PKBAppState().secondaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: PKBAppState().primaryColor,
                        borderRadius: BorderRadius.circular(16.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.0),
                          highlightColor: PKBAppState().tertiaryColor.withOpacity(0.1),
                          splashColor: PKBAppState().tertiaryColor.withOpacity(0.12),
                          onTap: () {
                            String category = _determineCategory(medicineName);
                        String source = PKBAppState().recognitionSource;

                        PKBAppState().addMedicine(medicineName, category, source, note: '');

                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  loc.getText('medicine_saved'),
                                  style: TextStyle(color: PKBAppState().tertiaryColor),
                                ),
                                backgroundColor: PKBAppState().primaryColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                context.pushReplacement('/myMedicinesPage');
                              }
                            });
                          },
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: PKBAppState().primaryColor,
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              loc.getText('save_medicine'),
                              style: TextStyle(
                                color: PKBAppState().tertiaryColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _determineCategory(String medicineName) {
    final lowerName = medicineName.toLowerCase();

    if (lowerName.contains('pain') || lowerName.contains('tylenol') ||
        lowerName.contains('ibuprofen') || lowerName.contains('paracetamol')) {
      return 'Pain Relief';
    } else if (lowerName.contains('antibiotic') || lowerName.contains('cillin')) {
      return 'Antibiotic';
    } else if (lowerName.contains('vitamin')) {
      return 'Vitamin';
    } else if (lowerName.contains('allergy') || lowerName.contains('antihistamine')) {
      return 'Allergy';
    } else if (lowerName.contains('cough') || lowerName.contains('cold')) {
      return 'Cold & Cough';
    } else {
      return 'General';
    }
  }
}
