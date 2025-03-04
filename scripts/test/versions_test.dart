// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:scripts/src/versions.dart';
import 'package:test/test.dart';

import 'utils.dart';

final stable = DartSdkVersion('stable', Version.parse('2.12.4'), {
  'x64': 'abc',
  'arm': 'def',
  'arm64': 'ghi',
}, fakeRead);
final beta = DartSdkVersion('beta', Version.parse('2.13.0-211.6.beta'), {
  'x64': 'jmn',
  'arm': 'opq',
  'arm64': 'rst',
}, fakeRead);

void main() {
  test('fromJson', () {
    var versions = versionsFromJson(<String, dynamic>{
      'stable': {
        'version': '2.12.4',
        'sha256': {'x64': 'abc', 'arm': 'def', 'arm64': 'ghi'},
      },
      'beta': {
        'version': '2.13.0-211.6.beta',
        'sha256': {'x64': 'jmn', 'arm': 'opq', 'arm64': 'rst'},
      },
    }, fakeRead);

    expect(versions['stable'], stable);
    expect(versions['beta'], beta);
    expect(versions['stable']?.tags, [
      '2.12.4-sdk',
      '2.12-sdk',
      '2-sdk',
      'stable-sdk',
      'sdk',
      '2.12.4',
      '2.12',
      '2',
      'stable',
      'latest',
    ]);
    expect(versions['beta']?.tags, [
      '2.13.0-211.6.beta-sdk',
      'beta-sdk',
      '2.13.0-211.6.beta',
      'beta',
    ]);
    expect(versions['stable']?.sha256, {
      'x64': 'abc',
      'arm': 'def',
      'arm64': 'ghi',
    });
    expect(versions['beta']?.sha256, {
      'x64': 'jmn',
      'arm': 'opq',
      'arm64': 'rst',
    });
  });

  test('update, no update', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/latest/VERSION':
          '{"version":"2.12.4"}',
    });
    var version = DartSdkVersion('stable', Version.parse('2.12.4'), {}, read);
    expect(await version.update(), false);
  });

  test('update, new version', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/latest/VERSION':
          '{"version":"3.13.2"}',
      '/dart-archive/channels/stable/release/3.13.2/sdk/dartsdk-linux-x64-release.zip.sha256sum':
          'abc *dartsdk-linux-x64-release.zip',
      '/dart-archive/channels/stable/release/3.13.2/sdk/dartsdk-linux-arm-release.zip.sha256sum':
          'def *dartsdk-linux-arm-release.zip',
      '/dart-archive/channels/stable/release/3.13.2/sdk/dartsdk-linux-arm64-release.zip.sha256sum':
          'ghi *dartsdk-linux-arm64-release.zip',
    });
    var version = DartSdkVersion('stable', Version.parse('2.12.4'), {}, read);
    expect(await version.update(), true);
    expect(
      version,
      DartSdkVersion('stable', Version.parse('3.13.2'), {
        'x64': 'abc',
        'arm': 'def',
        'arm64': 'ghi',
      }, fakeRead),
    );
  });

  test('verify version succeeds', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-x64-release.zip.sha256sum':
          'x64-sha *dartsdk-linux-x64-release.zip',
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-arm-release.zip.sha256sum':
          'arm-sha *dartsdk-linux-arm-release.zip',
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-arm64-release.zip.sha256sum':
          'arm64-sha *dartsdk-linux-arm64-release.zip',
    });
    var sha256 = {'x64': 'x64-sha', 'arm': 'arm-sha', 'arm64': 'arm64-sha'};
    var version = DartSdkVersion(
      'stable',
      Version.parse('2.12.4'),
      sha256,
      read,
    );
    await version.verify();
  });

  test('verify version fails', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-x64-release.zip.sha256sum':
          'x64-sha *dartsdk-linux-x64-release.zip',
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-arm-release.zip.sha256sum':
          'arm-sha *dartsdk-linux-arm-release.zip',
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-arm64-release.zip.sha256sum':
          'arm64-sha *dartsdk-linux-arm64-release.zip',
    });
    var sha256 = {'x64': 'wrong-sha', 'arm': 'wrong-sha', 'arm64': 'wrong-sha'};
    var version = DartSdkVersion(
      'stable',
      Version.parse('2.12.4'),
      sha256,
      read,
    );
    expect(() async => await version.verify(), throwsStateError);
  });
}
