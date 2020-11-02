/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of esense;

abstract class _ESenseProbe extends StreamProbe {
  bool connected = false;
  String deviceName;
  int samplingRate = 10;

  void onInitialize(Measure measure) {
    assert(measure is ESenseMeasure);
    super.onInitialize(measure);
    deviceName = (measure as ESenseMeasure)?.deviceName;
    assert(deviceName != null, 'Must specify a non-null device name for the eSense device.');
    samplingRate ??= (measure as ESenseMeasure)?.samplingRate;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) {
      print('eSense connection : $event');
      // wait until connection is established before listening to events.
      if (!connected && event.type == ConnectionType.connected) {
        connected = true;

        // this is a hack! - don't know why, but the sensorEvents stream needs a kick in the ass to get started...
        ESenseManager.sensorEvents.listen(null);
        this.restart();
      } else {
        connected = false;
      }
    });

    ESenseManager.setSamplingRate(samplingRate);
    ESenseManager.connect(deviceName);
  }
}

/// Collects eSense button pressed events.
/// It generates an [ESenseButtonDatum] every time the button is pressed or released.
class ESenseButtonProbe extends _ESenseProbe {
  Stream<Datum> get stream {
    if (!ESenseManager.connected) ESenseManager.connect(deviceName);
    return (ESenseManager.connected)
        ? ESenseManager.eSenseEvents
            .where((event) => event.runtimeType == ButtonEventChanged)
            .map((event) => ESenseButtonDatum(deviceName: deviceName, pressed: (event as ButtonEventChanged).pressed))
        : null;
  }
}

/// Collects eSense sensor events.
/// It generates an [ESenseSensorDatum] for each sensor event.
class ESenseSensorProbe extends _ESenseProbe {
  Stream<Datum> get stream {
    if (!ESenseManager.connected) ESenseManager.connect(deviceName);
    return (ESenseManager.connected)
        ? ESenseManager.sensorEvents
            .map((event) => ESenseSensorDatum.fromSensorEvent(deviceName: deviceName, event: event))
        : null;
  }
}
