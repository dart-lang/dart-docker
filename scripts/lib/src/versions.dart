// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:file/file.dart';
import 'package:pub_semver/pub_semver.dart';

import 'http.dart';

Map<String, DartSdkVersion> versionsFromFile(
    FileSystem fileSystem, HttpRead read) {
  var json = jsonDecode(fileSystem.file('versions.json').readAsStringSync());
  return versionsFromJson(json, read);
}

Map<String, DartSdkVersion> versionsFromJson(
    Map<String, dynamic> json, HttpRead read) {
  var stable = DartSdkVersion.fromJson('stable', json['stable']!, read);
  var beta = DartSdkVersion.fromJson('beta', json['beta']!, read);
  return {'stable': stable, 'beta': beta};
}

void writeVersionsFile(FileSystem fileSystem, List<DartSdkVersion> versions) {
  fileSystem
      .file('versions.json')
      .writeAsStringSync(JsonEncoder.withIndent('    ').convert({
        for (var version in versions)
          version.channel: {
            'version': version.version.toString(),
            'sha256': version.sha256,
          }
      }));
}

class DartSdkVersion {
  static final baseUri =
      Uri.https('storage.googleapis.com', 'dart-archive/channels/');

  final String channel;
  Version version;
  Map<String, String> sha256;
  final HttpRead _read;

  DartSdkVersion(this.channel, this.version, this.sha256, this._read);

  factory DartSdkVersion.fromJson(
      String channel, Map<String, dynamic> json, HttpRead read) {
    var version = Version.parse(json['version']!);
    var sha256 = (json['sha256']! as Map).cast<String, String>();
    return DartSdkVersion(channel, version, sha256, read);
  }

  Iterable<String> get tags {
    if (channel == 'stable') {
      var major = version.major;
      var minor = version.minor;
      return [
        '$version-sdk',
        '$major.$minor-sdk',
        '$major-sdk',
        'stable-sdk',
        'sdk',
        '$version',
        '$major.$minor',
        '$major',
        'stable',
        'latest'
      ];
    }
    if (channel == 'beta') {
      return ['$version-sdk', 'beta-sdk', '$version', 'beta'];
    }
    throw StateError("Unsupported channel '$channel'");
  }

  @override
  String toString() {
    return '$version $channel $sha256';
  }

  Future<void> verify() async {
    var remoteSha256 = await _readSha256(version);
    if (!MapEquality().equals(sha256, remoteSha256)) {
      throw StateError("Expected SHA256 '$sha256' but got '$remoteSha256'");
    }
  }

  Future<bool> update() async {
    var latest = await _readLatestVersion();
    if (version == latest) {
      return false;
    }
    sha256 = await _readSha256(latest);
    version = latest;
    return true;
  }

  Future<Map<String, String>> _readSha256(Version version) async {
    var sha256 = <String, String>{};
    for (var arch in ['x64', 'arm', 'arm64']) {
      var sdk = 'dartsdk-linux-$arch-release.zip';
      var sha256Url =
          baseUri.resolve('$channel/release/$version/sdk/$sdk.sha256sum');
      var sha256sum = await _read(sha256Url);
      if (!sha256sum.trim().endsWith(sdk)) {
        throw StateError("Expected file name $sdk in sha256sum:\n$sha256sum");
      }
      sha256[arch] = sha256sum.split(' ').first;
    }
    return sha256;
  }

  Future<Version> _readLatestVersion() async {
    var versionUrl = baseUri.resolve('$channel/release/latest/VERSION');
    var versionJson = jsonDecode(await _read(versionUrl));
    return Version.parse(versionJson['version']);
  }

  bool operator ==(Object other) {
    return other is DartSdkVersion &&
        other.channel == channel &&
        other.version == version &&
        MapEquality().equals(other.sha256, sha256);
  }

  @override
  int get hashCode {
    return channel.hashCode ^ version.hashCode ^ MapEquality().hash(sha256);
  }
}
