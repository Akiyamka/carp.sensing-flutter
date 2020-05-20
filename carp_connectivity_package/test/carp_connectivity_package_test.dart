import 'package:carp_connectivity_package/connectivity.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'dart:io';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';

String _encode(Object object) => const JsonEncoder.withIndent(' ').convert(object);

void main() {
  Study study;

  setUp(() {
    //SamplingPackageRegistry.register(AudioSamplingPackage());
    //SamplingPackageRegistry.register(CommunicationSamplingPackage());
    //SamplingPackageRegistry.register(ContextSamplingPackage());

    study = Study("1234", "bardram", name: "bardram study");
    //study.dataEndPoint = DataEndPoint(DataEndPointType.PRINT);
    study.dataEndPoint = FileDataEndPoint()
      ..bufferSize = 50 * 1000
      ..zip = true
      ..encrypt = false;

    // adding all measure from the common schema to one one trigger and one task
    study.addTriggerTask(
        ImmediateTrigger(), // a simple trigger that starts immediately
        Task(name: 'Sampling Task')
          ..measures =
              SamplingSchema.common(namespace: NameSpace.CARP).measures.values.toList() // a task with all measures
        );
  });

  test('Study -> JSON', () async {
    print(_encode(study));

    expect(study.id, "1234");
  });

  test('JSON -> Study, assert study id', () async {
    final studyJson = _encode(study);

    Study study_2 = Study.fromJson(json.decode(studyJson) as Map<String, dynamic>);
    expect(study_2.id, study.id);

    print(_encode(study_2));
  });

  test('JSON -> Study, deep assert', () async {
    final studyJson = _encode(study);

    Study study_2 = Study.fromJson(json.decode(studyJson) as Map<String, dynamic>);
    expect(_encode(study_2), equals(studyJson));
  });

  test('Configuration -> JSON', () async {
    final studyJson = _encode(study);

    Study study_2 = Study.fromJson(json.decode(studyJson) as Map<String, dynamic>);
    expect(study_2.name, study.name);
  });

  test('Plain JSON string -> Study object', () async {
    print(Directory.current.toString());
    String plainStudyJson = File("test/study_1234.json").readAsStringSync();
    print(plainStudyJson);

    Study plainStudy = Study.fromJson(json.decode(plainStudyJson) as Map<String, dynamic>);
    expect(plainStudy.id, study.id);

    final studyJson = _encode(study);

    Study study_2 = Study.fromJson(json.decode(plainStudyJson) as Map<String, dynamic>);
    expect(_encode(study_2), equals(studyJson));
  });

  test('Data point -> JSON', () async {
    var dp =
        DataPoint.fromDatum(study.id, study.userId, MapDatum({'item_1': '12.23423452345', 'item_2': '3.82375823475'}));
    print(_encode(dp));

    BluetoothDatum datum = BluetoothDatum()
      ..scanResult.add(BluetoothDevice()
        ..bluetoothDeviceId = "weg"
        ..bluetoothDeviceName = "ksjbdf"
        ..connectable = true
        ..txPowerLevel = 314
        ..rssi = 567
        ..bluetoothDeviceType = "classic");

    final DataPoint data = DataPoint.fromDatum(study.id, study.userId, datum);

    print(_encode(data.toJson()));
  });

  test('Triggers -> JSON', () async {
    Study study_3 = Study("3", "bardram", name: "Multi Trigger Study");
    study_3.dataEndPoint = FileDataEndPoint()
      ..bufferSize = 50 * 1000
      ..zip = true
      ..encrypt = false;

    study_3.addTriggerTask(
        DelayedTrigger(delay: 10 * 1000), // delay for 10 secs.
        Task(name: 'Sensing Task #1')
          ..measures = SamplingSchema.common()
              .getMeasureList(types: [SensorSamplingPackage.PEDOMETER, DeviceSamplingPackage.SCREEN]));

    study_3.addTriggerTask(
        PeriodicTrigger(period: 60 * 1000), // collect every min.
        Task(name: 'Sensing Task #2')
          ..measures = SamplingSchema.common()
              .getMeasureList(types: [SensorSamplingPackage.LIGHT, DeviceSamplingPackage.DEVICE]));

    study_3.addTriggerTask(
        ScheduledTrigger(schedule: DateTime(2019, 12, 24)), // collect date on Xmas.
        Task(name: 'Sensing Task #3')
          ..measures = SamplingSchema.common()
              .getMeasureList(types: [AppsSamplingPackage.APP_USAGE, ConnectivitySamplingPackage.BLUETOOTH]));

    RecurrentScheduledTrigger t1, t2, t3, t4;

    // collect every day at 13:30.
    t1 = RecurrentScheduledTrigger(type: RecurrentType.daily, time: Time(hour: 21, minute: 30));
    print('$t1');
    study_3.addTriggerTask(
        t1,
        Task(name: 'Sensing Task #1')
          ..measures = SamplingSchema.common().getMeasureList(types: [DeviceSamplingPackage.MEMORY]));

    // collect every other day at 13:30.
    t2 = RecurrentScheduledTrigger(type: RecurrentType.daily, time: Time(hour: 13, minute: 30), separationCount: 1);
    print('$t2');
    study_3.addTriggerTask(
        t2,
        Task(name: 'Sensing Task #1')
          ..measures = SamplingSchema.common()
              .getMeasureList(types: [AppsSamplingPackage.APPS, ConnectivitySamplingPackage.CONNECTIVITY]));

    // collect every wednesday at 12:23.
    t3 = RecurrentScheduledTrigger(
        type: RecurrentType.weekly, time: Time(hour: 12, minute: 23), dayOfWeek: DateTime.wednesday);
    print('$t3');
    study_3.addTriggerTask(
        t3,
        Task(name: 'Sensing Task #1')
          ..measures = SamplingSchema.common()
              .getMeasureList(types: [AppsSamplingPackage.APPS, ConnectivitySamplingPackage.CONNECTIVITY]));

    // collect every 2nd monday at 12:23.
    t4 = RecurrentScheduledTrigger(
        type: RecurrentType.weekly, time: Time(hour: 12, minute: 23), dayOfWeek: DateTime.monday, separationCount: 1);
    print('$t4');
    study_3.addTriggerTask(
        t4,
        Task(name: 'Sensing Task #1')
          ..measures = SamplingSchema.common()
              .getMeasureList(types: [AppsSamplingPackage.APPS, ConnectivitySamplingPackage.CONNECTIVITY]));

    // when entering the 'wifi.bardram.net' WIFI network, start sampling bluetooth devices
    study_3.addTriggerTask(
        SamplingEventTrigger(
            measureType: MeasureType(NameSpace.CARP, ConnectivitySamplingPackage.WIFI),
            resumeCondition: WifiDatum()..ssid = 'wifi.bardram.net'),
        Task(name: 'Sensing Task #1')
          ..measures = SamplingSchema.common().getMeasureList(types: [ConnectivitySamplingPackage.BLUETOOTH]));

    study_3.addTriggerTask(
        ConditionalSamplingEventTrigger(
            measureType: MeasureType(NameSpace.CARP, ConnectivitySamplingPackage.WIFI),
            resumeCondition: (datum) => (datum as WifiDatum).ssid == 'wifi.bardram.net'),
        Task(name: 'Sensing Task #1')
          ..measures = SamplingSchema.common().getMeasureList(types: [ConnectivitySamplingPackage.BLUETOOTH]));

    final studyJson = _encode(study_3);

    print(studyJson);

    Study study_4 = Study.fromJson(json.decode(studyJson) as Map<String, dynamic>);
    expect(study_4.id, study_3.id);
  });
}
