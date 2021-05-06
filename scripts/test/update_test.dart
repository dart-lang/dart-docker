// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/memory.dart';
import 'package:scripts/src/versions.dart';
import 'package:test/test.dart';

import '../bin/update.dart' as update;
import 'utils.dart';

void main() {
  test('update succeeds, no updates', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/latest/VERSION':
          '{"version":"2.12.4"}',
      '/dart-archive/channels/beta/release/latest/VERSION':
          '{"version":"2.13.0-211.14.beta"}',
    });

    var fileSystem = TestFileSystem.build({
      'versions.json': versions,
    });
    await update.update(fileSystem.fileSystem, read);

    expect(fileSystem.contexts, ['versions.json']);
    expect(fileSystem.operations, [FileSystemOp.read]);
  });

  test('update succeedes, dockerfile updated', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/latest/VERSION':
          '{"version":"2.12.4"}',
      '/dart-archive/channels/beta/release/latest/VERSION':
          '{"version":"2.14.0-16.1.beta"}',
      '/dart-archive/channels/beta/release/2.14.0-16.1.beta/sdk/dartsdk-linux-x64-release.zip.sha256sum':
          'abc *${DartSdkVersion.sdk}',
    });
    var fileSystem = TestFileSystem.build({
      'versions.json': versions,
      'Dockerfile-debian.template': dockerfileTemplate,
      'beta/buster/Dockerfile': '',
    });

    await update.update(fileSystem.fileSystem, read);

    expect(fileSystem.contexts, [
      'versions.json',
      'Dockerfile-debian.template',
      'versions.json',
      'beta/buster/Dockerfile',
    ]);
    expect(fileSystem.operations, [
      FileSystemOp.read,
      FileSystemOp.read,
      FileSystemOp.write,
      FileSystemOp.write,
    ]);
    const expected = '''
ENV PLATFORM       linux
ENV ARCH           x64
ENV CHANNEL        beta
ENV DART_VERSION   2.14.0-16.1.beta
ENV DART_SHA256    abc
''';
    expect(
        fileSystem.fileSystem.file('beta/buster/Dockerfile').readAsStringSync(),
        expected);
  });
}
