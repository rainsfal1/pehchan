import '../../../../../core/pehchan_util.dart';
import 'prescribed_med_result_page_widget.dart' show PrescribedMedResultPageWidget;
import 'package:flutter/material.dart';

class PrescribedMedResultPageModel extends PehchanModel<PrescribedMedResultPageWidget> {

  final unfocusNode = FocusNode();


  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}