import 'package:flutter/material.dart';

class DoseConfirmationPageModel {
  final unfocusNode = FocusNode();

  void dispose() {
    unfocusNode.dispose();
  }
}
