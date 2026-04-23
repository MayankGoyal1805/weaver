# Source Code Guide: Navigation Sidebars (`widgets/shell/`)

The layout of Weaver is defined by its two sidebars: the **Left Sidebar** (Navigation & History) and the **Right Sidebar** (Context & Configuration).

---

## 1. `lib/widgets/shell/left_sidebar.dart`

This is the primary navigation hub.

### Collapsible Logic (Lines 13-38)
- Controlled by `appState.leftSidebarOpen`.
- **Width**: Transitions between **64px** (collapsed) and **260px** (expanded).
- **Behavior**: When collapsed, it acts like a "Navigation Rail" showing only icons. When expanded, it reveals labels and the full chat history.

### Nav Section (Lines 64-155)
- Defines the four main areas: Chats, Dashboard, Workflows, and Settings.
- **`_NavItem`**: A stateful widget that handles hover effects and highlights the currently active page using `WeaverColors.accentGlow`.

### Chat History (Lines 158-335)
- Only visible when the sidebar is expanded.
- Groups chats into "Pinned", "Today", and "Earlier".
- **`_ChatSessionTile`**: Shows the chat title, last updated time, and an icon if the chat has linked workflows.

---

## 2. `lib/widgets/shell/right_sidebar.dart`

This sidebar provides contextual information based on the current page.

### The Tabbed Interface (Lines 16-47)
- Uses an `IndexedStack` to keep all three panels "alive" in the background:
    1.  **Tools Panel**: For managing provider connections.
    2.  **Workflows Panel**: For managing automations linked to the chat.
    3.  **Model Panel**: For tweaking LLM parameters (temp, max tokens).

### Tools Panel (Lines 166-314)
- **Search & Filter**: Includes a search bar and category chips (Cloud, Messaging, Files, etc.).
- **Error Handling (Line 184)**: Displays a red error banner if the backend fails to fetch the tool catalog, with a "Refresh" button.
- **List Rendering**: Uses `ListView.builder` for performance, rendering a `ToolCard` for each available tool.

---

## Architectural Note: IndexedStack
We use `IndexedStack` in the sidebars so that if you type something into a search bar or start configuring a tool, your progress isn't lost if you switch tabs and come back. The state is preserved.

## Key References
- [Flutter IndexedStack](https://api.flutter.dev/flutter/widgets/IndexedStack-class.html)
- [Flutter NavigationRail Pattern](https://m3.material.io/components/navigation-rail/overview)
