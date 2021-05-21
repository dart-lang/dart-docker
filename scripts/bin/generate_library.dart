#! /usr/bin/env dart
// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:scripts/src/library.dart';
import 'package:scripts/src/versions.dart';

/// Reads `versions.json` and generates the `dart` library definition.
void main() {
  generateLibrary(const LocalFileSystem());
}

void generateLibrary(FileSystem fileSystem) {
  var read = (_, {headers}) =>
      throw StateError("generate_library should work offline");
  var versions = versionsFromFile(fileSystem, read);
  stdout.write(buildLibrary(commit, versions['stable']!, versions['beta']!));
}
