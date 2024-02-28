import 'package:flutter/material.dart';

class AnimatedMarker extends StatelessWidget {
  final bool isMoving;
  const AnimatedMarker({super.key, this.isMoving = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, isMoving ? -20 : 0, 0),
      child: AnimatedOpacity(
        opacity: isMoving ? 0.5 : 1,
        duration: const Duration(milliseconds: 300),
        child: const Icon(
          Icons.location_on,
          size: 50,
          color: Colors.red,
        ),
      ),
    );
  }
}
