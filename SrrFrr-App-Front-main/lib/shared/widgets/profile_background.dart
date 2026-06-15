import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileBg extends StatelessWidget {
  final double? width;
  final double? height;
  
  const ProfileBg({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/user_icon.svg',
      width: width ?? 240,
      height: height ?? 240,
    );
  }
}