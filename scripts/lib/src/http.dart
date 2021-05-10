// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:http/http.dart';
import 'package:http/retry.dart';

typedef HttpRead = Future<String> Function(Uri url,
    {Map<String, String>? headers});

Future<String> read(Uri url, {Map<String, String>? headers}) async {
  final client = RetryClient(Client());
  try {
    return await client.read(url, headers: headers);
  } finally {
    client.close();
  }
}
