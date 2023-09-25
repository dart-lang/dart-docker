#! /usr/bin/env dart
// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:scripts/src/dockerfile.dart';
import 'package:scripts/src/http.dart' as http;
import 'package:scripts/src/versions.dart';

/// Downloads the latest versions on the Dart stable and beta channels and the
/// relevant SHA256 checksums. For all versions that haven't changed, the script
/// verifies that the checksums are still matching.
void main(List<String> args) async {
  final results = (ArgParser()
        ..addFlag(
          'force',
          abbr: 'f',
        ))
      .parse(args);
  final force = results['force'];
  await update(const LocalFileSystem(), http.read, force);
}

Future<void> update(
    FileSystem fileSystem, http.HttpRead read, bool force) async {
  final versions = versionsFromFile(fileSystem, read);
  final updated = <DartSdkVersion>{};
  await for (final version in Stream.fromIterable(versions.values)) {
    if (await version.update() || force) {
      updated.add(version);
    }
  }
  if (force || updated.isNotEmpty) {
    final template =
        fileSystem.file('Dockerfile-debian.template').readAsStringSync();
    writeVersionsFile(fileSystem, [versions['stable']!, versions['beta']!]);
    for (final version in updated) {
      final dockerfileContent = buildDockerfile(version, template);
      final dockerfile = (await fileSystem
              .directory('${version.channel}/bookworm')
              .create(recursive: true))
          .childFile('Dockerfile');
      await dockerfile.writeAsString(dockerfileContent);
    }
  }
}
