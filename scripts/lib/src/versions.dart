// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

/// The [Versions], usually parsed from a `versions.json` and their tags used in
/// Dart's official docker library.
class Versions {
  /// The semantic [Version] of Dart in the stable docker image.
  Version stable;
  /// The semantic [Version] of Dart in the beta docker image.
  Version beta;
  /// The tags for the stable docker image.
  String stableTags;
  /// The tags for the beta docker image.
  String betaTags;

  Versions(this.stable, this.beta, this.stableTags, this.betaTags);

  factory Versions.fromJson(Map<String, dynamic> json) {
    var beta = Version.parse(json['beta']!);
    var stable = Version.parse(json['stable']!);
    var betaTags = '$beta-sdk, beta-sdk, $beta, beta';
    var major = stable.major;
    var minor = stable.minor;
    var stableTags =
        '$stable-sdk, $major.$minor-sdk, $major-sdk, stable-sdk, sdk, $stable, '
        '$major.$minor, $major, stable, latest';
    return Versions(stable, beta, stableTags, betaTags);
  }
}
