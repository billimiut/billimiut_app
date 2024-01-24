import 'package:flutter/material.dart';

class AnimatedMarker extends StatelessWidget {
  final bool isMoving;
  const AnimatedMarker({Key? key, this.isMoving = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, isMoving ? -20 : 0, 0),
      child: AnimatedOpacity(
        opacity: this.isMoving ? 0.5 : 1,
        duration: Duration(milliseconds: 300),
        child: Icon(
          Icons.location_on,
          size: 50,
          color: Colors.red,
        ),
      ),
    );
  }
}
