import 'dart:async';

import '../../../../../app/tts/tts_service.dart';
import '../../../../../core/pillkaboo_util.dart';
import '../../../../widgets/index.dart' as widgets;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'med_recognition_page_model.dart';
export 'med_recognition_page_model.dart';


class MedRecognitionPageWidget extends StatefulWidget {
  const MedRecognitionPageWidget({super.key});

  @override
  State<MedRecognitionPageWidget> createState() => _MedRecognitionPageWidgetState();
}

class _MedRecognitionPageWidgetState extends State<MedRecognitionPageWidget> {
  late MedRecognitionPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final StreamController<bool> _controller = StreamController();
  String _instPlaceCamera =
      'Hold the camera about 30 cm away and slowly rotate the medicine package.';


  @override
  void initState() {
    super.initState();
    _controller.stream.listen((success) {
      if (success) {
        if (mounted) {
          context.pushReplacement('/medInfoPage');
        }
      }
    });
    _model = createModel(context, () => MedRecognitionPageModel());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = PKBLocalizations.of(context);
    final val = loc.getText('scan_instruction_med');
    _instPlaceCamera = val.isNotEmpty
        ? val
        : 'Hold the camera about 30 cm away and slowly rotate the medicine package.';
    if (!PKBAppState().useScreenReader) {
      TtsService().stop();
      TtsService().speak(_instPlaceCamera);
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

    double appBarFontSize = 32.0/892.0 * MediaQuery.of(context).size.height;
    double appBarHeight = 60.0/892.0 * MediaQuery.of(context).size.height;

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
                          child: widgets.MedRecognizerWidget(
                            width: MediaQuery.of(context).size.width * 1.0,
                            height: MediaQuery.of(context).size.height * 0.85,
                            controller: _controller,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                  width: MediaQuery.of(context).size.width,
                  height: appBarHeight,
                  color: PKBAppState().tertiaryColor,
                  child: Semantics(
                    container: true,
                    label: _instPlaceCamera,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ExcludeSemantics(
                            excluding: true,
                            child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: ExcludeSemantics(
                              excluding: true,
                              child: Text(
                              loc.getText('header_med_scan').isNotEmpty ? loc.getText('header_med_scan') : 'Medicine Scan',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: appBarFontSize,
                                color: PKBAppState().secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),),
                          ),),
                          const Spacer(),
                          Semantics(
                            container: true,
                            label: 'Go to home. Double tap to activate.',
                            child: const widgets.HomeButtonWidget(),
                          )
                        ],
                      ),),
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }
}
