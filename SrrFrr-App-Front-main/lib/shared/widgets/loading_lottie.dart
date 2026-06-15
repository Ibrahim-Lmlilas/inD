/// Loading Lottie Animation Widget
/// 
/// Displays a Lottie animation while searching for drivers.
/// Place your Lottie JSON file in assets/animations/loading.json

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// In loading_lottie.dart
class LoadingLottie extends StatefulWidget {
  const LoadingLottie({super.key});

  @override
  State<LoadingLottie> createState() => _LoadingLottieState();
}

class _LoadingLottieState extends State<LoadingLottie> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/loading_drivers.json',
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        _controller.repeat();
      },
    );
  }
}