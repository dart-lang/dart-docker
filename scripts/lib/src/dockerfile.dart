// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:scripts/src/versions.dart';

/// Generate the `Dockerfile` for the [version] using a [template].
String buildDockerfile(DartSdkVersion version, String template) {
  var variables = {
    'DART_CHANNEL': version.channel,
    'DART_VERSION': version.version.toString(),
    'DART_SHA256': version.sha256,
  };
  var dockerfile = template.splitMapJoin(RegExp(r'{{(.*)}}'), onMatch: (match) {
    var value = variables.remove(match[1]!);
    if (value == null) {
      throw StateError('Unknown template variable ${match[1]}');
    }
    return value;
  });
  if (variables.isNotEmpty) {
    throw ArgumentError.value(template, 'template', 'missing $variables');
  }
  return dockerfile;
}
