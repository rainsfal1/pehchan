import '../../../../../core/pillkaboo_util.dart';
import '../../../../styles/pillkaboo_theme.dart';
import '../../../../widgets/index.dart' as widgets;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'allergy_list_page_model.dart';
export 'allergy_list_page_model.dart';

class AllergyListPageWidget extends StatefulWidget {
  const AllergyListPageWidget({super.key});

  @override
  State<AllergyListPageWidget> createState() => _AllergyListPageWidgetState();
}

class _AllergyListPageWidgetState extends State<AllergyListPageWidget> {
  late AllergyListPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  FontWeight _weightForLocale(PKBLocalizations loc) =>
      loc.languageCode == 'ur' ? FontWeight.w800 : FontWeight.bold;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllergyListPageModel());
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
    final screenHeight = MediaQuery.of(context).size.height;
    double appBarFontSize = (30.0/892.0 * screenHeight).clamp(20.0, 26.0);
    double backIconSize = (30.0/892.0 * screenHeight).clamp(18.0, 24.0);

    context.watch<PKBAppState>();

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
            label: loc.getText('settings_allergy').isNotEmpty ? loc.getText('settings_allergy') : 'Allergy settings',
            child: ExcludeSemantics(
              excluding: true,
              child: Text(
                loc.getText('settings_allergy').isNotEmpty ? loc.getText('settings_allergy') : 'Allergy settings',
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
          actions: const [
            widgets.HomeButtonWidget(),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: PKBAppState().tertiaryColor,
                    borderRadius: BorderRadius.circular(26.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(26.0),
                      highlightColor: PKBAppState().secondaryColor.withOpacity(0.1),
                      splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
                      onTap: () async {
                        context.pushReplacement('/allergyAddPage');
                      },
                      onLongPress: () async {
                        context.pushReplacement('/allergyAddPage');
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 52.35,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(
                            color: PKBAppState().secondaryColor,
                            width: 1.0,
                          ),
                        ),
                        alignment: const Alignment(0, 0),
                        child: Text(
                          loc.getText('allergy_add_button').isNotEmpty
                              ? loc.getText('allergy_add_button')
                              : 'Add',
                          style: TextStyle(
                            color: PKBAppState().secondaryColor,
                            fontSize: backIconSize,
                            fontFamily: 'Pretendard',
                            fontWeight: _weightForLocale(loc),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PKBAppState().userAllergies.isNotEmpty
                    ? ListView.builder(
                        itemCount: PKBAppState().userAllergies.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                            child: Material(
                              color: PKBAppState().tertiaryColor,
                              borderRadius: BorderRadius.circular(14.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14.0),
                                highlightColor: PKBAppState().secondaryColor.withOpacity(0.08),
                                splashColor: PKBAppState().secondaryColor.withOpacity(0.1),
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14.0),
                                    border: Border.all(color: PKBAppState().secondaryColor.withOpacity(0.5), width: 1.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          PKBAppState().userAllergies[index],
                                          style: TextStyle(
                                            color: PKBAppState().secondaryColor,
                                            fontSize: 18,
                                            fontWeight: _weightForLocale(loc),
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(12.0),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(12.0),
                                          highlightColor: PKBAppState().secondaryColor.withOpacity(0.1),
                                          splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
                                          onTap: () {
                                            setState(() {
                                              PKBAppState().userAllergies.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12.0),
                                              border: Border.all(
                                                color: PKBAppState().secondaryColor.withOpacity(0.5),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: SvgPicture.asset(
                                              'assets/images/trash.svg',
                                              height: 24,
                                              colorFilter: ColorFilter.mode(
                                                PKBAppState().secondaryColor,
                                                BlendMode.srcIn,
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
                          );
                  },
                )
                    : Container()
              ),
              ],
          ),
        ),
      ),
    );
  }
}
