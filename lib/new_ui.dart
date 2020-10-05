import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_samsung_remote/tv_provider.dart';
import 'package:provider/provider.dart';
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
  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TvProvider(),
        )
      ],
      child: UniversalControllerApp(),
    ),
  );
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
  bool status = false;

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
      status = tv.isConnected;
      setColor(status);
      // await tv.connect(tokenValue: token);
    } catch (e) {
      print(e);
    }
  }

  setColor(status) {
    Color result;
    if (status) {
      result = Colors.green;
    } else {
      result = Colors.white;
    }
    setState(() {
      selectColor = result;
    });
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
    Color color = context.watch<TvProvider>().colorStatus;
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
                  margin: EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.5,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: size.width / 2.6,
                        top: -20,
                        child: GestureDetector(
                          onTap: () async {
                            vibrate();
                            await tv.sendKey(KEY_CODES.KEY_UP);
                          },
                          child: Icon(
                            Icons.arrow_drop_up,
                            color: Colors.purple,
                            size: 100,
                          ),
                        ),
                      ),
                      Positioned(
                        top: size.height / 8,
                        left: 20,
                        child: GestureDetector(
                          onTap: () async {
                            vibrate();
                            await tv.sendKey(KEY_CODES.KEY_LEFT);
                            ;
                          },
                          child: Icon(
                            Icons.arrow_left,
                            color: Colors.red,
                            size: 100,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 80,
                        left: MediaQuery.of(context).size.width / 3.3,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          width: size.width * 0.4,
                          height: size.width * 0.4,
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
                            decoration: new BoxDecoration(
                              color: backgroundColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: size.height / 8,
                        right: 20.0,
                        child: GestureDetector(
                          onTap: () async {
                            vibrate();
                            await tv.sendKey(KEY_CODES.KEY_RIGHT);
                          },
                          child: Icon(
                            Icons.arrow_right,
                            color: Color(0xFF59C533),
                            size: 100,
                          ),
                        ),
                      ),
                      Positioned(
                        top: size.height / 7.5,
                        left: size.width / 2.6,
                        child: GestureDetector(
                          onTap: () async {
                            vibrate();
                            await tv.sendKey(KEY_CODES.KEY_ENTER);
                          },
                          child: Icon(
                            Icons.adjust,
                            color: Color(0xFF584BD2),
                            size: 100,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: (size.height / 10) - 95,
                        left: size.width / 2.6,
                        child: GestureDetector(
                          onTap: () async {
                            vibrate();
                            await tv.sendKey(KEY_CODES.KEY_DOWN);
                          },
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.yellow,
                            size: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.10,
                  margin: EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              vibrate();
                              await tv.sendKey(KEY_CODES.KEY_RETURN);
                            },
                            child: Container(
                              child: Icon(
                                Icons.arrow_back,
                                color: iconColor,
                                size: 38,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              vibrate();
                              await tv.sendKey(KEY_CODES.KEY_HOME);
                            },
                            child: Container(
                              child: Icon(
                                Icons.home,
                                color: iconColor,
                                size: 38,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await tv.sendKey(KEY_CODES.KEY_MENU);
                            },
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
