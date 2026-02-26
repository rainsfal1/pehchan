import 'package:flutter/material.dart';
import '../../../../../core/pehchan_util.dart';

class SelectMedicinePageModel extends PehchanModel {
  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
