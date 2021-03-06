// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file/file.dart';
import 'package:flutter_tools/src/base/file_system.dart';
import 'package:flutter_tools/src/base/platform.dart';

import '../src/common.dart';
import 'test_data/basic_project.dart';
import 'test_driver.dart';

/// This duration is arbitrary but is ideally:
/// a) long enough to ensure that if the app is crashing at startup, we notice
/// b) as short as possible, to avoid inflating build times
const Duration requiredLifespan = Duration(seconds: 5);

void main() {
  group('flutter run', () {
    final BasicProject _project = new BasicProject();
    FlutterTestDriver _flutter;
    Directory tempDir;

    setUp(() async {
      tempDir = fs.systemTempDirectory.createTempSync('flutter_lifetime_test.');
      await _project.setUpIn(tempDir);
      _flutter = new FlutterTestDriver(tempDir);
    });

    tearDown(() async {
      await _flutter.stop();
      tryToDelete(tempDir);
    });

    test('does not terminate when a debugger is attached', () async {
      await _flutter.run(withDebugger: true);
      await new Future<void>.delayed(requiredLifespan);
      expect(_flutter.hasExited, equals(false));
    });

    test('does not terminate when a debugger is attached and pause-on-exceptions', () async {
      await _flutter.run(withDebugger: true, pauseOnExceptions: true);
      await new Future<void>.delayed(requiredLifespan);
      expect(_flutter.hasExited, equals(false));
    });
    // TODO(dantup): Unskip after flutter-tester is fixed on Windows:
    // https://github.com/flutter/flutter/issues/17833.
  }, timeout: const Timeout.factor(6), skip: platform.isWindows);
}
