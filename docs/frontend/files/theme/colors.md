# Source Code Guide: `lib/theme/colors.dart`

This file defines the **Visual Identity** of Weaver. Instead of using generic colors like `Colors.blue`, we use a custom palette inspired by modern high-authority software (like Linear or Raycast).

---

## 1. Complete Code

```dart
import 'package:flutter/material.dart';

class WeaverColors {
  // Private constructor
  WeaverColors._();

  // 1. Backgrounds & Surfaces
  static const background = Color(0xFF0A0B0F); // Deep Obsidian
  static const surface = Color(0xFF12141A);    // Dark Charcoal
  static const card = Color(0xFF1A1D26);
  static const cardBorder = Color(0xFF2A2F3D);

  // 2. The Signature Accent (Gold/Amber)
  static const accent = Color(0xFFC8973A);
  static const accentGlow = Color(0x33C8973A); // 20% opacity gold

  // 3. Semantic Colors (Success, Error, etc.)
  static const success = Color(0xFF3ABFA8);
  static const error = Color(0xFFE05252);
  static const info = Color(0xFF5B8DEF);

  // 4. Typography
  static const textPrimary = Color(0xFFEEF0F7);   // Off-white
  static const textSecondary = Color(0xFFB0B8CC); // Light Gray
  static const textMuted = Color(0xFF6B7280);    // Medium Gray
}
```

---

## 2. Line-by-Line Deep Dive

### Hex Color Format

- **Line 7**: `Color(0xFF0A0B0F)`
  - **What**: Flutter uses 8-digit Hex codes. 
  - **`0xFF`**: This is the **Alpha** (Opacity). `FF` means 100% opaque.
  - **`0A0B0F`**: This is the **Red, Green, Blue** (RGB) value.

### The "Obsidian" Palette

- **Background vs. Surface**: We use `0A0B0F` for the main background and a slightly lighter `12141A` for panels. This subtle difference creates "Depth" without using heavy shadows.

### Semantic Meaning

- **Line 36**: `cloudColor = Color(0xFF5B8DEF)`
  - Weaver assigns specific colors to **Tool Categories**. 
  - **Why**: When a user sees a blue icon in the chat, their brain instantly thinks "Cloud/Google Drive." When they see a green icon, they think "Files." This reduces cognitive load.

### Accent Glow

- **Line 16**: `Color(0x33C8973A)`
  - **What**: The `33` at the start means **20% Opacity**. 
  - **Usage**: We use this for "Hover States." When you mouse over a button, it doesn't just change color; it gets a soft amber glow behind it.

---

## 3. Educational Callouts

> [!TIP]
> **Why use a class with a private constructor?**
> `WeaverColors._();` prevents you from doing `var c = WeaverColors();`. You don't need an instance! You just use it as a static namespace: `WeaverColors.accent`.

---

## Key References
- [Flutter: Color class](https://api.flutter.dev/flutter/dart-ui/Color-class.html)
- [Design: Creating a Dark Mode Palette](https://material.io/design/color/dark-theme.html)
