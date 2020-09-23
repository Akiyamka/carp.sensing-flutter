/*
 * Copyright 2020 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

/// A library for collecting survey from the [Research Package](https://pub.dev/packages/research_package):
///  * survey
library survey;

import 'dart:async';
import 'package:json_annotation/json_annotation.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:research_package/research_package.dart';
import 'package:flutter/material.dart';

part 'survey.g.dart';
part 'survey_domain.dart';
part 'survey_runtime.dart';
part 'survey_ui.dart';
part 'who5.dart';
