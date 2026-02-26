import '../../../../../core/pehchan_util.dart';
import 'med_info_page_widget.dart' show MedInfoPageWidget;
import 'package:flutter/material.dart';

class MedInfoPageModel extends PehchanModel<MedInfoPageWidget> {

  final unfocusNode = FocusNode();


  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}