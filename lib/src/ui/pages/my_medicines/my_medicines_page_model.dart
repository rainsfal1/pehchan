import 'package:flutter/material.dart';
import 'package:pehchan/src/core/pehchan_util.dart';

class MyMedicinesPageModel extends PehchanModel {
  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
