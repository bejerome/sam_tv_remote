import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_samsung_remote/remote.dart';
import 'device.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_samsung_remote/lock_screen.dart';

import 'http_override.dart';

/// Virtual keyboard actions.
enum VirtualKeyboardKeyAction { Backspace, Return, Shift, Space }
SamsungSmartTV tv;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
   HttpOverrides.global = MyHttpOverrides();
  return runApp(AppLock(
    builder: (args) => UniversalControllerApp(),
    lockScreen: LockScreen(),
    enabled: false,
    backgroundLockLatency: const Duration(seconds: 15),
  ));
}
