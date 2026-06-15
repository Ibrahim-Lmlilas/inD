// features/ride_tracking/utils/color_utils.dart

import 'package:flutter/material.dart';

class ColorUtils {
  static Color getColorFromName(String colorName) {
    final lowerName = colorName.toLowerCase();

    if (lowerName.contains('blanc') || lowerName.contains('white')) {
      return Colors.white;
    } else if (lowerName.contains('noir') || lowerName.contains('black')) {
      return Colors.black;
    } else if (lowerName.contains('rouge') || lowerName.contains('red')) {
      return Colors.red;
    } else if (lowerName.contains('bleu') || lowerName.contains('blue')) {
      return Colors.blue;
    } else if (lowerName.contains('vert') || lowerName.contains('green')) {
      return Colors.green;
    } else if (lowerName.contains('jaune') || lowerName.contains('yellow')) {
      return Colors.yellow;
    } else if (lowerName.contains('gris') ||
        lowerName.contains('grey') ||
        lowerName.contains('gray')) {
      return Colors.grey;
    } else if (lowerName.contains('marron') || lowerName.contains('brown')) {
      return Colors.brown;
    } else if (lowerName.contains('argent') || lowerName.contains('silver')) {
      return Colors.grey.shade300;
    } else {
      return Colors.grey.shade400;
    }
  }
}
