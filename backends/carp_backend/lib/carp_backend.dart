/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

library carp_backend;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

import 'package:carp_serializable/carp_serializable.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_webservices/carp_services/carp_services.dart';
import 'package:carp_webservices/carp_auth/carp_auth.dart';
import 'package:research_package/model.dart';

part 'carp_data_manager.dart';
part 'data_stream_buffer.dart';
part 'carp_study_manager.dart';
part 'localization_manager.dart';
part 'informed_consent_manager.dart';
part 'carp_resource_manager.dart';
part 'carp_localization.dart';
part 'carp_backend.g.dart';
part 'carp_deployment_service.dart';
part 'message_manager.dart';

/// Specify a CARP Service endpoint for uploading data.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class CarpDataEndPoint extends DataEndPoint {
  /// The method used to upload to CARP.
  /// See [CarpUploadMethod] for options.
  CarpUploadMethod uploadMethod;

  /// The name of the CARP endpoint. Can be anything, but its recommended
  /// to name it according to the CARP service name.
  String name;

  /// The URI of the CARP endpoint.
  String? uri;

  /// The CARP web service client ID
  String? clientId;

  /// The CARP web service client secret
  String? clientSecret;

  /// Email used as username in password authentication.
  String? email;

  /// Password used in password authentication.
  ///
  /// Note that the password is in **clear text** and should hence only be used
  /// if the study is created locally on the phone in Dart.
  ///
  /// If the study deployment is downloaded from CARP (i.e., via the
  /// [CarpDeploymentService]), then the authentication used for downloading
  /// is used and the [email] and [password] may be `null`.
  String? password;

  /// When uploading to CARP using file in the [CarpUploadMethod.DATA_STREAM]
  /// or [CarpUploadMethod.FILE] methods, specifies if the local buffered data on the phone
  /// should be deleted once uploaded.
  bool deleteWhenUploaded = true;

  /// Creates a [CarpDataEndPoint].
  CarpDataEndPoint({
    this.uploadMethod = CarpUploadMethod.DATA_STREAM,
    this.name = 'CARP Web Services',
    this.uri,
    this.clientId,
    this.clientSecret,
    this.email,
    this.password,
    this.deleteWhenUploaded = true,
    super.dataFormat,
  }) : super(
          type: DataEndPointTypes.CAWS,
        );

  /// Creates a [CarpDataEndPoint] based on a [CarpApp] [app].
  CarpDataEndPoint.fromCarpApp({
    CarpUploadMethod uploadMethod = CarpUploadMethod.DATA_STREAM,
    String name = 'CARP Web Services',
    String? collection,
    bool deleteWhenUploaded = true,
    String dataFormat = NameSpace.CARP,
    required CarpApp app,
  }) : this(
          uploadMethod: uploadMethod,
          name: app.name,
          uri: app.uri.toString(),
          clientId: app.oauth.clientID,
          clientSecret: app.oauth.clientSecret,
          dataFormat: dataFormat,
          deleteWhenUploaded: deleteWhenUploaded,
        );

  Function get fromJsonFunction => _$CarpDataEndPointFromJson;

  factory CarpDataEndPoint.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json) as CarpDataEndPoint;
  Map<String, dynamic> toJson() => _$CarpDataEndPointToJson(this);

  String toString() =>
      '$runtimeType [$name] - method: ${uploadMethod.toString().split('.').last}';
}

/// A enumeration of upload methods to CARP
enum CarpUploadMethod {
  /// Upload data as data streams (the default method).
  DATA_STREAM,

  /// Upload each data point separately using the old DataPoint endpoint in CAWS.
  DATA_POINT,

  /// Collect measurements in a SQLite DB file and upload as a `db` file
  FILE,
}

// enum CarpBackendEvents {
//   /// The CarpBackend is successfully initialized.
//   Initialized,

//   /// The status of the deployment has successfully been downloaded from the CARP server.
//   DeploymentStatusRetrieved,

//   /// The study protocol has successfully been downloaded from the CARP server.
//   ProtocolRetrieved,

//   /// The deployment has successfully been downloaded from the CARP server.
//   DeploymentRetrieved,

//   /// The deployment has been marked as successfully at the CARP server.
//   DeploymentSuccessful,

//   /// An error occurred in the communication with the CARP server.
//   Error,
// }

/// Exception for CARP backend communication.
class CarpBackendException implements Exception {
  String? message;
  CarpBackendException([this.message]);
  String toString() => "$runtimeType - ${message ?? ""}";
}

// String _encode(Object? object) =>
//     const JsonEncoder.withIndent(' ').convert(object);
