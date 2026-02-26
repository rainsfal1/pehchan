import '../../../../../core/pehchan_model.dart';
import 'allergy_add_page_widget.dart' show AllergyAddPageWidget;
import 'package:flutter/material.dart';

class AllergyAddPageModel extends PehchanModel<AllergyAddPageWidget> {

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}