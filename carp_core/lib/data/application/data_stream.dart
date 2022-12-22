/*
 * Copyright 2022 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of carp_core_data;

/// Configures the set of [ExpectedDataStream] for a study deployment.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class DataStreamsConfiguration {
  String studyDeploymentId;
  Set<ExpectedDataStream> expectedDataStreams;

  DataStreamsConfiguration({
    required this.studyDeploymentId,
    required this.expectedDataStreams,
  });
  factory DataStreamsConfiguration.fromJson(Map<String, dynamic> json) =>
      _$DataStreamsConfigurationFromJson(json);
  Map<String, dynamic> toJson() => _$DataStreamsConfigurationToJson(this);
}

/// The expected data type for a device with a rolename.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class ExpectedDataStream {
  String deviceRoleName;
  String dataType;

  ExpectedDataStream({
    required this.deviceRoleName,
    required this.dataType,
  });
  factory ExpectedDataStream.fromJson(Map<String, dynamic> json) =>
      _$ExpectedDataStreamFromJson(json);
  Map<String, dynamic> toJson() => _$ExpectedDataStreamToJson(this);

  @override
  bool operator ==(other) =>
      other is ExpectedDataStream &&
      deviceRoleName == other.deviceRoleName &&
      dataType == other.dataType;

  @override
  int get hashCode => Object.hash(deviceRoleName.hashCode, dataType.hashCode);
}

/// Identifies a data stream of collected [dataType] data on the device with
/// [deviceRoleName] in a deployed study protocol with [studyDeploymentId].
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class DataStreamId {
  String studyDeploymentId;
  String deviceRoleName;
  String dataType;

  DataStreamId({
    required this.studyDeploymentId,
    required this.deviceRoleName,
    required this.dataType,
  });
  factory DataStreamId.fromJson(Map<String, dynamic> json) =>
      _$DataStreamIdFromJson(json);
  Map<String, dynamic> toJson() => _$DataStreamIdToJson(this);
}

/// A collection of non-overlapping, ordered, data [measurements].
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class DataStreamBatch {
  DataStreamId dataStream;
  int firstSequenceId;
  List<Measurement> measurements;
  Set<int> triggerIds;

  DataStreamBatch({
    required this.dataStream,
    required this.firstSequenceId,
    required this.measurements,
    required this.triggerIds,
  });
  factory DataStreamBatch.fromJson(Map<String, dynamic> json) =>
      _$DataStreamBatchFromJson(json);
  Map<String, dynamic> toJson() => _$DataStreamBatchToJson(this);
}

/// The result of a measurement of [data] of a given [dataType] at a specific
/// point or interval in time.
/// When [sensorEndTime] is set, the [data] pertains to an interval in time;
/// otherwise, a point in time.
///
/// The unit of [sensorStartTime] and [sensorEndTime] is fully determined by the
/// sensor that collected the data.
/// For example, it could be a simple clock increment since the device powered up.
/// However, in CARP we prefer microseconds over milliseconds for higher precision.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class Measurement {
  /// Start time as set by the sensor.
  /// The unit is determined by the sensor.
  int sensorStartTime;

  /// End time as set by the sensor, if available.
  int? sensorEndTime;

  /// The type of the [data].
  @JsonKey(ignore: true)
  DataType get dataType => data.format;

  /// The [TaskControl] which triggered the collection of this measurement.
  @JsonKey(ignore: true)
  TaskControl? taskControl;

  /// The [Data] collected in this measurement.
  Data data;

  Measurement({
    required this.sensorStartTime,
    this.sensorEndTime,
    required this.data,
  });

  /// Create a measurement from [data] giving it the current time
  /// stamp as [sensorStartTime].
  factory Measurement.fromData(Data data, [int? sensorStartTime]) =>
      Measurement(
          sensorStartTime:
              sensorStartTime ?? DateTime.now().microsecondsSinceEpoch,
          data: data);

  factory Measurement.fromJson(Map<String, dynamic> json) =>
      _$MeasurementFromJson(json);
  Map<String, dynamic> toJson() => _$MeasurementToJson(this);
}
