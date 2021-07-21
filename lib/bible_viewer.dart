import 'package:flutter/cupertino.dart';
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
  //inclusive
  final int start;

  //exclusive
  final int end;
  final Color color;

  const Highlight(this.start, this.end, this.color);

  factory Highlight.empty() {
    return Highlight(0, 0, Colors.black);
  }

  bool isEmpty() {
    return start == 0 && end == 0 && color == Colors.black;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "start: $start end: $end color: $color";
  }
}

class Sentence {
  final String text;
  final Color color;

  const Sentence(this.text, {this.color});
}

class HighlightableTextController extends ChangeNotifier {
  final String text;
  final Color defaultTextColor;
  List<Highlight> _highlights;

  List<Color> colors;

  HighlightableTextController(this.text, this.defaultTextColor) {
    _highlights = List();
    colors = List(text.length);
    colors.fillRange(0, colors.length, defaultTextColor);
  }

  void addHighlight(Highlight highlight) {
    _highlights.add(highlight);
    notifyListeners();
  }

  List<Sentence> getSentences() {
    for (var highlight in _highlights) {
      colors.fillRange(
          highlight.start, highlight.end, highlight.color); //알파블렌드 해야
    }
    List<Sentence> result = List();
    Color oldValue = colors.first;
    int startIndex = 0;
    for (int i = 1; i < colors.length; ++i) {
      if (colors[i] != oldValue) {
        result.add(
            Sentence(text.substring(startIndex, i), color: colors[startIndex]));
        startIndex = i;
        oldValue = colors[startIndex];
      }
    }
    result.add(Sentence(text.substring(startIndex, text.length),
        color: defaultTextColor));

    return result;
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
          Highlight(start, end, colors[Random().nextInt(colors.length)]));
    }));
  }

  List<InlineSpan> _buildText() {
    return controller
        .getSentences()
        .map((e) => TextSpan(text: e.text, style: TextStyle(color: e.color)))
        .toList();
  }
}
