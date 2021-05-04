// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:scripts/src/versions.dart';
import 'package:test/test.dart';
import 'package:scripts/src/library.dart';

void main() {
  test('buildLibrary test', () {
    var library = buildLibrary(
        'abcdef',
        Versions(Version.parse("2.12.4"), Version.parse('2.13.0-211.6.beta'),
            '2.12.4, stable', '2.13.0-211.6.beta, beta'));
    var expected = '''
Maintainers: Alexander Thomas <athom@google.com> (@athomas), Tony Pujals <tonypujals@google.com> (@tonypujals)
GitRepo: https://github.com/dart-lang/dart-docker.git
GitFetch: refs/heads/main
GitCommit: abcdef

Tags: 2.12.4, stable
Directory: stable/buster

Tags: 2.13.0-211.6.beta, beta
Directory: beta/buster
''';

    expect(library, expected);
  });

  test('get commit test', () {
    expect(commit, matches(r'^\b[0-9a-f]{5,40}\b$'));
  });
}
