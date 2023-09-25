// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:scripts/src/versions.dart';

/// Builds a library file for the official images repository based on the passed
/// [commit] and [versions].
String buildLibrary(String commit, DartSdkVersion stable, DartSdkVersion beta) {
  var library = StringBuffer('''
Maintainers: Alexander Thomas <athom@google.com> (@athomas), Tony Pujals <tonypujals@google.com> (@subfuzion)
GitRepo: https://github.com/dart-lang/dart-docker.git
GitFetch: refs/heads/main
GitCommit: $commit
''');
  if (stable.version >= beta.version) {
    // stable is ahead of beta, that means stable _is_ beta.
    var tags = stable.tags.followedBy(['beta-sdk', 'beta']);
    library.write(_imageData(tags, 'stable'));
  } else {
    library.write(_imageData(stable.tags, 'stable'));
    library.write(_imageData(beta.tags, 'beta'));
  }
  return library.toString();
}

String _imageData(Iterable<String> tags, String channel) => '''

Tags: ${tags.join(', ')}
Architectures: amd64, arm32v7, arm64v8
Directory: $channel/bookworm
''';

/// Uses `git rev-parse HEAD` to get the hash of the current commit.
String get commit =>
    Process.runSync('git', ['rev-parse', 'HEAD']).stdout.trim();
