# Source Code Guide: `lib/widgets/shell/app_shell.dart`

The `AppShell` is the **Root Layout** of Weaver. It defines the "Frame" that stays visible while you navigate between the Chat, Dashboard, and Workflows.

---

## 1. Complete Code

```dart
class AppShell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WeaverColors.background,
      body: Row(
        children: [
          // 1. Navigation on the left
          const LeftSidebar(),
          
          Expanded(
            child: Column(
              children: [
                // 2. Tabs at the top
                const WeaverTabBar(),
                
                // 3. Main Content in the middle
                Expanded(
                  child: Consumer<AppState>(
                    builder: (context, appState, _) {
                      return IndexedStack(
                        index: appState.navIndex,
                        children: const [
                          ChatView(),
                          DashboardView(),
                          WorkflowsScreen(),
                          SettingsScreen(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 4. Tools/Inspector on the right
          const RightSidebar(),
        ],
      ),
    );
  }
}
```

---

## 2. Line-by-Line Deep Dive

### Layout Structure

- **Line 20**: `Row(children: [...])`
  - Because Weaver is a desktop-first app, we use a `Row` to divide the screen horizontally into the **Sidebar**, **Content**, and **Inspector**.
- **Line 23**: `Expanded(...)`
  - This tells the middle section to take up all the *remaining* space after the sidebars are drawn.

### Navigation State

- **Lines 30-31**: `IndexedStack(index: appState.navIndex, ...)`
  - **What**: An `IndexedStack` is a stack of widgets where only one is visible at a time.
  - **Why use this instead of standard Routing?**: Standard routing ("Push/Pop") often destroys the state of the page you leave. `IndexedStack` keeps all pages (Chat, Dashboard, etc.) "Alive" in the background. If you switch to the Dashboard and back to the Chat, your scroll position and typing progress are still there!

### Sidebars

- **Line 22**: `LeftSidebar()`: Contains the main icons for Chat, Workflows, and Settings.
- **Line 45**: `RightSidebar()`: Contains the "Tools Catalog." It's always available so you can quickly see if your Google Drive is connected while you are chatting.

---

## 3. Educational Callouts

> [!TIP]
> **StatelessWidget**:
> Notice `AppShell` is a `StatelessWidget`. It doesn't have any variables of its own. It just **listens** to the `AppState` via the `Consumer` widget. This is the "Clean Architecture" way to build Flutter apps.

---

## Key References
- [Flutter: IndexedStack class](https://api.flutter.dev/flutter/widgets/IndexedStack-class.html)
- [Flutter Layout: Row and Column](https://docs.flutter.dev/ui/layout)
- [Flutter: Scaffold widget](https://api.flutter.dev/flutter/material/Scaffold-class.html)
