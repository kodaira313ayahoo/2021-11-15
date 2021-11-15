import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:highlight/highlight.dart' show highlight, Node;

const String LANG_MARKER = 'L@NG!';

class LangSyntaxHighlighter extends SyntaxHighlighter {
  LangSyntaxHighlighter({this.theme});
  final String? language = 'dart'; // どこにも使われていないような気が。。
  final Map<String, TextStyle>? theme; // User's code theme
  final String _rootKey = 'root';
  final String _defaultLang = 'dart';
  final String _defaultFontFamily = 'monospace';
  final Color _defaultFontColor = Color(0xfffdfeff);

  @override
  TextSpan format(String source) {
    String? lang;
    if (source.startsWith(LANG_MARKER)) {
      int idx = source.indexOf(LANG_MARKER, LANG_MARKER.length);
      lang = source.substring(LANG_MARKER.length, idx);
      source = source.substring(idx + LANG_MARKER.length);
    }
    TextStyle _textStyle = TextStyle(
      fontFamily: _defaultFontFamily,
      color: theme?[this._rootKey]?.color ?? _defaultFontColor,
    );
    return TextSpan(
      style: _textStyle,
      children: _convert(
        highlight
            .parse(
              source,
              autoDetection: true,
              language: lang ?? _defaultLang,
            )
            .nodes,
      ),
    );
  }

  List<TextSpan> _convert(List<Node>? nodes) {
    List<TextSpan> spans = [];
    var currentSpans = spans;
    List<List<TextSpan>> stack = [];

    final Map<String, TextStyle> _theme = theme ?? {}; // User's code theme

    if (nodes == null) {
      return spans;
    }

    _traverse(Node node) {
      if (node.value != null) {
        currentSpans.add(node.className == null
            ? TextSpan(text: node.value)
            : TextSpan(text: node.value, style: _theme[node.className]));
      } else if (node.children != null) {
        List<TextSpan> tmp = [];
        currentSpans
            .add(TextSpan(children: tmp, style: _theme[node.className]));
        stack.add(currentSpans);
        currentSpans = tmp;

        node.children!.forEach((n) {
          _traverse(n);
          if (n == node.children!.last)
            currentSpans = stack.isEmpty ? spans : stack.removeLast();
        });
      }
    }

    for (var node in nodes) _traverse(node);
    return spans;
  }
}
