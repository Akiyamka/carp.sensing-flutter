/*
 * Copyright 2022 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of carp_polar_package;

abstract class _PolarProbe extends StreamProbe {
  @override
  PolarDeviceManager get deviceManager =>
      super.deviceManager as PolarDeviceManager;
}

/// Collects accelerometer data from the Polar device.
class PolarAccelerometerProbe extends _PolarProbe {
  @override
  Stream<Measurement>? get stream => (deviceManager.isConnected)
      ? deviceManager.features.contains(DeviceStreamingFeature.acc)
          ? deviceManager.polar
              .startAccStreaming(deviceManager.id)
              .map((event) => Measurement.fromData(
                    PolarAccelerometer.fromPolarData(event),
                    event.timeStamp,
                  ))
              .asBroadcastStream()
          : null
      : null;
}

/// Collects gyroscope data from the Polar device.
class PolarGyroscopeProbe extends _PolarProbe {
  @override
  Stream<Measurement>? get stream => (deviceManager.isConnected)
      ? deviceManager.features.contains(DeviceStreamingFeature.gyro)
          ? deviceManager.polar
              .startGyroStreaming(deviceManager.id)
              .map((event) => Measurement.fromData(
                    PolarGyroscope.fromPolarData(event),
                    event.timeStamp,
                  ))
              .asBroadcastStream()
          : null
      : null;
}

/// Collects magnetometer data from the Polar device.
class PolarMagnetometerProbe extends _PolarProbe {
  @override
  Stream<Measurement>? get stream => (deviceManager.isConnected)
      ? deviceManager.features.contains(DeviceStreamingFeature.magnetometer)
          ? deviceManager.polar
              .startMagnetometerStreaming(deviceManager.id)
              .map((event) => Measurement.fromData(
                    PolarMagnetometer.fromPolarData(event),
                    event.timeStamp,
                  ))
              .asBroadcastStream()
          : null
      : null;
}

/// Collects PPG data from the Polar device.
class PolarPPGProbe extends _PolarProbe {
  @override
  Stream<Measurement>? get stream => (deviceManager.isConnected)
      ? deviceManager.features.contains(DeviceStreamingFeature.ppg)
          ? deviceManager.polar
              .startOhrStreaming(deviceManager.id)
              .map((event) => Measurement.fromData(
                    PolarPPG.fromPolarData(event),
                    event.timeStamp,
                  ))
              .asBroadcastStream()
          : null
      : null;
}

/// Collects PPI data from the Polar device.
class PolarPPIProbe extends _PolarProbe {
  @override
  Stream<Measurement>? get stream => (deviceManager.isConnected)
      ? deviceManager.features.contains(DeviceStreamingFeature.ppi)
          ? deviceManager.polar
              .startOhrPPIStreaming(deviceManager.id)
              .map((event) => Measurement.fromData(
                    PolarPPI.fromPolarData(event),
                    event.timeStamp,
                  ))
              .asBroadcastStream()
          : null
      : null;
}

/// Collects ECG data from the Polar device.
class PolarECGProbe extends _PolarProbe {
  @override
  Stream<Measurement>? get stream {
    debug('$runtimeType - features: ${deviceManager.features}');
    return (deviceManager.isConnected)
        ? deviceManager.features.contains(DeviceStreamingFeature.ecg)
            ? deviceManager.polar
                .startEcgStreaming(deviceManager.id)
                .map((event) => Measurement.fromData(
                      PolarECG.fromPolarData(event),
                      event.timeStamp,
                    ))
                .asBroadcastStream()
            : null
        : null;
  }
}

/// Collects HR data from the Polar device.
class PolarHRProbe extends _PolarProbe {
  @override
  Stream<Measurement>? get stream => (deviceManager.isConnected)
      ? deviceManager.polar.heartRateStream
          .map((event) => Measurement.fromData(
              PolarHR.fromPolarData(event.identifier, event.data)))
          .asBroadcastStream()
      : null;
}
