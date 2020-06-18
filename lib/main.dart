import 'dart:async';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String animationType = "Alarm";
  bool isPause = true;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();


  Timer _timer;
  Duration _duration;
  Duration _tick;
  Function _onTick;
  Duration _countdown;
  DateTime _endTime;
  String _buttonText;
  String _displayTime;

  @override
  void initState() {
    setState(() {
      _duration = _duration ?? Duration(minutes: 1);
      _tick = _tick ?? Duration(milliseconds: 100);
      _onTick = _onTick ?? (String displayTime) => {};
      resetTimer();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xfffeb47b),
              Color(0xffFDB99B),
              Color(0xffffffff),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  buildAnimation(context),
                  _buildTimeText(),
                ],
              ),
              _buildButton(context)
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  //ui elements
  Widget _buildTimeText() {
    return Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                  left: 0.0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      _displayTime,
                      style: TextStyle(color: Colors.pinkAccent, fontSize: 30),
                    ),
                  ),
                );
  }
  Widget _buildButton(BuildContext context) {
    return FlatButton(
              color: Colors.pinkAccent,
              textColor: Colors.white,
              shape: StadiumBorder(),
              child: Text(_buttonText),
              onPressed: () {
                onButtonClick(context);
              },
            );
  }
  Widget buildAnimation(BuildContext context) {
    return Container(
                  height: MediaQuery.of(context).size.width / 1.5,
                  child: FlareActor(
                    "animation/bg.flr",
                    animation: animationType,
                    fit: BoxFit.contain,
                    isPaused: isPause,
                  ),
                );
  }


  //timer related methods
  void stopTimer() => setState(() {
    isPause=true;
    _buttonText = 'Reset';
    _timer.cancel();
  });

  void resetTimer() => setState(() {
    _countdown = _duration;
    _displayTime = getDisplayTime(_countdown);
    _buttonText = 'Start';
  });

  void onButtonClick(BuildContext context) {
    if (_timer?.isActive ?? false) {
      isPause = true;
      stopTimer();
    } else {
      if (_countdown == _duration) {
        isPause = false;
        startTimer(context);
      } else {
        isPause = false;
        resetTimer();
        _onTick(_displayTime);
      }
    }
  }

  void startTimer(BuildContext context) {
    showAlert("Your Time starts now!!", scaffoldKey);
    setState(() {
      _endTime = DateTime.now().add(_duration);
      _displayTime = getDisplayTime(_duration - _tick);
      _onTick(_displayTime);
      _buttonText = 'Stop';
      _timer = Timer.periodic(_tick, (Timer timer) {
        setState(() {
          _countdown = _endTime.difference(DateTime.now());
          _displayTime = getDisplayTime(_countdown);
          _onTick(_displayTime);
          if (DateTime.now().isAfter(_endTime)) {
            stopTimer();
            showAlert("Time Is Over", scaffoldKey);
          }
        });
      });
    });
  }

  String getDisplayTime(Duration time) {
    int minutes = time.inMinutes;
    int seconds = (time.inSeconds - (time.inMinutes * 60));
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void showAlert(String msg,GlobalKey<ScaffoldState> scaffoldKey)
  {
    final snackBar = SnackBar(
      duration: Duration(
          seconds: 2
      ),
      content: Text(msg),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }



}
