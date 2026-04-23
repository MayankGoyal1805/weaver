# Source Code Guide: `lib/widgets/common/animated_widgets.dart`

This file contains the **Micro-Animations** that make Weaver feel smooth and reactive. These widgets are small, reusable building blocks that use the `flutter_animate` package to create high-quality motion effects with very little code.

---

## 1. Complete Code (Highlights)

```dart
class TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Agent Avatar
        _buildAvatar(),
        
        // 2. Animated Dots
        Row(
          children: List.generate(3, (i) => Container(
            width: 5, height: 5,
            decoration: BoxDecoration(color: WeaverColors.accent, shape: BoxShape.circle),
          ).animate(onPlay: (c) => c.repeat()).fadeIn(
            duration: 400.ms,
            delay: (i * 150).ms,
          ).then().fadeOut(duration: 400.ms)),
        ),
      ],
    );
  }
}

class AnimatedGradientBorder extends StatefulWidget {
  // 3. A rotating border effect
}
```

---

## 2. Line-by-Line Deep Dive

### The Typing Indicator

- **Lines 57-70**: The "Bouncing" Dots.
  - **`List.generate(3, ...)`**: Creates three identical dot widgets.
  - **`animate(onPlay: (c) => c.repeat())`**: Tells the animation to loop forever.
  - **`delay: (i * 150).ms`**: This is the "Wave" effect. The first dot starts at 0ms, the second at 150ms, and the third at 300ms. This creates a staggered sequence.
  - **`.then().fadeOut(...)`**: The `.then()` operator chains animations together. "First fade in, *then* fade out."

### Animated Gradient Border (Advanced)

- **Line 79**: `AnimatedGradientBorder`
  - This widget uses a `SweepGradient` that rotates around a child widget.
  - **`SingleTickerProviderStateMixin`**: This is a mixin that provides a "Ticker." A ticker is like a heartbeat for animations, firing 60 times per second to keep motion smooth.
  - **`_controller.repeat()`**: The animation never stops, creating a continuous "Spinning" border effect that makes a card look like it's active or processing.

### The Weaver Logo

- **Lines 135-175**: `WeaverLogo`
  - This is a branding widget.
  - **`RadialGradient`**: Creates a soft glow behind the logo emoji (`⟆`).
  - **`showLabel`**: A boolean flag. Sometimes we want just the icon (like in a small sidebar), and sometimes we want the full "Weaver" text.

---

## 3. Educational Callouts

> [!TIP]
> **What is `flutter_animate`?**
> Instead of writing 50 lines of `AnimationController` and `Tween` code, `flutter_animate` allows you to "Chain" effects: `.fadeIn().scale().move()`. It makes complex animations as easy as writing a single sentence.

---

## Key References
- [Flutter Animate Package Docs](https://pub.dev/packages/flutter_animate)
- [Flutter: AnimationController](https://api.flutter.dev/flutter/animation/AnimationController-class.html)
- [Design: The Importance of Micro-interactions](https://www.nngroup.com/articles/microinteractions/)
