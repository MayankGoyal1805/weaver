import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';

class SilkSpinner extends StatelessWidget {
  final double size;

  const SilkSpinner({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: WeaverColors.accent,
        backgroundColor: WeaverColors.cardBorder,
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  final String agentName;

  const TypingIndicator({super.key, required this.agentName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: WeaverColors.accentGlow,
            shape: BoxShape.circle,
            border: Border.all(color: WeaverColors.accent.withOpacity(0.4)),
          ),
          child: const Center(
            child: Text('W', style: TextStyle(color: WeaverColors.accent, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: WeaverColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WeaverColors.cardBorder),
          ),
          child: Row(
            children: [
              Text('$agentName is thinking', style: const TextStyle(color: WeaverColors.textMuted, fontSize: 13)),
              const SizedBox(width: 8),
              Row(
                children: List.generate(3, (i) => Container(
                  margin: const EdgeInsets.only(right: 3),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: WeaverColors.accent,
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (c) => c.repeat()).fadeIn(
                  duration: 400.ms,
                  delay: (i * 150).ms,
                ).then().fadeOut(duration: 400.ms)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;

  const AnimatedGradientBorder({super.key, required this.child, this.borderRadius = 12});

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: SweepGradient(
            colors: const [
              WeaverColors.accent,
              WeaverColors.accentDim,
              WeaverColors.accent,
            ],
            startAngle: _controller.value * 6.28,
            endAngle: _controller.value * 6.28 + 6.28,
          ),
        ),
        padding: const EdgeInsets.all(1.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius - 1.5),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

// Weaver spider logo
class WeaverLogo extends StatelessWidget {
  final double size;
  final bool showLabel;

  const WeaverLogo({super.key, this.size = 36, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              colors: [WeaverColors.accentDim, Color(0xFF0A0B0F)],
              center: Alignment.center,
              radius: 0.8,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: WeaverColors.accent.withOpacity(0.5)),
          ),
          child: Center(
            child: Text('⟆', style: TextStyle(fontSize: size * 0.55, color: WeaverColors.accent)),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 10),
          Text(
            'Weaver',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w700,
              color: WeaverColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
