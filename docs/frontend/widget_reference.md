# Weaver Widget Reference

This document provides a comprehensive guide to every major widget in the Weaver frontend, explaining their functionality, implementation details, and where to find them in the codebase.

---

## 🏗️ Shell & Navigation

### WeaverApp
- **File**: `lib/app.dart`
- **Purpose**: The root application widget.
- **Role**: Configures the `MaterialApp`, applies the global theme, and wraps the UI in a `MultiProvider` to ensure all state managers are available throughout the widget tree.

### AppShell
- **File**: `lib/widgets/shell/app_shell.dart`
- **Purpose**: Master layout orchestrator.
- **Role**: Implements a three-column `Row` layout. It decides which main view to show using an `IndexedStack` based on `AppState.navIndex`.
- **Children**: `LeftSidebar`, `WeaverTabBar`, `ChatView`/`DashboardView`/`WorkflowsScreen`/`SettingsScreen`, and `RightSidebar`.

### LeftSidebar
- **File**: `lib/widgets/shell/left_sidebar.dart`
- **Purpose**: Primary navigation and session management.
- **Role**: Contains the "Logo", navigation buttons (Chat, Dashboard, Workflows, Settings), and a list of pinned/recent chat sessions. It allows users to switch between global views and specific chat contexts.

### RightSidebar
- **File**: `lib/widgets/shell/right_sidebar.dart`
- **Purpose**: Contextual configuration and tool discovery.
- **Role**: A toggleable panel containing three tabs:
  1. **Tools**: Searching and configuring active plugins (Gmail, Discord, etc.).
  2. **Workflows**: Listing and managing automated sequences for the current session.
  3. **Model**: Fine-tuning agent parameters like temperature, max tokens, and system prompts.

### WeaverTabBar
- **File**: `lib/widgets/shell/weaver_tab_bar.dart`
- **Purpose**: Multi-tab management for chat sessions.
- **Role**: Similar to a VS Code or Browser tab bar. It allows users to keep multiple chat sessions open and switch between them quickly without losing their scroll position.

---

## 💬 Chat System

### ChatView
- **File**: `lib/widgets/chat/chat_view.dart`
- **Purpose**: The main interface for interacting with AI agents.
- **Role**: Combines the message history (`_MessageList`), the tool status strip (`_ToolChipStrip`), and the message composer (`_ChatInput`). It also handles "empty states" when no session is selected.

### MessageBubble
- **File**: `lib/widgets/chat/chat_view.dart`
- **Purpose**: A wrapper for individual chat messages.
- **Role**: A stateless dispatcher that chooses between `_UserBubble` (right-aligned, accent color) and `_AssistantBubble` (left-aligned, card color) based on the message sender.

### _ToolCallCard
- **File**: `lib/widgets/chat/chat_view.dart`
- **Purpose**: Visualizing agent actions.
- **Role**: Rendered when an agent calls a tool. It shows the tool name, arguments, and execution status (OK/ERR). It is expandable to reveal the raw JSON response from the backend.

### _ChatInput
- **File**: `lib/widgets/chat/chat_view.dart`
- **Purpose**: Message entry.
- **Role**: A stylized text field with a glassmorphism effect. It handles the `Enter` key to send messages and provides a visual "Typing..." indicator.

---

## ⚡ Workflow System

### WorkflowCanvas
- **File**: `lib/widgets/workflow/workflow_canvas.dart`
- **Purpose**: An interactive graph editor for automations.
- **Role**: Handles the infinite grid background, zooming, and panning of the canvas. It renders the nodes and their connections.

### _EdgePainter (CustomPainter)
- **File**: `lib/widgets/workflow/workflow_canvas.dart`
- **Purpose**: Drawing connection lines.
- **Role**: Uses `Path.cubicTo` to draw smooth Bezier curves between nodes. It includes a multi-layered stroke to create a glowing "silk thread" effect.

### _DraggableNode
- **File**: `lib/widgets/workflow/workflow_canvas.dart`
- **Purpose**: Individual workflow steps.
- **Role**: A floating card that represents a trigger or action. It uses `GestureDetector` to track drag deltas and updates its position in the `WorkflowsProvider`.

---

## 📊 Dashboard & Tools

### DashboardView
- **File**: `lib/widgets/dashboard/dashboard_view.dart`
- **Purpose**: High-level platform overview.
- **Role**: A scrollable dashboard containing `_StatsRow` (key metrics), `_ToolStatusCard` (usage bars), and `_RecentActivityCard` (activity timeline).

### ToolCard
- **File**: `lib/widgets/tool_card/tool_card.dart`
- **Purpose**: Deep configuration for integrations.
- **Role**: Used in the Right Sidebar. It provides:
  - Toggle switches to enable/disable tools.
  - Authentication status and "Connect" buttons.
  - Specialized editors like `_FilesystemRootEditor` or `_DiscordChannelEditor`.
  - A list of `ToolCapability` rows explaining what the tool can do.

---

## 🛠️ Common Components

### StatusBadge
- **File**: `lib/widgets/common/common_widgets.dart`
- **Purpose**: Consistent status visualization.
- **Role**: Used for Auth status (Connected/Disconnected), Workflow status (Running/Success/Error), and Backend health.

### TypingIndicator
- **File**: `lib/widgets/common/animated_widgets.dart`
- **Purpose**: Agent feedback.
- **Role**: A custom animation showing three pulsing dots and the agent's name to indicate the backend is processing a request.
