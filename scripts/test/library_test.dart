// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:scripts/src/versions.dart';
import 'package:test/test.dart';
import 'package:scripts/src/library.dart';

import 'utils.dart';

void main() {
  test('build library', () {
    var stable =
        DartSdkVersion('stable', Version.parse("2.12.4"), {}, fakeRead);
    var beta = DartSdkVersion(
        'beta', Version.parse('2.13.0-211.6.beta'), {}, fakeRead);
    var library = buildLibrary('abcdef', stable, beta);
    var expected = '''
Maintainers: Alexander Thomas <athom@google.com> (@athomas), Tony Pujals <tonypujals@google.com> (@subfuzion)
GitRepo: https://github.com/dart-lang/dart-docker.git
GitFetch: refs/heads/main
GitCommit: abcdef

Tags: 2.12.4-sdk, 2.12-sdk, 2-sdk, stable-sdk, sdk, 2.12.4, 2.12, 2, stable, latest
Architectures: amd64, arm32v7, arm64v8
Directory: stable/bullseye

Tags: 2.13.0-211.6.beta-sdk, beta-sdk, 2.13.0-211.6.beta, beta
Architectures: amd64, arm32v7, arm64v8
Directory: beta/bullseye
''';

    expect(library, expected);
  });

  test('build library: stable is beta', () {
    var stable =
        DartSdkVersion('stable', Version.parse('2.13.0'), {}, fakeRead);
    var beta = DartSdkVersion('beta', Version.parse('2.13.0'), {}, fakeRead);
    var library = buildLibrary('abcdef', stable, beta);
    var expected = '''
Maintainers: Alexander Thomas <athom@google.com> (@athomas), Tony Pujals <tonypujals@google.com> (@subfuzion)
GitRepo: https://github.com/dart-lang/dart-docker.git
GitFetch: refs/heads/main
GitCommit: abcdef

Tags: 2.13.0-sdk, 2.13-sdk, 2-sdk, stable-sdk, sdk, 2.13.0, 2.13, 2, stable, latest, beta-sdk, beta
Architectures: amd64, arm32v7, arm64v8
Directory: stable/bullseye
''';

    expect(library, expected);
  });

  test('build library: stable is ahead of beta', () {
    var stable =
        DartSdkVersion('stable', Version.parse('2.13.0'), {}, fakeRead);
    var beta = DartSdkVersion(
        'beta', Version.parse('2.13.0-211.6.beta'), {}, fakeRead);
    var library = buildLibrary('abcdef', stable, beta);
    var expected = '''
Maintainers: Alexander Thomas <athom@google.com> (@athomas), Tony Pujals <tonypujals@google.com> (@subfuzion)
GitRepo: https://github.com/dart-lang/dart-docker.git
GitFetch: refs/heads/main
GitCommit: abcdef

Tags: 2.13.0-sdk, 2.13-sdk, 2-sdk, stable-sdk, sdk, 2.13.0, 2.13, 2, stable, latest, beta-sdk, beta
Architectures: amd64, arm32v7, arm64v8
Directory: stable/bullseye
''';

    expect(library, expected);
  });

  test('get commit test', () {
    expect(commit, matches(r'^\b[0-9a-f]{5,40}\b$'));
  });
}
