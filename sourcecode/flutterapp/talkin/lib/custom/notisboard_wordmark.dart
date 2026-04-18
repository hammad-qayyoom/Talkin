import 'package:flutter/material.dart';
import 'package:notisboard/utils/app_color.dart';

class NotisboardWordmark extends StatelessWidget {
  const NotisboardWordmark({
    super.key,
    required this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.visible,
    this.word = 'Notisboard',
    this.baseColor,
    this.highlightColor,
  });

  final TextStyle style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final String word;
  final Color? baseColor;
  final Color? highlightColor;

  static TextSpan span({
    required TextStyle style,
    String word = 'Notisboard',
    Color? baseColor,
    Color? highlightColor,
  }) {
    final defaultColor = baseColor ?? const Color(0xFFFBD100);
    final specialColor = highlightColor ?? AppColors.black;
    final matches = RegExp(r'[oO]').allMatches(word).toList();
    final highlightedIndex = matches.length >= 2
        ? matches[1].start
        : (matches.isNotEmpty ? matches.first.start : -1);

    if (highlightedIndex == -1) {
      return TextSpan(
        text: word,
        style: style.copyWith(color: defaultColor),
      );
    }

    final before = word.substring(0, highlightedIndex);
    final highlighted = word.substring(highlightedIndex, highlightedIndex + 1);
    final after = word.substring(highlightedIndex + 1);

    return TextSpan(
      style: style.copyWith(color: defaultColor),
      children: [
        if (before.isNotEmpty) TextSpan(text: before),
        TextSpan(
          text: highlighted,
          style: style.copyWith(color: specialColor),
        ),
        if (after.isNotEmpty) TextSpan(text: after),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      text: span(
        style: style,
        word: word,
        baseColor: baseColor,
        highlightColor: highlightColor,
      ),
    );
  }
}
