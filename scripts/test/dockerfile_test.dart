// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:scripts/src/dockerfile.dart';
import 'package:scripts/src/versions.dart';
import 'package:test/test.dart';

import 'utils.dart';

var version =
    DartSdkVersion('stable', Version.parse('3.14.1'), 'abc', fakeRead);

void main() {
  test('build dockerfile', () {
    const expected = '''
ENV DART_CHANNEL        stable
ENV DART_VERSION   3.14.1
ENV DART_SHA256    abc
''';
    var dockerfile = buildDockerfile(version, dockerfileTemplate);
    expect(dockerfile, expected);
  });

  test('throws on unknown variable', () {
    const template = '''
ENV UNKNOWN       {{UNKNOWN}}
''';
    expect(() => buildDockerfile(version, template), throwsStateError);
  });

  test('throws on missing variable', () {
    const template = 'ENV DART_VERSION       {{DART_VERSION}}';
    expect(() => buildDockerfile(version, template), throwsArgumentError);
  });
}
