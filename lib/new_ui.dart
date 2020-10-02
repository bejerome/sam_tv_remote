import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'app_colors.dart';

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

  @override
  void initState() {
    willAcceptStream = new BehaviorSubject<int>();
    willAcceptStream.add(0);
    super.initState();
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
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: selectColor,
                          size: 28,
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
                        onTap: () {
                          print("Mute");
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
                        onTap: () {
                          print("Power Pressed");
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
                        upIconCallBack: () {
                          print("Vol up");
                        },
                        downIcon: Icons.remove,
                        downIconCallBack: () {
                          print("Vol down");
                        },
                      ),
                      CustomCircle(
                        size: size,
                        background: backgroundColor,
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
                          },
                          downIconCallBack: () {
                            print("Channel Down");
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.lens,
                        color: iconColor,
                        size: 8,
                      ),
                      Container(
                        width: 8,
                      ),
                      Icon(
                        Icons.lens,
                        color: iconColor,
                        size: 8,
                      ),
                      Container(
                        width: 8,
                      ),
                      Icon(
                        Icons.lens,
                        color: iconColor,
                        size: 8,
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
                        height: 0.0,
                        child: DragTarget(
                          builder: (context, list, list2) {
                            return Container(
                              padding: EdgeInsets.all(3),
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
                            debugPrint('^');
                            this.willAcceptStream.add(50);
                            // _fuctionDrag("================>");
                            return false;
                          },
                          onLeave: (item) {
                            debugPrint('RESET');
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
                            debugPrint('<================');
                            this.willAcceptStream.add(-50);
                            return false;
                          },
                          onLeave: (item) {
                            debugPrint('RESET');
                            this.willAcceptStream.add(0);
                          },
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: MediaQuery.of(context).size.width / 4,
                        child: Container(
                          padding: EdgeInsets.all(10),
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
                                      color: (snapshot.data) > 0
                                          ? Color(0xFF59C533)
                                          : (snapshot.data) == 0
                                              ? buttonBackgroundColor
                                              : Color(0xFFFF4B4D),
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
                            debugPrint('================>');
                            this.willAcceptStream.add(50);
                            // _fuctionDrag("================>");
                            return false;
                          },
                          onLeave: (item) {
                            debugPrint('RESET');
                            this.willAcceptStream.add(0);
                          },
                        ),
                      ),
                      Positioned(
                        bottom: -90.0,
                        left: size.width / 2.5,
                        child: DragTarget(
                          builder: (context, list, list2) {
                            return Container(
                              padding: EdgeInsets.all(3),
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
                            debugPrint('V');
                            this.willAcceptStream.add(50);
                            // _fuctionDrag("================>");
                            return false;
                          },
                          onLeave: (item) {
                            debugPrint('RESET');
                            this.willAcceptStream.add(0);
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
