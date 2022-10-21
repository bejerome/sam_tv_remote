import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samsung_remote/app_colors.dart';
import 'package:flutter_samsung_remote/home_page.dart';
import 'package:flutter_samsung_remote/key_codes.dart';
import 'package:flutter_samsung_remote/main.dart';

class UniversalControllerApp extends StatelessWidget {
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

  void toggleFab() {
    if (fabKey.currentState.isOpen) {
      fabKey.currentState.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: MyHomePage(),
          floatingActionButton: FabCircularMenu(
              key: fabKey,
              fabElevation: 20,
              fabSize: 40,
              fabColor: Colors.cyan[300],
              fabOpenIcon: Icon(Icons.play_arrow),
              alignment: Alignment.centerRight,
              ringColor: AppColors.darkButtonBackground,
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.stop,
                      size: 48,
                      color: Colors.yellow,
                    ),
                    onPressed: () async {
                      // await tv.sendKey(KEY_CODES.KEY_STOP);
                      toggleFab();
                    }),
                IconButton(
                    icon: Icon(
                      Icons.fast_rewind_sharp,
                      size: 28,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      // await tv.sendKey(KEY_CODES.KEY_REWIND);
                      toggleFab();
                    }),
                IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                      size: 48,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      // await tv.sendKey(KEY_CODES.KEY_PLAY);
                      toggleFab();
                    }),
                IconButton(
                    icon: Icon(
                      Icons.fast_forward,
                      size: 28,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      // await tv.sendKey(KEY_CODES.KEY_FF);
                      toggleFab();
                    }),
                IconButton(
                    icon: Icon(
                      Icons.pause,
                      size: 48,
                      color: Colors.cyanAccent,
                    ),
                    onPressed: () async {
                      // await tv.sendKey(KEY_CODES.KEY_PAUSE);
                      toggleFab();
                    })
              ]),
        ));
  }
}
