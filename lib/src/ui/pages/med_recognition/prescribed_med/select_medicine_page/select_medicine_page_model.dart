import 'package:flutter/material.dart';
import '../../../../../core/pillkaboo_util.dart';

class SelectMedicinePageModel extends PillKaBooModel {
  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
