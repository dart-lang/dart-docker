// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:scripts/src/http.dart';

const versions = '''{
    "stable": {
        "version": "2.12.4",
        "sha256": {"x64": "abc", "arm": "def", "arm64": "ghi"}
    },
    "beta": {
        "version": "2.13.0-211.14.beta",
        "sha256": {"x64": "jmn", "arm": "opq", "arm64": "rst"}
    }
}''';
const dockerfileTemplate = '''
ENV DART_CHANNEL        {{DART_CHANNEL}}
ENV DART_VERSION        {{DART_VERSION}}
ENV DART_SHA256_X64     {{DART_SHA256_X64}}
ENV DART_SHA256_ARM     {{DART_SHA256_ARM}}
ENV DART_SHA256_ARM64   {{DART_SHA256_ARM64}}
''';

final fakeRead = (_, {headers}) => throw 'unimplemented';
HttpRead mockRead(Map<String, String> responses) {
  return (uri, {headers}) async {
    return responses.remove(uri.path) ?? (throw ArgumentError.value(uri.path));
  };
}

class TestFileSystem {
  final List<String> contexts;
  final List<FileSystemOp> operations;
  var isTesting = false;
  FileSystem fileSystem;

  TestFileSystem(this.fileSystem, this.contexts, this.operations);

  factory TestFileSystem.build(Map<String, String> files) {
    var contexts = <String>[];
    var operations = <FileSystemOp>[];
    var fileSystem = MemoryFileSystem(opHandle: (context, op) {
      contexts.add(context);
      operations.add(op);
    });
    for (var file in files.entries) {
      fileSystem.file(file.key)
        ..createSync(recursive: true)
        ..writeAsStringSync(file.value);
    }
    contexts.clear();
    operations.clear();
    return TestFileSystem(fileSystem, contexts, operations);
  }
}
