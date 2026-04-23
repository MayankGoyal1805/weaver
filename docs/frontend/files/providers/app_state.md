# Source Code Guide: `AppState` (in `lib/providers/providers.dart`)

The `AppState` provider manages the top-level UI state of the application. It doesn't handle data or logic—only "where the user is" and "what they can see."

---

## 1. Complete Code

```dart
class AppState extends ChangeNotifier {
  // 1. Navigation State
  int _navIndex = 0;
  int get navIndex => _navIndex;

  void setNavIndex(int i) {
    _navIndex = i;
    notifyListeners(); // Tells Flutter to repaint the screen
  }

  // 2. Right Sidebar State
  bool _rightSidebarOpen = true;
  bool get rightSidebarOpen => _rightSidebarOpen;

  int _rightPanelTab = 0; // 0=tools, 1=workflows, 2=model
  int get rightPanelTab => _rightPanelTab;

  void setRightPanelTab(int i) {
    _rightPanelTab = i;
    _rightSidebarOpen = true; // Auto-open if a tab is selected
    notifyListeners();
  }

  void toggleRightSidebar() {
    _rightSidebarOpen = !_rightSidebarOpen;
    notifyListeners();
  }

  // 3. Left Sidebar State
  bool _leftSidebarOpen = true;
  bool get leftSidebarOpen => _leftSidebarOpen;

  void toggleLeftSidebar() {
    _leftSidebarOpen = !_leftSidebarOpen;
    notifyListeners();
  }
}
```

---

## 2. Line-by-Line Deep Dive

### Encapsulation (`_` prefix)

- **Line 12**: `int _navIndex = 0;`
  - In Dart, adding an underscore `_` before a variable name makes it **Private**.
  - **Why**: This prevents other files from changing the state directly. Instead, they must use the `setNavIndex` method, which ensures `notifyListeners()` is called.

### The Getter

- **Line 13**: `int get navIndex => _navIndex;`
  - This is a "Getter". It allows other widgets to *read* the value of `_navIndex` even though it's private.

### State Modification

- **Line 15-18**: `void setNavIndex(int i) { ... }`
  - This is a "Setter" method.
  - **`notifyListeners()`**: This is the most important call. It's inherited from `ChangeNotifier`. It tells the Flutter framework: "Hey, the navigation index changed! Please redraw the tabs."

### Sidebar Logic

- **Lines 27-31**: `setRightPanelTab`
  - Notice that we set `_rightSidebarOpen = true` here. This is a nice UX touch: if the user clicks the "Tools" tab icon, we automatically slide the sidebar open so they can see the tools.

---

## 3. Educational Callouts

> [!TIP]
> **Python Mental Model**:
> Think of `AppState` as a Python dictionary that stores your UI state, but with an added "Event" that fires whenever you update a key. In Python, you might use a callback or an observer pattern to achieve this.

---

## Key References
- [Flutter: ChangeNotifier Class](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
- [Dart: Private variables and Getters](https://dart.dev/guides/language/language-tour#getters-and-setters)
