import 'package:flutter/material.dart';

class TvProvider with ChangeNotifier {
  Color connectColor = Colors.white;
  String deviceName;
  void setConnectedColor({Color color}) {
    this.connectColor = color;
    notifyListeners();
  }

  void setDeviceName(name) {
    this.deviceName = name;
  }

  Color get colorStatus => connectColor;
}
