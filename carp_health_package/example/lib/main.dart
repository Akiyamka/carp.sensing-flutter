import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_health_package/health_package.dart';
import 'package:health/health.dart';

/// This is a very simple example of how this sampling package is used with CARP Mobile Sensing (CAMS).
/// NOTE, however, that the code below will not run.
/// See the documentation on how to use CAMS: https://github.com/cph-cachet/carp.sensing-flutter/wiki
void main() async {
  SamplingPackageRegistry.register(HealthSamplingPackage());

  Study study = Study("1234", "bardram", name: "bardram study");

  // creating a task collecting step counts and blood pressure data for the last two days
  study.addTriggerTask(
    ImmediateTrigger(), // a simple trigger that starts immediately
    Task(name: 'Step and bloodpressure')
      ..addMeasure(
        HealthMeasure(
            MeasureType(NameSpace.CARP, HealthSamplingPackage.HEALTH), HealthDataType.STEPS, Duration(days: 2),
            name: 'Health Data'),
      )
      ..addMeasure(
        HealthMeasure(MeasureType(NameSpace.CARP, HealthSamplingPackage.HEALTH),
            HealthDataType.BLOOD_PRESSURE_DIASTOLIC, Duration(days: 2),
            name: 'Health Data'),
      )
      ..addMeasure(
        HealthMeasure(MeasureType(NameSpace.CARP, HealthSamplingPackage.HEALTH), HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
            Duration(days: 2),
            name: 'Health Data'),
      ),
  );

  // Create a Study Controller that can manage this study, initialize it, and start it.
  StudyController controller = StudyController(study);

  // await initialization before starting
  await controller.initialize();
  controller.resume();

  // listening on all data events from the study
  controller.events.forEach(print);
}
