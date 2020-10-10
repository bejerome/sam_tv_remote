// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/material.dart';

class RawKeyboardEvent extends StatefulWidget {
  @override
  _RawKeyboardEventState createState() => _RawKeyboardEventState();
}

class _RawKeyboardEventState extends State<RawKeyboardEvent> {
  FocusNode node;
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
        autofocus: false,
        focusNode: FocusNode(),
        onKey: (RawKeyEvent key) {
          print(key.data);
        },
        child: GestureDetector(
          onTap: () => {},
          child: Text("Hello"),
        ));
  }
}