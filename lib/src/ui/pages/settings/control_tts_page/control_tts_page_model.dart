import '../../../../core/pehchan_model.dart';
import 'control_tts_page_widget.dart' show ControlTTSPageWidget;
import 'package:flutter/material.dart';

class ControlTTSPageModel extends PehchanModel<ControlTTSPageWidget> {

  final unfocusNode = FocusNode();


  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}