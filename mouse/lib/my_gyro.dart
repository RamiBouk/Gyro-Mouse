import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_sensors/flutter_sensors.dart';

class MyGyro extends Sensors {
  bool _gyroAvailable = true;
  List<double> _gyroData = List.filled(3, 0.0);
  StreamSubscription? _gyroSubscription;
  int i = 0;
  State? appState;

  void checkGyroscopeStatus() async {
    await SensorManager().isSensorAvailable(Sensors.GYROSCOPE).then((result) {
      appState?.setState(() {
        _gyroAvailable = result;
      });
    });
  }

  Future<void> startGyroscope(
      int fps, double a, Socket socket, double sens) async {
    if (_gyroSubscription != null) return;
    if (_gyroAvailable) {
      //
      final stream = await SensorManager().sensorUpdates(
          sensorId: Sensors.GYROSCOPE,
          interval:
              Duration(microseconds: Duration.microsecondsPerSecond ~/ fps));
      _gyroSubscription = stream.listen((sensorEvent) {
        if (sensorEvent.data.any((element) => element * element > a * a)) {
          i++;

          _gyroData[0] += sensorEvent.data[0];
          _gyroData[2] += sensorEvent.data[2];

          socket.write((_gyroData[0] * -sens).toString() +
              "|" +
              (_gyroData[2] * -sens).toString() +
              " ");
          _gyroData[0] = 0;
          _gyroData[2] = 0;
        }
      });
    }
  }

  void stopGyroscope() {
    if (_gyroSubscription == null) return;
    _gyroSubscription?.cancel();
    _gyroSubscription = null;
  }
}
