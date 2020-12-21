import 'package:flutter/material.dart';

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

class CustomVolButton extends StatelessWidget {
  const CustomVolButton(
      {Key key,
      @required this.size,
      @required this.buttonBackground,
      @required this.iconColor,
      @required this.buttonLabel,
      @required this.textColor,
      @required this.upIcon,
      @required this.downIcon,
      @required this.upIconCallBack,
      @required this.downIconCallBack,
      @required this.muteIconCallBack})
      : super(key: key);

  final Size size;
  final Color buttonBackground;
  final Color iconColor;
  final Color textColor;
  final IconData upIcon;
  final IconData downIcon;
  final Function upIconCallBack;
  final Function downIconCallBack;
  final Function muteIconCallBack;
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
          GestureDetector(
            onTap: () async {
              muteIconCallBack();
            },
            child: Container(
              width: size.height * 0.11,
              height: size.height * 0.08,
              child: Icon(
                Icons.volume_mute,
                color: textColor,
                size: 28,
              ),
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
