#! /usr/bin/env dart
// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:scripts/src/http.dart' as http;
import 'package:scripts/src/versions.dart';

/// Downloads the latest versions on the Dart stable and beta channels and the
/// relevant SHA256 checksums. For all versions that haven't changed, the script
/// verifies that the checksums are still matching.
void main() async {
  await verify(const LocalFileSystem(), http.read);
}

Future<void> verify(FileSystem fileSystem, http.HttpRead read) async {
  var versions = versionsFromFile(fileSystem, read);
  await for (var version in Stream.fromIterable(versions.values)) {
    await version.verify();
  }
}
