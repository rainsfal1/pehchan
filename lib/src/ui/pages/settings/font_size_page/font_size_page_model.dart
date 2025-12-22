import 'package:flutter/material.dart';

class FontSizePageModel {
  final unfocusNode = FocusNode();

  void dispose() {
    unfocusNode.dispose();
  }
}
