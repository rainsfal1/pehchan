import '../../../../core/pehchan_util.dart';
import 'main_menu_page_widget.dart' show MainMenuPageWidget;
import 'package:flutter/material.dart';

class MainMenuPageModel extends PehchanModel<MainMenuPageWidget> {

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}