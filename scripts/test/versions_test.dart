// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:scripts/src/versions.dart';
import 'package:test/test.dart';

import 'utils.dart';

final stable =
    DartSdkVersion('stable', Version.parse('2.12.4'), 'abc', fakeRead);
final beta =
    DartSdkVersion('beta', Version.parse('2.13.0-211.6.beta'), 'def', fakeRead);

void main() {
  test('fromJson', () {
    var versions = versionsFromJson(<String, dynamic>{
      'stable': {
        'version': '2.12.4',
        'sha256': 'abc',
      },
      'beta': {
        'version': '2.13.0-211.6.beta',
        'sha256': 'def',
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
      'latest'
    ]);
    expect(versions['beta']?.tags,
        ['2.13.0-211.6.beta-sdk', 'beta-sdk', '2.13.0-211.6.beta', 'beta']);
  });

  test('update, no update', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/latest/VERSION':
          '{"version":"2.12.4"}',
    });
    var version =
        DartSdkVersion('stable', Version.parse('2.12.4'), '2.12.4-sha', read);
    expect(await version.update(), false);
  });

  test('update, new version', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/latest/VERSION':
          '{"version":"3.13.2"}',
      '/dart-archive/channels/stable/release/3.13.2/sdk/dartsdk-linux-x64-release.zip.sha256sum':
          'abc *${DartSdkVersion.sdk}',
    });
    var version =
        DartSdkVersion('stable', Version.parse('2.12.4'), '2.12.4-sha', read);
    expect(await version.update(), true);
    expect(version,
        DartSdkVersion('stable', Version.parse('3.13.2'), 'abc', fakeRead));
  });

  test('verify version succeeds', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-x64-release.zip.sha256sum':
          '2.12.4-sha *dartsdk-linux-x64-release.zip',
    });
    var version =
        DartSdkVersion('stable', Version.parse('2.12.4'), '2.12.4-sha', read);
    await version.verify();
  });

  test('verify version fails', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-x64-release.zip.sha256sum':
          '2.12.4-sha *dartsdk-linux-x64-release.zip',
    });
    var version =
        DartSdkVersion('stable', Version.parse('2.12.4'), 'wrong-sha', read);
    expect(() async => await version.verify(), throwsStateError);
  });
}
