// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/memory.dart';
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
    await update.update(fileSystem.fileSystem, read, false);

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
          'x64-sha *dartsdk-linux-x64-release.zip',
      '/dart-archive/channels/beta/release/2.14.0-16.1.beta/sdk/dartsdk-linux-arm-release.zip.sha256sum':
          'arm-sha *dartsdk-linux-arm-release.zip',
      '/dart-archive/channels/beta/release/2.14.0-16.1.beta/sdk/dartsdk-linux-arm64-release.zip.sha256sum':
          'arm64-sha *dartsdk-linux-arm64-release.zip',
    });
    var fileSystem = TestFileSystem.build({
      'versions.json': versions,
      'Dockerfile-debian.template': dockerfileTemplate,
      'beta/bullseye/Dockerfile': '',
    });

    await update.update(fileSystem.fileSystem, read, false);

    expect(fileSystem.contexts, [
      'versions.json',
      'Dockerfile-debian.template',
      'versions.json',
      'beta/bullseye/Dockerfile',
    ]);
    expect(fileSystem.operations, [
      FileSystemOp.read,
      FileSystemOp.read,
      FileSystemOp.write,
      FileSystemOp.write,
    ]);
    const expected = '''
ENV DART_CHANNEL        beta
ENV DART_VERSION        2.14.0-16.1.beta
ENV DART_SHA256_X64     x64-sha
ENV DART_SHA256_ARM     arm-sha
ENV DART_SHA256_ARM64   arm64-sha
''';
    expect(
        fileSystem.fileSystem.file('beta/bullseye/Dockerfile').readAsStringSync(),
        expected);
  });

  test('update succeedes, dockerfile update forced', () async {
    var read = mockRead({
      '/dart-archive/channels/stable/release/latest/VERSION':
          '{"version":"2.12.4"}',
      '/dart-archive/channels/beta/release/latest/VERSION':
          '{"version":"2.13.0-211.14.beta"}',
    });

    var fileSystem = TestFileSystem.build({
      'versions.json': versions,
      'Dockerfile-debian.template': dockerfileTemplate,
      'stable/bullseye/Dockerfile': '''
ENV DART_CHANNEL        bugged
ENV DART_VERSION   weird
ENV DART_SHA256    off
''',
      'beta/bullseye/Dockerfile': '''
ENV DART_CHANNEL        outdated
ENV DART_VERSION   wrong
ENV DART_SHA256    incorrect
''',
    });

    await update.update(fileSystem.fileSystem, read, true);

    expect(fileSystem.contexts, [
      'versions.json',
      'Dockerfile-debian.template',
      'versions.json',
      'stable/bullseye/Dockerfile',
      'beta/bullseye/Dockerfile',
    ]);
    expect(fileSystem.operations, [
      FileSystemOp.read,
      FileSystemOp.read,
      FileSystemOp.write,
      FileSystemOp.write,
      FileSystemOp.write,
    ]);
    const expectedBeta = '''
ENV DART_CHANNEL        beta
ENV DART_VERSION        2.13.0-211.14.beta
ENV DART_SHA256_X64     jmn
ENV DART_SHA256_ARM     opq
ENV DART_SHA256_ARM64   rst
''';
    expect(
        fileSystem.fileSystem.file('beta/bullseye/Dockerfile').readAsStringSync(),
        expectedBeta);

    const expectedStable = '''
ENV DART_CHANNEL        stable
ENV DART_VERSION        2.12.4
ENV DART_SHA256_X64     abc
ENV DART_SHA256_ARM     def
ENV DART_SHA256_ARM64   ghi
''';
    expect(
        fileSystem.fileSystem
            .file('stable/bullseye/Dockerfile')
            .readAsStringSync(),
        expectedStable);
  });
}
