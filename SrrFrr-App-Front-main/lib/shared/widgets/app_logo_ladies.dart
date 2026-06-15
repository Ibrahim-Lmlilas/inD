import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogoLadies extends StatelessWidget {
  final double? width;
  final double? height;
  
  const AppLogoLadies({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/srr_frr_logo_ladies.svg',
      width: width ?? 120,
      height: height ?? 60,
    );
  }
}