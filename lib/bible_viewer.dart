import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';

import 'custom_text_selection_control.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BibleViewer(),
    );
  }
}

final testStr =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";

class BibleViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
        child: ChangeNotifierProvider(
            create: (_) => HighlightableTextController(
                testStr, [Highlight(100, 110, Colors.red)]),
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
  final MaterialColor color;

  const Highlight(this.start, this.end, this.color);
}

class Sentence {
  final String text;
  final MaterialColor color;

  const Sentence(this.text, {this.color});
}

class HighlightableTextController extends ChangeNotifier {
  final String text;

  final List<Highlight> _highlights;

  HighlightableTextController(this.text, this._highlights);

  void addHighlight(Highlight highlight) {
    _highlights.add(highlight);
    _highlights.sort((a, b) {
      return a.start.compareTo(b.start);
    });
    notifyListeners();
  }

  List<Sentence> getSentences() {
    List<Sentence> result = List();
    result.add(Sentence(text.substring(0, _highlights.first.start)));
    for (int i = 0; i < _highlights.length; i++) {
      result.add(Sentence(
          text.substring(_highlights[i].start, _highlights[i].end),
          color: _highlights[i].color));

      if (i + 1 >= _highlights.length) break;

      result.add(Sentence(
          text.substring(_highlights[i].end, _highlights[i + 1].start)));
    }
    result.add(Sentence(text.substring(_highlights.last.end, text.length)));
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
      controller.addHighlight(Highlight(start, end, Colors.red));
    }));
  }

  List<InlineSpan> _buildText() {
    return controller
        .getSentences()
        .map((e) => TextSpan(text: e.text, style: TextStyle(color: e.color)))
        .toList();
  }
}
