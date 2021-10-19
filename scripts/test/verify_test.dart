// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/file.dart';
import 'package:test/test.dart';

import '../bin/verify.dart' as verify;
import 'utils.dart';

void main() {
  late FileSystem fileSystem;

  setUp(() {
    fileSystem = TestFileSystem.build({'versions.json': versions}).fileSystem;
  });

  test('verify succeeds', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-x64-release.zip.sha256sum':
          'abc *dartsdk-linux-x64-release.zip',
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-arm-release.zip.sha256sum':
          'def *dartsdk-linux-arm-release.zip',
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-arm64-release.zip.sha256sum':
          'ghi *dartsdk-linux-arm64-release.zip',
      '/dart-archive/channels/beta/release/2.13.0-211.14.beta/sdk/dartsdk-linux-x64-release.zip.sha256sum':
          'jmn *dartsdk-linux-x64-release.zip',
      '/dart-archive/channels/beta/release/2.13.0-211.14.beta/sdk/dartsdk-linux-arm-release.zip.sha256sum':
          'opq *dartsdk-linux-arm-release.zip',
      '/dart-archive/channels/beta/release/2.13.0-211.14.beta/sdk/dartsdk-linux-arm64-release.zip.sha256sum':
          'rst *dartsdk-linux-arm64-release.zip',
    });

    await verify.verify(fileSystem, read);
  });

  test('verify fails', () {
    var read = mockRead({
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-x64-release.zip.sha256sum':
          'abc *dartsdk-linux-x64-release.zip',
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-arm-release.zip.sha256sum':
          'def *dartsdk-linux-arm-release.zip',
      '/dart-archive/channels/stable/release/2.12.4/sdk/dartsdk-linux-arm64-release.zip.sha256sum':
          'ghi *dartsdk-linux-arm64-release.zip',
      '/dart-archive/channels/beta/release/2.13.0-211.14.beta/sdk/dartsdk-linux-x64-release.zip.sha256sum':
          'jmn *dartsdk-linux-x64-release.zip',
      '/dart-archive/channels/beta/release/2.13.0-211.14.beta/sdk/dartsdk-linux-arm-release.zip.sha256sum':
          'wrong-sha *dartsdk-linux-arm-release.zip',
      '/dart-archive/channels/beta/release/2.13.0-211.14.beta/sdk/dartsdk-linux-arm64-release.zip.sha256sum':
          'rst *dartsdk-linux-arm64-release.zip',
    });

    expect(() async => await verify.verify(fileSystem, read), throwsStateError);
  });
}
