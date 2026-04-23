# Source Code Guide: `lib/screens/settings_screen.dart`

The `SettingsScreen` is a complex stateful widget that allows users to configure the application's core parameters, including the backend URL, LLM credentials, and OAuth integrations.

---

## State Management (Lines 15-40)

- It uses `TextEditingController` for all input fields.
- **`didChangeDependencies` (Line 24)**: This is a lifecycle method that runs when the screen is loaded. It reads the current values from the `BackendProvider` and populates the controllers.
- **`dispose` (Line 34)**: Cleanly removes the controllers from memory when the user navigates away to prevent memory leaks.

---

## UI Sections (Lines 43-271)

The screen is built using a `SingleChildScrollView` to handle cases where the settings exceed the window height.

### 1. Backend Runtime (Line 64)
- Allows setting the `API Base URL`.
- Features "Save" and "Start Backend" buttons.
- Includes a **Connection Pill** (Lines 477-519) that shows "Connected" or "Disconnected" in real-time.

### 2. LLM Credentials (Line 130)
- Allows configuring the LLM Base URL and API Key.
- Includes a visibility toggle (`IconButton` at Line 147) for the API Key field using the `_obscureApiKey` state.

### 3. Auth & Tools (Line 175)
- Displays the status of Google and Discord OAuth.
- Shows detailed "User Info" tiles (Lines 376-429) if the user is logged in.
- Features "Connect" or "Reconnect" buttons (using the `_AuthRow` helper at Line 521).

### 4. Agent Defaults (Line 242)
- Allows setting a default Discord Channel ID, which is used by the agent when you ask it to "send a message to Discord."

---

## Helper Components

To keep the code readable, the screen uses several private helper widgets:
- **`_Section` (Line 299)**: A styled container with a title and icon.
- **`_LabeledField` (Line 338)**: A standard text input with a label on top.
- **`_UserInfoTile` (Line 376)**: A specialized tile for showing account details.
- **`_AuthRow` (Line 521)**: A row that switches between "Connect" and "Reconnect" buttons based on `AuthStatus`.

---

## Why use Consumer2? (Line 44)
`Consumer2<BackendProvider, ToolsProvider>` is used to rebuild the UI whenever *either* the backend status or the tool catalog changes. This ensures the "Connected" status and the "Auth Status" are always up to date.

## Key References
- [Flutter TextField widget](https://api.flutter.dev/flutter/material/TextField-class.html)
- [Flutter SingleChildScrollView](https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html)
- [Provider Consumer2 class](https://pub.dev/documentation/provider/latest/provider/Consumer2-class.html)
