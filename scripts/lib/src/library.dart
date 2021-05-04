// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:scripts/src/versions.dart';

/// Builds a library file for the official images repository based on the passed
/// [commit] and [versions].
String buildLibrary(String commit, Versions versions) => '''
Maintainers: Alexander Thomas <athom@google.com> (@athomas), Tony Pujals <tonypujals@google.com> (@tonypujals)
GitRepo: https://github.com/dart-lang/dart-docker.git
GitFetch: refs/heads/main
GitCommit: $commit

Tags: ${versions.stableTags}
Directory: stable/buster

Tags: ${versions.betaTags}
Directory: beta/buster
''';

/// Uses `git rev-parse HEAD` to get the hash of the current commit.
String get commit =>
    Process.runSync('git', ['rev-parse', 'HEAD']).stdout.trim();
