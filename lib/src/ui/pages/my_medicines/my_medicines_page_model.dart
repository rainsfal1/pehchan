import 'package:flutter/material.dart';
import 'package:pillkaboo/src/core/pillkaboo_util.dart';

class MyMedicinesPageModel extends PillKaBooModel {
  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
