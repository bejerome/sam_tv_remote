import 'package:flutter/material.dart';

class TvProvider with ChangeNotifier {
  Color connectColor = Colors.white;

  void setConnectedColor({Color color}) {
    this.connectColor = color;
    notifyListeners();
  }

  Color get colorStatus => connectColor;
}
