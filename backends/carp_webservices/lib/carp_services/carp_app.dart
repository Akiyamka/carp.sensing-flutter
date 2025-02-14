/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of carp_services;

/// Represents a CARP web service app endpoint.
class CarpApp {
  /// The name of this app. The name has to be unique.
  final String name;

  /// URI of the CARP web service
  final Uri baseUri;

  /// The OAuth 2.0 endpoint.
  final OAuthEndPoint oauth;

  /// The CARP study id for this app.
  String? studyId;

  /// The CARP study deployment id of this app.
  String? studyDeploymentId;

  /// Create a [CarpApp] which know how to access a CARP backend.
  ///
  /// [name], [baseUri], and [oauth] are required parameters in order to identify,
  /// address, and authenticate this client.
  ///
  /// A [studyDeploymentId] and a [study] may be specified, if known at the
  /// creation time.
  CarpApp({
    required this.name,
    required this.baseUri,
    required this.oauth,
    this.studyDeploymentId,
    this.studyId,
  });

  int get hashCode => name.hashCode;

  bool operator ==(other) => name == other;

  String toString() =>
      'CarpApp - name: $name, uri: $baseUri, studyDeploymentId: $studyDeploymentId, studyId: $studyId';
}
