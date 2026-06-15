import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo2 extends StatelessWidget {
  final double? width;
  final double? height;
  
  const AppLogo2({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/srr_frr_logo_2.svg',
      width: width ?? 120,
      height: height ?? 60,
    );
  }
}