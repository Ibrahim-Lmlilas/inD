import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CarLogo extends StatelessWidget {
  final double? width;
  final double? height;
  
  const CarLogo({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/City driver-amico 1.svg',
      width: width ?? 240,
      height: height ?? 240,
    );
  }
}