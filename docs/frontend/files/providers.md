# Source Code Guide: `lib/providers/providers.dart`

This file is the "heart" of the Weaver frontend. It contains all the state management logic using the `Provider` pattern. It handles navigation, backend communication, chat history, tool management, and persistence.

[Note: Due to the size of this file (1200+ lines), this guide focuses on the core functional blocks.]

---

## 1. AppState (Navigation & UI)

This class manages the global UI state, such as which sidebar is open and which tab is selected in the main navigation.

- **Lines 12-18**: Handles the main navigation index (`navIndex`).
- **Lines 21-46**: Manages the visibility and active tab of the left and right sidebars.
- **Why?**: Centralizing this state ensures that when you switch tabs, the UI updates consistently across the app.

---

## 2. BackendProvider (The Bridge)

This is the most critical provider. It manages the connection to the Python FastAPI backend.

- **`initialize()` (Line 80)**: Loads saved settings (Base URL, API keys) from local storage and ensures the backend is running.
- **`ensureBackendRunning()` (Line 161)**: On Linux, this can actually trigger the backend to start automatically if it's not already running.
- **`sendAgentPrompt()` (Line 240)**: The main method for sending user prompts to the backend. It gathers all necessary context (model, tool IDs, history) and performs the POST request.
- **OAuth Logic (Line 230)**: Handles triggering the OAuth flow for Google and Discord by opening the system browser to the backend's auth URL.

---

## 3. ChatProvider (Conversation Memory)

This provider manages the history of messages, sessions, and active tabs (VSCode-style).

- **`sendMessage()` (Line 357)**:
  1. Creates a new `ChatMessage` for the user.
  2. Notifies the UI to show a loading/typing state.
  3. Calls `BackendProvider.sendAgentPrompt()`.
  4. Parses the response, including any `tool_calls` made by the agent.
  5. Adds "Assistant" messages and "Tool Call" results to the history.
- **Persistence (Line 627)**: Uses `jsonEncode` to save the entire chat history to local storage (`shared_preferences`) so your conversations are there when you restart the app.
- **History Management (Line 517)**: `_historyForBackend` ensures that only the last 20 messages are sent to the LLM to save tokens and stay within context limits.

---

## 4. ToolsProvider (The Catalog)

Manages the list of tools available in the system.

- **Filtering (Line 778)**: Implements search and category filtering logic that the UI uses to show/hide tool cards.
- **Sync (Line 771)**: Automatically refreshes the tool list from the backend whenever the connection status changes.

---

## Key Design Patterns

### ChangeNotifier
All providers extend `ChangeNotifier`. When a value changes (e.g., `_isConnected = true`), the provider calls `notifyListeners()`. This tells any Flutter widgets "listening" to this provider to rebuild with the new data.

### Cascades (`..`)
Used frequently (e.g., `BackendProvider()..initialize()`) to chain an initialization call immediately after an object is created.

### JSON Serialization
Since Dart is strongly typed, we manually convert JSON maps from the API into our strongly typed `ChatMessage` and `ChatSession` models using helper methods like `_messageFromJson`.

---

## Key References
- [Flutter Provider Package](https://pub.dev/packages/provider)
- [Working with JSON in Flutter](https://docs.flutter.dev/development/data-and-backend/json)
