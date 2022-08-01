// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

void main() => defineTests();

Widget renderingHelper(String inputLine, String textToHighlight) {
  return boilerplate(MediaQuery(
    data: const MediaQueryData(),
    child: Theme(
      data: ThemeData(
          textSelectionTheme:
              const TextSelectionThemeData(selectionColor: Color(0x12345678))),
      child: MarkdownBody(
        selectable: true,
        data: inputLine,
        textToHighlight: [textToHighlight],
      ),
    ),
  ));
}

void verificationHelper(Iterable<Widget> widgets, String textToHighlight) {
  for (final Widget widget in widgets) {
    if (widget is SelectableText) {
      expect(widget.textSpan, isNotNull);
      final TextSpan rt = widget.textSpan!;
      expect(rt.children, isNotNull);
      expect(
          rt.children!
              .where((e) => e.style?.backgroundColor == const Color(0x12345678))
              .map((e) => e.toPlainText())
              .join(),
          equals(textToHighlight));
    }
  }
}

void defineTests() {
  group('TextHighlight', () {
    testWidgets('plain text partial prefix matching',
        (WidgetTester tester) async {
      const String inputLine = 'Hello world';
      const String textToHighlight = 'Hello';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('plain text partial suffix matching',
        (WidgetTester tester) async {
      const String inputLine = 'Hello world';
      const String textToHighlight = 'world';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('plain text partial middle matching',
        (WidgetTester tester) async {
      const String inputLine = 'Hello world, Flutter';
      const String textToHighlight = 'world';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('plain text full line matching', (WidgetTester tester) async {
      const String inputLine = 'Hello world';
      const String textToHighlight = 'Hello world';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('single styled span, matching non-styled part, prefix',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello* world';
      const String textToHighlight = 'I like';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('single styled span, matching non-styled part, middle',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello* world';
      const String textToHighlight = 'like';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('single styled span, matching non-styled part, suffix',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello* world';
      const String textToHighlight = 'world';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('single styled span, matching styled part, full',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello* world';
      const String textToHighlight = 'hello';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('single styled span, matching cross boundary, end of span',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello* world';
      const String textToHighlight = 'hello world';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('single styled span, matching cross boundary, start of span',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello* world';
      const String textToHighlight = 'like hello';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('single styled span, matching cross boundary, end, partial',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello* world';
      const String textToHighlight = 'llo wor';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('single styled span, matching cross boundary, start, partial',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello* world';
      const String textToHighlight = 'like hell';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, matching non-styled part, prefix',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'I like';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, matching non-styled part, middle',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'like';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, matching non-styled part, suffix',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = '!';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, matching non-styled part, between',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'in';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, matching styled part, full',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'hello world';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, matching styled part, prefix',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'hello';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, matching styled part, suffix',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'world';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, matching styled part, middle',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'llo wor';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, cross boundary, start',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'I like hello world';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, cross boundary, end',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'world in';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, cross boundary, start, partial',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'like hello';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, both spans, full',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'hello world in Dart';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, both spans, partial',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'lo world in Dar';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, both spans, full, beyond',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'like hello world in Dart!';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });

    testWidgets('multiple styled spans, full line matching',
        (WidgetTester tester) async {
      const String inputLine = 'I like *hello world* in *Dart*!';
      const String textToHighlight = 'I like hello world in Dart!';
      await tester.pumpWidget(renderingHelper(inputLine, textToHighlight));
      verificationHelper(tester.allWidgets, textToHighlight);
    });
  });
}
