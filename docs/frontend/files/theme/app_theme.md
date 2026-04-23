# Source Code Guide: `lib/theme/app_theme.dart`

Styling in Flutter is centralized in the `ThemeData` object. Instead of writing CSS for every component, we define global rules for colors, fonts, and shapes. This ensures Weaver looks consistent and premium.

Weaver uses a high-fidelity **Dark Mode** design.

---

## 1. Complete Code

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class WeaverTheme {
  // 1. Private constructor to prevent instantiation
  WeaverTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: WeaverColors.background,
      
      // 2. Global Color Palette
      colorScheme: const ColorScheme.dark(
        primary: WeaverColors.accent,
        secondary: WeaverColors.success,
        surface: WeaverColors.surface,
        error: WeaverColors.error,
        onPrimary: WeaverColors.background,
        onSurface: WeaverColors.textPrimary,
      ),

      // 3. Typography
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          titleLarge: TextStyle(color: WeaverColors.textPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: WeaverColors.textPrimary),
          bodyMedium: TextStyle(color: WeaverColors.textSecondary),
        ),
      ),

      // 4. Component Styles (Theming specific widgets)
      cardTheme: const CardThemeData(
        color: WeaverColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: WeaverColors.cardBorder, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WeaverColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: WeaverColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: WeaverColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
```

---

## 2. Line-by-Line Deep Dive

### The Foundation

- **Line 10**: `useMaterial3: true`
  - **What**: Enables the latest version of Google's design system.
  - **Why**: Material 3 provides better animations, more flexible color schemes, and modern-looking components by default.

- **Line 13**: `colorScheme: ...`
  - This is the "Mapping" of roles to colors. For example, `primary` is used for buttons and active states. `onPrimary` is the color used for text *on top* of a primary-colored button.

### Typography

- **Line 22**: `GoogleFonts.interTextTheme(...)`
  - **Inter Font**: We use the "Inter" font, which is very popular in modern software (like Figma or GitHub) because it's extremely readable on screens.
  - **TextTheme**: We define different "Styles" for different roles. `titleLarge` is for headers, `bodyMedium` is for standard paragraph text.

### Component Theming

- **Lines 41-49**: `cardTheme`
  - Weaver relies heavily on cards. Instead of giving every card a border radius and border color manually, we define it here. 
  - **`elevation: 0`**: We use borders instead of shadows for a cleaner, "flat" look.

- **Lines 54-71**: `inputDecorationTheme`
  - This styles all text input fields (like the chat box). 
  - **`focusedBorder`**: When the user clicks into the text box, it glows with our `accent` color (purple/blue).

---

## 3. Educational Callouts

> [!TIP]
> **Why use a Theme instead of hardcoding colors?**
> If you decide to change the "Accent" color from Purple to Blue, you only have to change it in **one place** (`colors.dart`) and the entire app (buttons, sliders, inputs) will update instantly. This is equivalent to using CSS Variables in web development.

---

## Key References
- [Flutter: Theming your App](https://docs.flutter.dev/cookbook/design/themes)
- [Material 3 Design System](https://m3.material.io/)
- [Google Fonts for Flutter](https://pub.dev/packages/google_fonts)
