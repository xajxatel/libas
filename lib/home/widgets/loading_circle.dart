import 'package:flutter/material.dart';

class LoadingCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const LoadingCircle({
    super.key,
    this.size = 25.0, // Default size
    this.color = Colors.grey, // Default color
    this.strokeWidth = 2.0, // Default stroke width
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: Colors.grey.shade700, // Dark grey color (shade 700)
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
