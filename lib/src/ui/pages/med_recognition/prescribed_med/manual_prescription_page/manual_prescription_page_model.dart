import 'package:flutter/material.dart';
import '../../../../../core/pillkaboo_util.dart';

class ManualPrescriptionPageModel extends PillKaBooModel {
  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
