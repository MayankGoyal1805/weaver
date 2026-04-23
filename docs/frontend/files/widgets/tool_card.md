# Source Code Guide: `lib/widgets/tool_card/tool_card.dart`

The `ToolCard` is a **Self-Contained Dashboard** for a single capability (like Gmail or Discord). It manages its own expansion state, shows real-time connection status, and even includes editors for tool-specific settings.

---

## 1. High-Level Structure

```dart
class ToolCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ToolsProvider>(
      builder: (context, provider, _) {
        final isExpanded = provider.expandedToolId == tool.id;
        
        return AnimatedContainer(
          // ... animated border and color changes
          child: Column(
            children: [
              _ToolCardHeader(tool: tool, isExpanded: isExpanded),
              if (isExpanded) _ToolCardBody(tool: tool),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 2. Line-by-Line Deep Dive

### Header Logic (The "First Look")

- **Lines 87-99**: The Logo Container
  - We use a specific color for each tool category (`tool.categoryColor`).
  - **`withOpacity(0.12)`**: This creates a subtle, glassy background for the emoji, making it look premium.
- **Line 117**: `StatusBadge`
  - A custom widget that shows "Connected" (Green), "Auth Required" (Amber), or "Error" (Red).

### The Animated Expansion

- **Lines 19-21**: `AnimatedContainer`
  - When you click a card, it doesn't just "Snap" open. It smoothly transitions its background color and border width over 250 milliseconds.
- **Line 161**: `AnimatedRotation`
  - The "Down Arrow" icon rotates 180 degrees (`0.5` turns) when the card expands.

### Tool-Specific Editors

- **Lines 278-359**: `_FilesystemRootEditor`
  - This is a "Mini Form" inside the card.
  - **`didUpdateWidget` (Line 300)**: This is crucial. If the backend changes the root folder (e.g., you click "Reset"), the text field needs to update itself. We use `didUpdateWidget` to keep the UI in sync with the backend metadata.

### Capabilities List

- **Lines 509-550**: `_CapabilityRow`
  - Instead of just saying "Gmail," we show exactly what the tool can do (e.g., "Read Threads", "Send Message").
  - This helps the user understand *why* the AI is able to perform certain tasks.

---

## 3. Educational Callouts

> [!TIP]
> **What is `Transform.scale`?**
> On line 151, we use `Transform.scale(scale: 0.8, child: Switch(...))`. Flutter's default `Switch` widget is quite large. This "Transform" trick allows us to shrink it down so it fits neatly into our compact card header.

---

## Key References
- [Flutter: AnimatedContainer](https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html)
- [Flutter: MouseRegion (Hover effects)](https://api.flutter.dev/flutter/widgets/MouseRegion-class.html)
- [Dart: switch expression (Pattern matching)](https://dart.dev/language/branches#switch-expressions)
