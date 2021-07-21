import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'custom_text_selection_control.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BibleViewer(),
    );
  }
}

final String testStr =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";

class BibleViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
        child: ChangeNotifierProvider(
            create: (_) => HighlightableTextController(testStr, Colors.black),
            child: HighlightableText()),
      ),
    ));
  }
}

class Highlight {
  final String text;

  //inclusive
  final int start;

  //exclusive
  final int end;
  final Color color;

  const Highlight(this.text, this.start, this.end, this.color);

  @override
  String toString() {
    // TODO: implement toString
    return "start: $start end: $end color: $color";
  }
}

class HighlightableTextController extends ChangeNotifier {
  final String text;
  final Color defaultTextColor;
  List<Highlight> _sentences;

  List<Color> colors;

  HighlightableTextController(this.text, this.defaultTextColor) {
    _sentences = List();
    colors = List(text.length);
    colors.fillRange(0, colors.length, defaultTextColor);
  }

  void addHighlight(Highlight highlight) {
    _sentences.add(highlight);
    notifyListeners();
  }

  void removeHighlight(Highlight highlight) {
    _sentences.remove(highlight);
    notifyListeners();
  }

  List<Highlight> getSentences() {
    colors.fillRange(0, colors.length, defaultTextColor);
    for (var sentence in _sentences) {
      colors.fillRange(sentence.start, sentence.end, sentence.color);
    }
    _sentences.clear();

    Color oldValue = colors.first;
    int startIndex = 0;
    for (int i = 1; i < colors.length; ++i) {
      if (colors[i] != oldValue) {
        _sentences.add(Highlight(
            text.substring(startIndex, i), startIndex, i, colors[startIndex]));

        startIndex = i;
        oldValue = colors[startIndex];
      }
    }
    _sentences.add(Highlight(text.substring(startIndex, text.length),
        startIndex, text.length, defaultTextColor));

    return _sentences;
  }
}

class HighlightableText extends StatelessWidget {
  HighlightableTextController controller;

  @override
  Widget build(BuildContext context) {
    controller = context.watch();

    return SelectableText.rich(
        TextSpan(style: TextStyle(color: Colors.black), children: _buildText()),
        selectionControls:
            CustomTextSelectionControls(customButton: (start, end) {
      print("start: $start end: $end");
      print("len: ${testStr.length}");
      var colors = [Colors.red, Colors.green, Colors.amber];
      controller.addHighlight(
          Highlight("", start, end, colors[Random().nextInt(colors.length)]));
    }));
  }

  List<InlineSpan> _buildText() {
    return controller
        .getSentences()
        .map((sentence) => TextSpan(
            text: sentence.text,
            style: TextStyle(color: sentence.color),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                controller.removeHighlight(sentence);
              }))
        .toList();
  }
}
