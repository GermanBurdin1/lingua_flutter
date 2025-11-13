import 'package:flutter/material.dart';
import 'dart:math' as math;

class CosmicBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const CosmicBackground({
    super.key,
    required this.child,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond dégradé
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0A0E27),
                      const Color(0xFF1A1F3A),
                      const Color(0xFF0A0E27),
                    ]
                  : [
                      const Color(0xFFF0F4FF),
                      const Color(0xFFE3F2FD),
                      const Color(0xFFF0F4FF),
                    ],
            ),
          ),
        ),
        // Étoiles
        ...List.generate(50, (index) {
          final random = math.Random(index);
          return Positioned(
            left: random.nextDouble() * 500,
            top: random.nextDouble() * 1000,
            child: Container(
              width: random.nextDouble() * 3 + 1,
              height: random.nextDouble() * 3 + 1,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(random.nextDouble() * 0.8)
                    : const Color(0xFF0066FF)
                        .withOpacity(random.nextDouble() * 0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFF00F5FF)
                            .withOpacity(random.nextDouble() * 0.5)
                        : const Color(0xFF0066FF)
                            .withOpacity(random.nextDouble() * 0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        }),
        // Contenu
        child,
      ],
    );
  }
}







