import 'package:flutter/material.dart';

/// The official AYA emblem (Sree Aradhana Youth Association, Chennai), shown
/// inside a white circle so it reads cleanly on both light and dark surfaces.
class AyaLogo extends StatelessWidget {
  const AyaLogo({super.key, this.size = 72, this.onDark = true});

  final double size;
  final bool onDark; // stronger shadow when placed on a dark/coloured surface

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(onDark ? 0.20 : 0.08),
            blurRadius: onDark ? 18 : 12,
            offset: Offset(0, onDark ? 8 : 4),
          ),
        ],
      ),
      child: const ClipOval(
        child: Image(
          image: AssetImage('assets/images/aya_logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
