/*
 * Copyright 2022 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of domain;

String _encode(Object? object) =>
    const JsonEncoder.withIndent(' ').convert(object);

/// Specify how sampling should be done. Used to make default configuration of
/// [Measure]s.
///
/// A new [SamplingSchema] can be created for specific purposes. For example,
/// the following schema is made for outdoor activity tracking.
///
///     SamplingSchema activitySchema = SamplingSchema(name: 'Outdoor Activity Sampling Schema', powerAware: true)
///       ..measures.addEntries([
///         MapEntry(DataType.PEDOMETER,
///           PeriodicMeasure(MeasureType(NameSpace.CARP, DataType.PEDOMETER), enabled: true, frequency: 60 * 60 * 1000)),
///         MapEntry(DataType.SCREEN, Measure(MeasureType(NameSpace.CARP, DataType.SCREEN), enabled: true)),
///         MapEntry(DataType.LOCATION, Measure(MeasureType(NameSpace.CARP, DataType.LOCATION), enabled: true)),
///         MapEntry(DataType.NOISE,
///           PeriodicMeasure(MeasureType(NameSpace.CARP, DataType.NOISE),
///             enabled: true, frequency: 60 * 1000, duration: 2 * 1000)),
///         MapEntry(DataType.ACTIVITY, Measure(MeasureType(NameSpace.CARP, DataType.ACTIVITY), enabled: true)),
///         MapEntry(DataType.WEATHER,
///           WeatherMeasure(MeasureType(NameSpace.CARP, DataType.WEATHER), enabled: true, frequency: 2 * 60 * 60 * 1000))
///       ]);
///
/// There is also a set of factory methods than provide different default
/// sampling schemas, including:
///
/// * [`common`]() - a default, most common configuration of all known measures
/// * [`maximum`]() - using the `common` default configuration of all probes, but enabling all measures
/// * [`light`]() - a light configuration, enabling low-frequent sampling but with good coverage
/// * [`minimum`]() - a minimum set of measures, with a minimum sampling rate
/// * [`none`]() - no sampling at all (used to pause all sampling)
///
/// See the [documentation](https://github.com/cph-cachet/carp.sensing-flutter/wiki/Schemas) for further details.
///
class SamplingSchema {
  final Map<String, SamplingConfiguration> _configurations = {};

  /// The sampling schema type according to [SamplingSchemaType].
  // SamplingSchemaType type;

  /// A map of default [SamplingConfiguration]s for different measure types for
  /// this sampling schema.
  Map<String, SamplingConfiguration> get configurations => _configurations;

  // /// Is this sampling schema power-aware, i.e. adapting its sampling strategy
  // /// to the battery power status. See [PowerAwarenessState].
  // bool powerAware;

  SamplingSchema() : super();

  /// Add a default configuration to this schema.
  void addConfiguration(String type, SamplingConfiguration configuration) =>
      _configurations[type] = configuration;

  /// Remove a configuration from this schema.
  void removeConfiguration(String type) => _configurations.remove(type);

  /// Adds all configurations from [schema] to this sampling schema.
  /// If a measure in [schema] is already in this schema, its value is overwritten.
  void addSamplingSchema(SamplingSchema schema) =>
      configurations.addAll(schema.configurations);

  /// Returns a list of [SamplingConfiguration]s from this [SamplingSchema] for
  /// a list of [types].
  List<SamplingConfiguration> getConfigurationList(
      {required List<String> types}) {
    List<SamplingConfiguration> _list = [];

    // since we're using json serialization below, make sure that the json
    // functions have been registred
    _registerFromJsonFunctions();

    types.forEach((type) {
      if (configurations.containsKey(type)) {
        // using json encoding/decoding to clone the measure object
        final _json = _encode(configurations[type]);
        final SamplingConfiguration _clone = SamplingConfiguration.fromJson(
            json.decode(_json) as Map<String, dynamic>);
        _list.add(_clone);
      }
    });

    return _list;
  }

  // /// A sampling schema that does not adapt any [Measure]s.
  // ///
  // /// This schema is used in the power-aware adaptation of sampling. See [PowerAwarenessState].
  // /// [SamplingSchema.normal] is an empty schema and therefore don't change anything when
  // /// used to adapt a [StudyProtocol] and its [Measure]s in the [adapt] method.
  // factory SamplingSchema.normal({bool powerAware = false}) => SamplingSchema(
  //     type: SamplingSchemaType.normal,
  //     name: 'Default sampling',
  //     powerAware: powerAware);

  /// Adapts all [Measure]s in a [MasterDeviceDeployment] to this [SamplingSchema].
  ///
  /// The following parameters are adapted
  ///   * [enabled] - a measure can be enabled / disabled based on this schema
  ///   * [frequency] - the sampling frequency can be adjusted based on this schema
  ///   * [duration] - the sampling duration can be adjusted based on this schema
  void adapt(MasterDeviceDeployment deployment, {bool restore = true}) {
    deployment.tasks.forEach((task) {
      task.measures.forEach((measure) {
        if (measure is CAMSMeasure) {
          // first restore each measure in the study+tasks to its previous value
          if (restore) measure.restore();
          if (measures.containsKey(measure.type)) {
            // if an adapted measure exists in this schema, adapt to it
            measure.adapt(measures[measure.type]!);
          }
          // notify listeners that the measure has changed due to restoration
          // and/or adaptation
          measure.hasChanged();
        }
      });
    });
  }
}

// /// A enumeration of known sampling schemas types.
// enum SamplingSchemaType {
//   maximum,
//   common,
//   normal,
//   light,
//   minimum,
//   none,
//   debug,
// }
