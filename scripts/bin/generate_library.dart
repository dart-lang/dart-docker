#! /usr/bin/env dart
// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:scripts/src/library.dart';
import 'package:scripts/src/versions.dart';

/// Reads `versions.json` and generates the `dart` library definition.
void main() async {
  var json = jsonDecode(File('versions.json').readAsStringSync());
  var versions = Versions.fromJson(json);
  print(buildLibrary(commit, versions));
}
