# Source Code Guide: `lib/theme/app_theme.dart`

This file defines the visual identity of the Weaver application. It uses Flutter's `ThemeData` to centralize all styling—colors, fonts, button shapes, and input decorations.

---

## The WeaverTheme Class

Weaver uses a **Dark Mode** first design. The theme is built on top of `Material 3` to leverage modern UI components and behaviors.

### 1. Color Palette (Lines 11-21)
The theme uses a custom `ColorScheme` defined in `colors.dart`.
- `primary`: Used for main buttons and active states.
- `surface`: Used for card backgrounds and sidebars.
- `background`: The deep dark base of the application.

### 2. Typography (Lines 22-40)
Weaver uses the **Inter** font via `GoogleFonts`.
- The `textTheme` maps standard Material titles (e.g., `headlineLarge`, `bodyMedium`) to the Inter font with consistent colors and weights.
- This ensures that every text element in the app follows a strict hierarchy.

### 3. Component Styling

#### Cards (Lines 41-49)
- Defines a rounded border (`borderRadius: 12`) and a subtle border color.
- Sets `elevation: 0` to achieve the modern, "flat" glassmorphism look instead of traditional shadows.

#### Inputs (Lines 54-71)
- Customizes `TextField` appearance globally.
- Features a colored border that glows when the field is focused (`focusedBorder`).
- Sets consistent padding for all text inputs.

#### Buttons (Lines 72-89)
- Both `ElevatedButton` and `OutlinedButton` are styled with rounded corners (`10px`) and specific padding to match the high-fidelity design.

---

## Why use a Global Theme?

Instead of styling every widget individually, a global theme allows you to:
1.  **Change everything at once**: Want to change the accent color from blue to purple? Just change it in the theme, and every button in the app updates instantly.
2.  **Consistency**: Ensures that a "medium title" on the Settings page looks identical to a "medium title" on the Chat page.
3.  **Performance**: Flutter's rendering engine is optimized for widgets that inherit their styles from a central `Theme` object.

---

## Key References
- [Flutter Material 3](https://m3.material.io/)
- [Google Fonts for Flutter](https://pub.dev/packages/google_fonts)
- [Flutter ThemeData class](https://api.flutter.dev/flutter/material/ThemeData-class.html)
