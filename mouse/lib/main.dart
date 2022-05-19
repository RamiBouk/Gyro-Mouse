import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'my_gyro.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool conneceted = false;
  bool sending = false;
  int i = 0;
  MyGyro myGyro = MyGyro();
  late Socket socket;
  String ip = "0.0.0.0";
  double sens = 80;
  double scroll = 0;
  bool scrooling = false;
  double h1 = 4, h2 = 4, h3 = 4, h4 = 4, h5 = 4;

  void specific(String ip) async {
    if (!conneceted) {
      try {
        socket =
            await Socket.connect(ip, 4567, timeout: const Duration(seconds: 5));
      } catch (err) {
        return;
      }
      setState(() => conneceted = true);
    } else {
      socket.destroy();
      setState(() => conneceted = false);
    }
  }

  press(double h) async {
    double oldHeight = h;
    print("pressing $h1");
    setState(() {});
    h = 0;
    print("pressing2 $h1");
    print("pressing2 $h");

    await Future.delayed(const Duration(seconds: 2), () {});
    h = oldHeight;
    setState(() {});
    print("pressing2 $h1");
  }

  Future<void> scanNetwork() async {
    String tryip = "starting";
    if (!conneceted) {
      final String subnet = "192.168.1";
      const port = 4567;
      bool cncted = false;
      while (!cncted) {
        for (var i = 100; i < 120 && !cncted; i++) {
          ip = '$subnet.$i';

          try {
            socket = await Socket.connect(ip, port,
                timeout: const Duration(milliseconds: 50));
            setState(() => conneceted = true);
            socket.drain().then((value) => !conneceted ? specific(ip) : null);
            return;
          } catch (_) {}
        }
      }
    } else
      setState(() {
        conneceted = false;
      });
  }

  bool touch = false;
  @override
  Widget build(BuildContext context) {
    myGyro.appState;

    return SafeArea(
        child: Scaffold(
      backgroundColor: NeumorphicColors.background,
      body: Padding(
        padding: const EdgeInsetsDirectional.all(5),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: NeumorphicButton(
                      style: NeumorphicStyle(
                          color: conneceted ? Colors.red : Colors.green),
                      child: Center(
                          child: conneceted
                              ? const Text(
                                  "Disconnect",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                )
                              : const Text(
                                  "Connect",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                )),
                      onPressed: () {
                        if (!conneceted) {
                          scanNetwork();
                        } else {
                          socket.destroy();
                          conneceted = false;
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10).copyWith(bottom: 5),
              child: NeumorphicSlider(
                  value: sens,
                  onChanged: (newsens) => setState(() => sens = newsens),
                  min: 20,
                  max: 120),
            ),
            const Text("sensitivity"),
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Expanded(
                      //left button
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                              child: Neumorphic(
                                  style: NeumorphicStyle(
                                    shape: NeumorphicShape.concave,
                                    intensity: 1,
                                    boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.circular(12)),
                                    depth: conneceted ? h1 : -4,
                                  ),
                                  child: Listener(
                                    behavior: HitTestBehavior.translucent,
                                    onPointerDown: (_) async {
                                      touch = true;
                                      setState(() {
                                        h1 = 0;
                                      });

                                      await Future.delayed(
                                          const Duration(milliseconds: 100),
                                          () {});
                                      if (touch) {
                                        socket.write('hold ');
                                        myGyro.startGyroscope(
                                            70, 2 / sens, socket, sens);
                                      } else {
                                        socket.write('mouse1 ');
                                      }
                                      ;
                                    },
                                    onPointerUp: (_) {
                                      try {
                                        print("releases");
                                        myGyro.stopGyroscope();
                                      } catch (e) {}
                                      if (touch) {
                                        socket.write('release ');
                                      }
                                      setState(() {
                                        h1 = 4;
                                      });
                                      touch = false;
                                    },
                                    child: SizedBox(),
                                  ))))),
                  Expanded(
                      //left button
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                              child: Neumorphic(
                                  style: NeumorphicStyle(
                                    shape: NeumorphicShape.concave,
                                    intensity: 2,
                                    boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.circular(12)),
                                    depth: conneceted ? h2 : -4,
                                  ),
                                  child: Listener(
                                    behavior: HitTestBehavior.translucent,
                                    onPointerDown: (_) async {
                                      setState(() {
                                        h2 = 0;
                                      });
                                      print("11");
                                      socket.write('mouse2 ');
                                      await Future.delayed(
                                          const Duration(milliseconds: 200),
                                          () {});
                                    },
                                    onPointerUp: (_) {
                                      setState(() {
                                        h2 = 4;
                                      });
                                    },
                                    child: SizedBox(),
                                  ))))),
                ])),
            SizedBox(
              height: 200,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        //left button
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Neumorphic(
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.concave,
                                  intensity: 2,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(12)),
                                  depth: conneceted ? h3 : -4,
                                  lightSource: LightSource.topLeft,
                                ),
                                child: Listener(
                                  behavior: HitTestBehavior.translucent,
                                  onPointerDown: (_) {
                                    if (conneceted) {
                                      myGyro.startGyroscope(
                                          74, 2 / sens, socket, sens);
                                      setState(() {
                                        h3 = 0;
                                      });
                                    }
                                  },
                                  onPointerUp: (_) {
                                    if (conneceted) {
                                      myGyro.stopGyroscope();
                                      setState(() {
                                        h3 = 4;
                                      });
                                    }
                                  },
                                  child: const Center(child: Text("pointer")),
                                )))),
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Neumorphic(
                                    style: NeumorphicStyle(
                                      //  shape: NeumorphicShape.concave,
                                      intensity: 1,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(12)),
                                      depth: conneceted ? h4 : -4,
                                    ),
                                    child: Listener(
                                      behavior: HitTestBehavior.translucent,
                                      onPointerDown: (_) async {
                                        touch = true;
                                        setState(() {
                                          h4 = 0;
                                        });

                                        await Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {});
                                        if (touch) {
                                          socket.write('pgUp ');
                                        } else {
                                          socket.write('scrollUp ');
                                        }
                                        ;
                                      },
                                      onPointerUp: (_) {
                                        setState(() {
                                          h4 = 4;
                                        });

                                        touch = false;
                                      },
                                      child: Center(child: Text("up")),
                                    )))),
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Neumorphic(
                                    style: NeumorphicStyle(
                                      //  shape: NeumorphicShape.concave,
                                      intensity: 1,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(12)),
                                      depth: conneceted ? h5 : -4,
                                    ),
                                    child: Listener(
                                      behavior: HitTestBehavior.translucent,
                                      onPointerDown: (_) async {
                                        touch = true;
                                        setState(() {
                                          h5 = 0;
                                        });

                                        await Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {});
                                        if (touch) {
                                          socket.write('pgDown ');
                                        } else {
                                          socket.write('scrollDown ');
                                        }
                                        ;
                                      },
                                      onPointerUp: (_) {
                                        setState(() {
                                          h5 = 4;
                                        });

                                        touch = false;
                                      },
                                      child: const Center(child: Text("down")),
                                    )))),
                      ],
                    ))
                  ]),
            )
          ],
        ),
      ),
    ));
  }
}
