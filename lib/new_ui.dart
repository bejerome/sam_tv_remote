import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibration/vibration.dart';
import 'app_colors.dart';
import 'device.dart';
import 'key_codes.dart';
import 'package:hardware_buttons/hardware_buttons.dart' as HardwareButtons;
import 'package:hive/hive.dart';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setEnabledSystemUIOverlays([]);
  return runApp(UniversalControllerApp());
}

class UniversalControllerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Universal Controller',
      home: Scaffold(
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BehaviorSubject<int> willAcceptStream;
  Color backgroundColor = AppColors.darkBackground;
  Color textColor = AppColors.darkText;
  Color selectColor = AppColors.darkSelect;
  Color iconColor = AppColors.darkIcon;
  Color buttonBackgroundColor = AppColors.darkButtonBackground;
  Color iconButtonColor = AppColors.darkIconButton;
  Color sliderBackground = AppColors.darkButtonBackground;
  Future canVibrate;
  SamsungSmartTV tv;
  String _latestHardwareButtonEvent;
  StreamSubscription<HardwareButtons.VolumeButtonEvent>
      _volumeButtonSubscription;
  String token;

  @override
  void initState() {
    willAcceptStream = new BehaviorSubject<int>();
    willAcceptStream.add(0);
    _volumeButtonSubscription =
        HardwareButtons.volumeButtonEvents.listen((event) {
      setState(() {
        _latestHardwareButtonEvent = event.toString();
        volumeButtonActions(_latestHardwareButtonEvent);
      });
    });
    connectTV();
    super.initState();
  }

  Future<void> storeToken() async {
    await Hive.initFlutter();
    var keyBox = await Hive.openBox('encryptionKeyBox');
    if (!keyBox.containsKey('key')) {
      var key = Hive.generateSecureKey();
      keyBox.put('key', key);
    }
    var key = keyBox.get('key') as Uint8List;
    var encryptedBox = await Hive.openBox('vaultBox', encryptionKey: key);
    if (encryptedBox.get('secret') == null) {
      token = await getTvToken();
      encryptedBox.put('secret', token);
      print(encryptedBox.get('secret'));
    } else {
      token = encryptedBox.get('secret');
      await getTvToken();
    }
  }

  void connectTV() async {
    try {
      await storeToken();
      // await tv.connect(tokenValue: token);
    } catch (e) {
      print(e);
    }
  }

  Future<String> getTvToken() async {
    try {
      tv = await SamsungSmartTV.discover();
      await tv.connect(tokenValue: token);
    } catch (e) {
      print(e);
    }
    return tv.token;
  }

  void volumeButtonActions(String status) async {
    switch (status) {
      case 'VolumeButtonEvent.VOLUME_DOWN':
        {
          await tv.sendKey(KEY_CODES.KEY_VOLDOWN);
        }
        break;

      case 'VolumeButtonEvent.VOLUME_UP':
        {
          await tv.sendKey(KEY_CODES.KEY_VOLUP);
        }
        break;

      default:
        {
          //statements;

        }
        break;
    }
  }

  void toggleTheme() {
    setState(
      () {
        backgroundColor = backgroundColor == AppColors.darkBackground
            ? AppColors.lightBackground
            : AppColors.darkBackground;
        textColor = textColor == AppColors.darkText
            ? AppColors.lightText
            : AppColors.darkText;
        selectColor = selectColor == AppColors.darkSelect
            ? AppColors.lightSelect
            : AppColors.darkSelect;
        iconColor = iconColor == AppColors.darkIcon
            ? AppColors.lightIcon
            : AppColors.darkIcon;
        iconButtonColor = iconButtonColor == AppColors.darkIconButton
            ? AppColors.lightIconButton
            : AppColors.darkIconButton;
        buttonBackgroundColor =
            buttonBackgroundColor == AppColors.darkButtonBackground
                ? AppColors.lightButtonBackground
                : AppColors.darkButtonBackground;
      },
    );
  }

  Color colorSelect(data) {
    Color color;
    if (data == 0) {
      color = buttonBackgroundColor;
    } else {
      color = Colors.blue;
    }
    return color;
  }

  void vibrate() {
    Vibration.vibrate(duration: 5);
  }

  @override
  void dispose() {
    super.dispose();
    _volumeButtonSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        width: size.width,
        height: size.height,
        color: backgroundColor,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  width: size.width,
                  height: size.height * 0.1,
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            text: 'Samsung',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: 20,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Remote',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: textColor,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.personal_video,
                          color: selectColor,
                          size: 28,
                        ),
                        GestureDetector(
                          onTap: connectTV,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: selectColor,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.11,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          vibrate();
                          print("Mute");
                          await tv.sendKey(KEY_CODES.KEY_MUTE);
                        },
                        child: Container(
                          width: size.height * 0.11,
                          height: size.height * 0.08,
                          child: Icon(
                            Icons.volume_down,
                            color: iconColor,
                            size: 28,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          print("Power Pressed");
                          vibrate();
                          await tv.sendKey(KEY_CODES.KEY_POWER);
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          width: size.height * 0.11,
                          height: size.height * 0.11,
                          decoration: new BoxDecoration(
                            color: buttonBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.power_settings_new,
                            color: Color(0xFFEF5252),
                            size: 38,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          toggleTheme();
                          vibrate();
                        },
                        child: Container(
                          width: size.height * 0.11,
                          height: size.height * 0.08,
                          child: Icon(
                            Icons.filter_list,
                            color: iconColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CustomButton(
                        size: size,
                        buttonBackground: buttonBackgroundColor,
                        buttonLabel: "Vol",
                        iconColor: iconButtonColor,
                        textColor: textColor,
                        upIcon: Icons.add,
                        upIconCallBack: () async {
                          print("Vol up");
                          vibrate();
                          await tv.sendKey(KEY_CODES.KEY_VOLUP);
                        },
                        downIcon: Icons.remove,
                        downIconCallBack: () async {
                          print("Vol down");
                          vibrate();
                          await tv.sendKey(KEY_CODES.KEY_VOLDOWN);
                        },
                      ),
                      GestureDetector(
                        onTap: () async {
                          await tv.sendKey(KEY_CODES.KEY_ENTER);
                        },
                        child: CustomCircle(
                          size: size,
                          background: backgroundColor,
                        ),
                      ),
                      Container(
                        width: size.width * 0.20,
                        height: size.height * 0.25,
                        decoration: new BoxDecoration(
                          color: buttonBackgroundColor,
                          borderRadius: new BorderRadius.all(
                            Radius.circular(40.0),
                          ),
                        ),
                        child: CustomButton(
                          size: size,
                          buttonBackground: buttonBackgroundColor,
                          buttonLabel: "CH",
                          iconColor: iconButtonColor,
                          textColor: textColor,
                          upIcon: Icons.keyboard_arrow_up,
                          downIcon: Icons.keyboard_arrow_down,
                          upIconCallBack: () {
                            print("Channel Up");
                            vibrate();
                          },
                          downIconCallBack: () {
                            print("Channel Down");
                            vibrate();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  // color: Colors.blue,
                  width: size.width,
                  height: size.height * 0.10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          await tv.sendKey(KEY_CODES.KEY_BACK_MHP);
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 20,
                            left: 50,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: iconColor,
                            size: 38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  // alignment: Alignment.topCenter,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2.5,
                        height: 20.0,
                        child: DragTarget(
                          builder: (context, list, list2) {
                            return Container(
                              padding: EdgeInsets.only(bottom: 8),
                              width: size.width * 0.2,
                              height: size.width * 0.5,
                              child: Icon(
                                Icons.lens,
                                color: Colors.purple,
                                size: 18,
                              ),
                            );
                          },
                          onWillAccept: (item) {
                            vibrate();
                            this.willAcceptStream.add(-50);
                            debugPrint('<================');
                            setState(() {
                              sliderBackground = Colors.purple;
                            });
                            tv.sendKey(KEY_CODES.KEY_UP);

                            return false;
                          },
                          onLeave: (item) {
                            vibrate();
                            debugPrint('RESET Purple');
                            sliderBackground = AppColors.darkButtonBackground;
                            this.willAcceptStream.add(0);
                          },
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: 10,
                        child: DragTarget(
                          builder: (context, list, list2) {
                            return Nub(size: size);
                          },
                          onWillAccept: (item) {
                            vibrate();
                            this.willAcceptStream.add(-50);
                            debugPrint('<================');
                            sliderBackground = Colors.red;
                            tv.sendKey(KEY_CODES.KEY_LEFT);
                            return false;
                          },
                          onLeave: (item) {
                            vibrate();
                            setState(() {
                              sliderBackground = AppColors.darkButtonBackground;
                            });
                            this.willAcceptStream.add(0);
                          },
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: MediaQuery.of(context).size.width / 4,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          width: size.width * 0.5,
                          height: size.width * 0.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.pinkAccent,
                                Colors.blue,
                                Color(0xFF584BD2)
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(18),
                            width: size.width * 0.4,
                            height: size.width * 0.4,
                            decoration: new BoxDecoration(
                              color: backgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Draggable(
                              axis: null,
                              feedback: StreamBuilder(
                                initialData: 0,
                                stream: willAcceptStream,
                                builder: (context, snapshot) {
                                  return Container(
                                    width: size.width * 0.4,
                                    height: size.width * 0.4,
                                    decoration: new BoxDecoration(
                                      color: sliderBackground,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              ),
                              childWhenDragging: Container(),
                              child: Container(
                                width: size.width * 0.5,
                                height: size.width * 0.5,
                                decoration: new BoxDecoration(
                                  color: buttonBackgroundColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              onDraggableCanceled: (v, f) => setState(
                                () {
                                  this.willAcceptStream.add(0);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 30,
                        right: 0.0,
                        child: DragTarget(
                          builder: (context, list, list2) {
                            return Container(
                              padding: EdgeInsets.all(3),
                              width: size.width * 0.2,
                              height: size.width * 0.5,
                              child: Icon(
                                Icons.lens,
                                color: Color(0xFF59C533),
                                size: 18,
                              ),
                            );
                          },
                          onWillAccept: (item) {
                            vibrate();
                            debugPrint('================>');
                            this.willAcceptStream.add(50);
                            setState(() {
                              sliderBackground = Color(0xFF59C533);
                            });
                            tv.sendKey(KEY_CODES.KEY_RIGHT);
                            return false;
                          },
                          onLeave: (item) {
                            debugPrint('RESET');
                            this.willAcceptStream.add(0);
                            sliderBackground = buttonBackgroundColor;
                          },
                        ),
                      ),
                      Positioned(
                        bottom: -95.0,
                        left: size.width / 2.5,
                        child: DragTarget(
                          builder: (context, list, list2) {
                            return Container(
                              width: size.width * 0.2,
                              height: size.width * 0.5,
                              child: Icon(
                                Icons.lens,
                                color: Colors.yellow,
                                size: 18,
                              ),
                            );
                          },
                          onWillAccept: (item) {
                            vibrate();
                            debugPrint('================>');
                            this.willAcceptStream.add(50);
                            setState(() {
                              sliderBackground = Colors.yellow;
                            });
                            tv.sendKey(KEY_CODES.KEY_DOWN);
                            return false;
                          },
                          onLeave: (item) {
                            debugPrint('RESET');
                            this.willAcceptStream.add(0);
                            sliderBackground = buttonBackgroundColor;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Icon(
                        Icons.adjust,
                        color: Color(0xFF584BD2),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              print("Start Pressed");
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Icon(
                              Icons.rss_feed,
                              color: Color(0xFF584BD2),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              print("Settings Pressed");
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Icon(
                              Icons.settings,
                              color: iconColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Nub extends StatelessWidget {
  const Nub({
    Key key,
    @required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      width: size.width * 0.2,
      height: size.width * 0.5,
      child: Icon(
        Icons.lens,
        color: Color(0xFFFF4B4D),
        size: 18,
      ),
    );
  }
}

class CustomCircle extends StatelessWidget {
  const CustomCircle({
    Key key,
    @required this.size,
    @required this.background,
  }) : super(key: key);

  final Size size;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      width: size.width * 0.1,
      height: size.width * 0.1,
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.blue,
            Colors.pink,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: EdgeInsets.all(18),
        width: size.width * 0.4,
        height: size.width * 0.4,
        decoration: new BoxDecoration(
          color: background,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton(
      {Key key,
      @required this.size,
      @required this.buttonBackground,
      @required this.iconColor,
      @required this.buttonLabel,
      @required this.textColor,
      @required this.upIcon,
      @required this.downIcon,
      @required this.upIconCallBack,
      @required this.downIconCallBack})
      : super(key: key);

  final Size size;
  final Color buttonBackground;
  final Color iconColor;
  final Color textColor;
  final IconData upIcon;
  final IconData downIcon;
  final Function upIconCallBack;
  final Function downIconCallBack;
  final String buttonLabel;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.20,
      height: size.height * 0.25,
      decoration: new BoxDecoration(
        color: buttonBackground,
        borderRadius: new BorderRadius.all(
          Radius.circular(40.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            onTap: upIconCallBack,
            child: Icon(
              upIcon,
              color: iconColor,
              size: 38,
            ),
          ),
          Text(
            buttonLabel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 24,
            ),
          ),
          GestureDetector(
            onTap: downIconCallBack,
            child: Icon(
              downIcon,
              color: iconColor,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }
}
