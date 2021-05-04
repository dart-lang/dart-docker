// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:scripts/src/versions.dart';
import 'package:test/test.dart';

void main() {
  test('test Versions.fromJson', () {
    var versions = Versions.fromJson(<String, dynamic>{
      'stable': '2.12.4',
      'beta': '2.13.0-211.6.beta',
    });

    expect(versions.stable, Version.parse('2.12.4'));
    expect(versions.beta, Version.parse('2.13.0-211.6.beta'));
    expect(versions.stableTags,
        '2.12.4-sdk, 2.12-sdk, 2-sdk, stable-sdk, sdk, 2.12.4, 2.12, 2, stable, latest');
    expect(versions.betaTags,
        '2.13.0-211.6.beta-sdk, beta-sdk, 2.13.0-211.6.beta, beta');
  });
}
