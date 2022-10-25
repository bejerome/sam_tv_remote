import 'dart:async';
import 'dart:convert';

import 'package:adv_fab/adv_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samsung_remote/app_colors.dart';
import 'package:flutter_samsung_remote/device.dart';
import 'package:flutter_samsung_remote/key_codes.dart';
import 'package:flutter_samsung_remote/main.dart';
import 'package:flutter_samsung_remote/widgets/custom_widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:hardware_buttons/hardware_buttons.dart' as HardwareButtons;
import 'package:virtual_keyboard/virtual_keyboard.dart';
import 'package:sensors/sensors.dart';
import 'package:flare_flutter/flare_actor.dart';
// import 'package:upnp2/upnp.dart';
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  BehaviorSubject<int> willAcceptStream;
  Color backgroundColor = AppColors.darkBackground;
  Color textColor = AppColors.darkText;
  Color selectColor = Color(0xFFEF5252);
  Color iconColor = AppColors.darkIcon;
  Color buttonBackgroundColor = AppColors.darkButtonBackground;
  Color iconButtonColor = AppColors.darkIconButton;
  Color sliderBackground = AppColors.darkButtonBackground;
  String inputValue = "";
  String _latestHardwareButtonEvent;
  // StreamSubscription<HardwareButtons.VolumeButtonEvent>
  //     _volumeButtonSubscription;
  String token;
  bool status = false;
  SharedPreferences _pref;
  bool _canVibrate;
  AdvFabController mabialaFABController;
  bool useFloatingSpaceBar = true;
  bool useAsFloatingActionButton = false;
  bool useNavigationBar = false;
  Map<String, List<String>> myMapList = Map();
  bool isAlwaysCaps = false;
  bool _isInForeground = true;
  bool _isPaused = false;
  bool _isInInactive = false;
  List<double> _accelerometerValues;

  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  List<double> _history = [0.1, 0.1, 0.1];
  double xChange;
  double yChange;
  double zChange;
  bool isGestureActive = false;
  Color mouseColor = AppColors.darkIcon;
  @override
  void initState() {
    mabialaFABController = AdvFabController();
    willAcceptStream = new BehaviorSubject<int>();
    willAcceptStream.add(0);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
    gyroSetup();
  }

  void init() async {
    bool canVibrate = await Vibrate.canVibrate;
    _pref = await SharedPreferences.getInstance();
    setState(() {
      _canVibrate = canVibrate;
      _canVibrate
          ? print("This device can vibrate")
          : print("This device cannot vibrate");
    });
    // _volumeButtonSubscription =
    //     HardwareButtons.volumeButtonEvents.listen((event) {
    //   setState(() {
    //     _latestHardwareButtonEvent = event.toString();
    //     volumeButtonActions(_latestHardwareButtonEvent);
    //   });
    // });
    await setUp();
  }

  void toggleGesture() {
    var state = isGestureActive == true ? false : true;

    setState(() {
      isGestureActive = state;
      mouseColor = state == true ? Colors.green : iconColor;
    });
  }

  void controlDirection(direction) async {
    if (isGestureActive) {
      switch (direction) {
        case 'left':
          await tv.sendKey(KEY_CODES.KEY_LEFT);
          break;
        case 'right':
          await tv.sendKey(KEY_CODES.KEY_RIGHT);
          break;
        case 'up':
          await tv.sendKey(KEY_CODES.KEY_UP);
          break;
        case 'down':
          await tv.sendKey(KEY_CODES.KEY_DOWN);
          break;
        default:
          print("Warning Direction");
          break;
      }
    }
  }

  void gyroSetup() async {
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _accelerometerValues = <double>[event.x, event.y, event.z];
          setState(
            () {
              xChange = _accelerometerValues[0].toDouble();
              yChange = _accelerometerValues[1].toDouble();
              zChange = _accelerometerValues[2].toDouble();
              if ((xChange) > 5) {
                print("Swing left");
                controlDirection('left');
              } else if (xChange < -7) {
                controlDirection('right');
                print("Swing Right");
              } else if (yChange > 5) {
                controlDirection('up');
                print("Swing UP");
                print("Z: $zChange");
              } else if (yChange < -5) {
                controlDirection('down');
                print("Swing DOWN");
                print("Z: $zChange");
              } else {
                _history[0] = _accelerometerValues[0].toDouble();
                _history[1] = _accelerometerValues[1].toDouble();
              }
            },
          );
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && !_isPaused) {
      _isPaused = true;
      showDisconnectState();
    } else if (state == AppLifecycleState.resumed) {
      _isInForeground = true;
      connectTV();
    }

    // _isInForeground ? connectTV() : showDisconnectState();
  }

  void showDisconnectState() async {
    // tv.disconnect();
    setColor(false);
  }

  Future<void> setUp() async {
    await wakeTV();
    await connectTV();
    if (_pref.getString('token') == null) {
      await discoverTV();
      token = await getTvToken();
      if (token != null) {
        _pref.setString('token', token);
        print("Set Token: $token");
      }
      var info = await tv.getDeviceInfo();
      var details = jsonDecode(info.body);
      _pref.setString('host', tv.host);
      _pref.setString('mac', details['device']['wifiMac']);
      print("Set Mac ${details['device']['wifiMac']}");
    }
    status = tv.isConnected;
    setColor(status);
  }

  Future<void> viewToken() async {
    print(tv.token);
  }

  Future<void> wakeTV() async {
    if (_pref.containsKey('token')) {
      try {
        await SamsungSmartTV.wakeOnLan(
            _pref.getString('host'), _pref.getString('mac'));
      } catch (e) {
        print("Failed to Wake on lan");
      }
    }
  }

  Future<void> discoverTV() async {
    try {
      tv = await SamsungSmartTV.discover();
    } catch (e) {
      print("Failed to discover tv");
    }
  }

  Future<void> connectTV() async {
    token = _pref.getString('token');

    try {
      if (token != null) {
        tv = new SamsungSmartTV(
            deviceName: "Samsung TV",
            host: _pref.getString('host'),
            mac: _pref.getString('mac'));
        await tv.connect(tokenValue: token);
        setColor(true);
        print("Token: $token");
      }
    } catch (e) {
      print("failed to connect");
      setColor(false);
    }
  }

  setColor(status) {
    Color result;
    if (status) {
      result = Colors.green;
    } else {
      result = Color(0xFFEF5252);
    }
    setState(() {
      selectColor = result;
    });
  }

  Future<String> getTvToken() async {
    if (_pref.containsKey('token') != true) {
       await tv.connect(tokenValue: token);

      token = tv.token;

      status = tv.isConnected;
      setColor(status);
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
    var _type = FeedbackType.selection;
    Vibrate.feedback(_type);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    // _volumeButtonSubscription?.cancel();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  void setBar() {
    //3201601007230 HBO
    //org.tizen.browser internet
    myMapList['app'] = ["Netflix", "HBO", "Prime", "YouTube"];
    myMapList['logo'] = [
      "assets/netflix_logo.jpeg",
      "assets/hbo_logo.jpeg",
      "assets/amazon_logo.jpg",
      "assets/youtube_logo.png"
    ];
    mabialaFABController.setExpandedWidgetConfiguration(
      showLogs: true,
      heightToExpandTo: 30,
      expendedBackgroundColor: backgroundColor,
      withChild: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: Container(
          width: (MediaQuery.of(context).size.width),

          ///[IMPORTANT]: the height percentage shall be less than [heightToExpandTo]
          ///in the next line we use 20%
          height: (MediaQuery.of(context).size.height / 100) * 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8),
                    child: Center(
                        child: GestureDetector(
                            onTap: () {
                              mabialaFABController.collapseFAB();
                            },
                            child: Icon(
                              Icons.close,
                              size: 25,
                              color: Colors.white,
                            ))),
                  ),
                ]),
              ),
              Expanded(
                  flex: 5,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: 4,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              vibrate();
                              mabialaFABController.collapseFAB();
                              tv.openTVApp(myMapList['app'][index]);
                            },
                            child: Container(
                              width: (MediaQuery.of(context).size.width / 100) *
                                  25,
                              color: backgroundColor,
                              child: Image.asset(myMapList['logo'][index]),
                            ),
                          ),
                        );
                      }))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    setBar();
    return SafeArea(
        child: Scaffold(
      floatingActionButton: AdvFab(
        floatingActionButtonIcon: Icons.apps_outlined,
        floatingActionButtonIconColor: Colors.red,
        floatingSpaceBarContainerWidth: 100,
        useAsFloatingActionButton: true,
        floatingActionButtonExpendedWidth: 90,
        useAsNavigationBar: false,
        controller: mabialaFABController,
        animationDuration: Duration(milliseconds: 350),
        useElevation: true,
        showLogs: false,
        onFloatingActionButtonTapped: () {
          vibrate();
          mabialaFABController.isCollapsed
              ? mabialaFABController.expandFAB()
              : mabialaFABController.collapseFAB();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: true,
      body: Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          padding: EdgeInsets.all(40.0),
          width: size.width,
          height: size.height,
          color: backgroundColor,
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: size.width,
                      height: size.height * 0.11,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              print("Power Pressed");
                              vibrate();
                              await SamsungSmartTV.wakeOnLan(tv.host, tv.mac);
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
                                color: selectColor,
                                size: 38,
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
                          CustomVolButton(
                            size: size,
                            buttonBackground: buttonBackgroundColor,
                            buttonLabel: "Vol",
                            iconColor: iconButtonColor,
                            textColor: textColor,
                            upIcon: Icons.add,
                            upIconCallBack: () async {
                              print("Vol up");
                              // vibrate();
                              await tv.sendKey(KEY_CODES.KEY_VOLUP);
                            },
                            downIcon: Icons.remove,
                            downIconCallBack: () async {
                              print("Vol down");
                              // vibrate();
                              await tv.sendKey(KEY_CODES.KEY_VOLDOWN);
                            },
                            muteIconCallBack: () async {
                              vibrate();
                              await tv.sendKey(KEY_CODES.KEY_MUTE);
                            },
                          ),
                          GestureDetector(
                            onTap: () async {
                             await tv.sendKey(KEY_CODES.KEY_HOME);
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
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2,
                      child: Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () async {
                                      vibrate();
                                      await tv.sendKey(KEY_CODES.KEY_UP);
                                    },
                                    child: Icon(
                                      Icons.arrow_drop_up,
                                      color: Color(0xFF584BD2),
                                      size: 100,
                                    ),
                                  ),
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () async {
                                      vibrate();
                                      await tv.sendKey(KEY_CODES.KEY_LEFT);
                                    },
                                    child: Icon(
                                      Icons.arrow_left,
                                      color: Color(0xFF584BD2),
                                      size: 100,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      vibrate();
                                      await tv.sendKey(KEY_CODES.KEY_ENTER);
                                    },
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      child: FlareActor(
                                        'assets/the_orb.flr',
                                        alignment: Alignment.center,
                                        fit: BoxFit.contain,
                                        animation: 'Aura',
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      vibrate();
                                      await tv.sendKey(KEY_CODES.KEY_RIGHT);
                                    },
                                    child: Icon(
                                      Icons.arrow_right,
                                      color: Color(0xFF584BD2),
                                      size: 100,
                                    ),
                                  ),
                                ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    vibrate();
                                    await tv.sendKey(KEY_CODES.KEY_DOWN);
                                  },
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xFF584BD2),
                                    size: 100,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: size.width,
                      height: size.height / 18,
                      margin: EdgeInsets.only(top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    print("mouse");
                                    toggleGesture();
                                  },
                                  child: Icon(
                                    Icons.mouse,
                                    color: mouseColor,
                                    size: 28,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    print("home");
                                    await tv.sendKey(KEY_CODES.KEY_MENU);
                                  },
                                  child: Icon(
                                    Icons.settings,
                                    color: iconColor,
                                    size: 28,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    inputValue = "";
                                   await tv.sendKey(KEY_CODES.KEY_DTV_SIGNAL);
                                    showModalBottomSheet<void>(
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                              margin: EdgeInsets.only(
                                                  top: 0, bottom: 30),
                                              height: 400,
                                              color: Colors.transparent,
                                              child: Center(
                                                  child: Container(
                                                // Keyboard is transparent
                                                color: Colors.teal,
                                                child: VirtualKeyboard(
                                                    alwaysCaps: isAlwaysCaps,
                                                    // Default height is 300
                                                    height: 300,
                                                    // Default is black
                                                    textColor: Colors.white,
                                                    // Default 14
                                                    fontSize: 20,
                                                    // [A-Z, 0-9]
                                                    type: VirtualKeyboardType
                                                        .Alphanumeric,
                                                    // Callback for key press event
                                                    onKeyPress: (key) async {
                                                      if (key.keyType ==
                                                          VirtualKeyboardKeyType
                                                              .String) {
                                                        var txt =
                                                            (isAlwaysCaps ==
                                                                    true)
                                                                ? key.capsText
                                                                : key.text
                                                                    .toString();
                                                        inputValue += txt;
                                                      } else if (key.keyType ==
                                                          VirtualKeyboardKeyType
                                                              .Action) {
                                                        switch (key.action
                                                            .toString()) {
                                                          case "VirtualKeyboardKeyAction.Backspace":
                                                            print("backspace");
                                                            if (inputValue
                                                                    .length ==
                                                                0) {
                                                              return;
                                                            } else {
                                                              print(
                                                                  "backspace");
                                                              inputValue = inputValue
                                                                  .substring(
                                                                      0,
                                                                      inputValue
                                                                              .length -
                                                                          1);
                                                            }
                                                            break;
                                                          case "VirtualKeyboardKeyAction.Return":
                                                            await tv.sendKey(
                                                                KEY_CODES
                                                                    .KEY_ENTER);
                                                            break;
                                                          case "VirtualKeyboardKeyAction.Space":
                                                            inputValue += " ";
                                                            break;
                                                          case "VirtualKeyboardKeyAction.Shift":
                                                            setState(() {
                                                              if (isAlwaysCaps ==
                                                                  true) {
                                                                isAlwaysCaps =
                                                                    false;
                                                              } else {
                                                                isAlwaysCaps =
                                                                    true;
                                                              }
                                                            });

                                                            break;
                                                          default:
                                                        }
                                                      }
                                                      // print(inputValue);
                                                      // await tv.sendInputString(
                                                      //     inputValue);

                                                      //await tv.sendKey(
                                                      //     "KEY_" + key.text);
                                                      //search KEY_DTV_SIGNAL
                                                    }),
                                              )));
                                        });
                                  },
                                  child: Icon(
                                    Icons.keyboard,
                                    color: iconColor,
                                    size: 28,
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.10,
                    )
                  ]),
            ),
          )),
    ));
  }
}
