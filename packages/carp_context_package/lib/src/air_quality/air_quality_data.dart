/*
 * Copyright 2019-2022 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of carp_context_package;

/// A [Data] that holds air quality information collected via the
/// [World's Air Quality Index (WAQI)](https://waqi.info) API.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class AirQuality extends Data {
  static const dataType = ContextSamplingPackage.AIR_QUALITY;

  int airQualityIndex;
  String? source, place;
  double latitude, longitude;
  AirQualityLevel? airQualityLevel;

  AirQuality({
    required this.airQualityIndex,
    this.source,
    this.place,
    required this.latitude,
    required this.longitude,
    this.airQualityLevel,
  }) : super();

  AirQuality.fromAirQualityData(waqi.AirQualityData airQualityData)
      : latitude = airQualityData.latitude,
        longitude = airQualityData.longitude,
        airQualityIndex = airQualityData.airQualityIndex,
        source = airQualityData.source,
        place = airQualityData.place,
        airQualityLevel =
            AirQualityLevel.values[airQualityData.airQualityLevel.index],
        super();

  factory AirQuality.fromJson(Map<String, dynamic> json) =>
      _$AirQualityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AirQualityToJson(this);

  @override
  String toString() =>
      '${super.toString()}, place: $place (latitude:$latitude, longitude:$longitude), souce: $source, airQualityIndex: $airQualityIndex, airQualityLevel: $airQualityLevel';
}

/// Level of air quality.
enum AirQualityLevel {
  UNKNOWN,
  GOOD,
  MODERATE,
  UNHEALTHY_FOR_SENSITIVE_GROUPS,
  UNHEALTHY,
  VERY_UNHEALTHY,
  HAZARDOUS
}
