import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final int maxLines;
  final TextAlign align;
  final double? height;
  final double? letterSpacing;
  final bool softWrap;
    final TextOverflow overflow;

  const CustomText({
    super.key,
    required this.text,
    this.size = 14,
    this.weight = FontWeight.w400,
    this.color = Colors.black,
    this.maxLines = 2,
    this.align = TextAlign.start,
    this.height,
    this.letterSpacing,
    this.softWrap = true,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      softWrap: softWrap,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
