# Source Code Guide: `lib/providers/providers.dart` (Overview)

The `providers.dart` file is the "Central Nervous System" of the Weaver frontend. It uses the **ChangeNotifier** pattern to manage the application's state and notify the UI when something changes.

Because this file is extensive, we have broken down the documentation into its core components:

---

## The Core Providers

### 1. [AppState](./app_state.md)
Manages the global UI state:
- Which tab is active (Chat, Workflows, Settings).
- Whether the sidebars are open or closed.

### 2. [BackendProvider](./backend_provider.md)
Handles the connection to the Python server:
- Health checks.
- API authentication status.
- Saving user preferences (Base URL, API Keys).

### 3. [ChatProvider](./chat_provider.md)
The most complex provider. It manages:
- All chat sessions and messages.
- Sending prompts to the backend.
- Handling real-time updates and tool results.

### 4. [ToolsProvider](./tools_provider.md)
Manages the catalog of available tools:
- Fetching tools from the backend.
- Filtering tools by category or search query.
- Enabling/Disabling specific tools for the agent.

---

## Architecture: The "Notify" Pattern

In Flutter, when a piece of data changes (e.g., a new message arrives), we don't manually tell every widget to repaint. Instead:
1. We update the data in the **Provider**.
2. We call `notifyListeners()`.
3. Flutter automatically finds every widget that is "Listening" to that provider and updates only those widgets.

This is very efficient and prevents the "Jank" often seen in poorly optimized apps.

---

## Key References
- [Flutter Provider Package](https://pub.dev/packages/provider)
- [ChangeNotifier Class](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
- [State Management in Flutter](https://docs.flutter.dev/development/data-and-backend/state-mgmt/intro)
