import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum FontSize {
  extraSmall(10),
  small(12),
  normal(14),
  mediumSmall(16),
  medium(21),
  large(25),
  xLarge(30),
  xxLarge(50),
  xxxLarge(70);

  final double size;

  const FontSize(this.size);
}

class MyTextStyle {
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final TextDecoration? decoration;
  final TextDecorationStyle? decorationStyle;
  final Color? decorationColor;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final List<Shadow>? shadows;

  MyTextStyle({
    this.fontWeight,
    this.color,
    this.textAlign,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.fontStyle,
    this.shadows,
    this.letterSpacing,
  });
}

class AppText extends StatelessWidget {
  final String text;
  final MyTextStyle? style;
  final FontSize fontSize;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? fontStyle;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fontStyle,
    this.fontSize = FontSize.normal,
  });

  const AppText.extraSmall(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fontStyle,
  }) : fontSize = FontSize.extraSmall;

  const AppText.small(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fontStyle,
  }) : fontSize = FontSize.small;

  const AppText.normal(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fontStyle,
  }) : fontSize = FontSize.normal;

  const AppText.mediumSmall(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fontStyle,
  }) : fontSize = FontSize.mediumSmall;

  const AppText.medium(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fontStyle,
  }) : fontSize = FontSize.medium;

  const AppText.large(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fontStyle,
  }) : fontSize = FontSize.large;

  const AppText.xLarge(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fontStyle,
  }) : fontSize = FontSize.xLarge;

  const AppText.xxLarge(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fontStyle,
  }) : fontSize = FontSize.xxLarge;

  const AppText.xxxLarge(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fontStyle,
  }) : fontSize = FontSize.xxxLarge;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          fontStyle ??
          GoogleFonts.openSans(
            fontSize: fontSize.size,
            color: style?.color ?? Colors.white,
            fontWeight: style?.fontWeight,
            decorationColor: style?.decorationColor,
            decorationStyle: style?.decorationStyle,
            decoration: style?.decoration,
            fontStyle: style?.fontStyle,
            letterSpacing: style?.letterSpacing,
          ),
      textAlign: style?.textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
