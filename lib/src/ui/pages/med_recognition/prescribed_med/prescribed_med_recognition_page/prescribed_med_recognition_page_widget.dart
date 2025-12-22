import 'dart:async';

import '../../../../../core/pillkaboo_util.dart';
import '../../../../widgets/index.dart' as widgets;
import '../../../../../app/tts/tts_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'prescribed_med_recognition_page_model.dart';
export 'prescribed_med_recognition_page_model.dart';


class PrescribedMedRecognitionPageWidget extends StatefulWidget {
  const PrescribedMedRecognitionPageWidget({super.key});

  @override
  State<PrescribedMedRecognitionPageWidget> createState() => _PrescribedMedRecognitionPageWidgetState();
}

class _PrescribedMedRecognitionPageWidgetState extends State<PrescribedMedRecognitionPageWidget> {
  late PrescribedMedRecognitionPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final StreamController<bool> _controller = StreamController();
  String _instPlaceCameraPack =
      'Hold the camera ~30 cm away, show one prescription packet, flip it, then show again.';


  @override
  void initState() {
    super.initState();
    _controller.stream.listen((success) {
      if (success) {
        if (mounted) {
          context.pushReplacement('/prescribedMedResultPage');
        }
      }
    });
    PKBAppState().slotOfDay = "";
    _model = createModel(context, () => PrescribedMedRecognitionPageModel());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = PKBLocalizations.of(context);
    final val = loc.getText('scan_instruction_rx');
    _instPlaceCameraPack = val.isNotEmpty
        ? val
        : 'Hold the camera ~30 cm away, show one prescription packet, flip it, then show again.';
    if (!PKBAppState().useScreenReader) {
      TtsService().stop();
      TtsService().speak(_instPlaceCameraPack);
    }
  }


  @override
  void dispose() {
    _model.dispose();
    _controller.close();
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
    final headerWeight =
        loc.languageCode == 'ur' ? FontWeight.w800 : FontWeight.bold;

    double appBarFontSize = 24.0/892.0 * MediaQuery.of(context).size.height;
    double appBarHeight = 64.0/892.0 * MediaQuery.of(context).size.height;
    final double manualCtaBottom =
        16.0 + MediaQuery.of(context).padding.bottom.clamp(0.0, 40.0);

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: PKBAppState().tertiaryColor,
        body: SafeArea(
          top: true,
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Stack(
              children: [
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 1.0,
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: widgets.PrescribedMedRecognizerWidget(
                          width: MediaQuery.of(context).size.width * 1.0,
                          height: MediaQuery.of(context).size.height * 0.85,
                          controller: _controller,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: manualCtaBottom,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      highlightColor: PKBAppState().secondaryColor.withOpacity(0.08),
                      splashColor: PKBAppState().secondaryColor.withOpacity(0.12),
                      onTap: () {
                        PKBAppState().clearPrescriptionData();
                        context.push('/manualPrescriptionPage');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        decoration: BoxDecoration(
                          color: PKBAppState().tertiaryColor.withOpacity(0.94),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: PKBAppState().secondaryColor.withOpacity(0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.getText('manual_cta_title').isNotEmpty
                                        ? loc.getText('manual_cta_title')
                                        : 'Prefer to add it manually?',
                                    style: TextStyle(
                                      color: PKBAppState().secondaryColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    loc.getText('manual_cta_body').isNotEmpty
                                        ? loc.getText('manual_cta_body')
                                        : 'Pick a medicine and set times without scanning.',
                                    style: TextStyle(
                                      color: PKBAppState().secondaryColor.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 14.0),
                              decoration: BoxDecoration(
                                color: PKBAppState().primaryColor,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: PKBAppState().primaryColor,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                loc.getText('manual_cta_button').isNotEmpty
                                    ? loc.getText('manual_cta_button')
                                    : 'Add manually',
                                style: TextStyle(
                                  color: PKBAppState().tertiaryColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: appBarHeight,
                  color: PKBAppState().tertiaryColor,
                  child: Semantics(
                    container: true,
                    label: _instPlaceCameraPack,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                            child: ExcludeSemantics(
                              excluding: true,
                              child: Text(
                                loc.getText('header_prescription_scan').isNotEmpty
                                    ? loc.getText('header_prescription_scan')
                                    : 'Prescription Scan',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: appBarFontSize,
                                  color: PKBAppState().secondaryColor,
                                  fontWeight: headerWeight,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const widgets.HomeButtonWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}
