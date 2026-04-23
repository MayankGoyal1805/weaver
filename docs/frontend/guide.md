# Frontend Guide

The frontend is a Flutter application using Provider for state management. It renders chat, tool controls, model settings, and workflow views, while persisting key user settings locally.

## System Overview

Core frontend layers:

1. App shell and navigation (`widgets/shell`)
   - Frame, sidebars, and tab switching.

2. State management (`providers/providers.dart`)
   - Backend settings.
   - Chat sessions and messages.
   - Tool cards and auth state.

3. UI feature widgets (`widgets/chat`, `widgets/tool_card`, `widgets/dashboard`, `widgets/workflow`)
   - User interaction and visual components.

4. API integration (`services/backend_api.dart`)
   - HTTP calls and local persistence.

5. Data contracts (`models/models.dart`)
   - Shared model objects used across providers and widgets.

6. Theme system (`theme/*`)
   - Consistent visual language and component styles.

## Frontend Directory Breakdown

### Entrypoint and root app

- `frontend/lib/main.dart`
  - Program entry.

- `frontend/lib/app.dart`
  - Root widget tree.
  - Provider registration.
  - Theme/app shell setup.

### State and data

- `frontend/lib/providers/providers.dart`
  - Main state graph.
  - Chat persistence/hydration.
  - Tool card state and backend sync.
  - Async calls to backend client.

- `frontend/lib/models/models.dart`
  - Data classes for chats, tools, settings, statuses.

- `frontend/lib/services/backend_api.dart`
  - API transport.
  - SharedPreferences keys and serialization logic.

### UI feature modules

- `frontend/lib/widgets/chat/chat_view.dart`
  - Message rendering.
  - Markdown output display.
  - `<think>` and tool block separation.

- `frontend/lib/widgets/chat/model_panel.dart`
  - Model/provider parameter controls.

- `frontend/lib/widgets/tool_card/tool_card.dart`
  - Expandable tool cards.
  - Auth status display.
  - Filesystem root editor.
  - Discord default channel editor.

- `frontend/lib/screens/settings_screen.dart`
  - Global settings and provider account information.

- `frontend/lib/widgets/dashboard/dashboard_view.dart`
  - Dashboard summary of app activity.

- `frontend/lib/widgets/workflow/*`
  - Workflow visualization panels.

- `frontend/lib/widgets/common/*`
  - Shared reusable components.

- `frontend/lib/theme/*`
  - Color and component theme definitions.

## Message Flow: UI -> Backend -> UI

1. User sends message in chat UI.
2. Provider constructs request payload with session/settings.
3. `backend_api.dart` posts to backend route.
4. Response is mapped to message/tool models.
5. Provider appends response to the correct chat session.
6. `chat_view.dart` renders markdown plus structured auxiliary blocks.

## State Management Patterns To Notice

1. `ChangeNotifier` boundaries in `providers.dart`.
2. Session-id based chat updates (to avoid history cross-contamination).
3. Local persistence key versioning for safe migration.
4. Clear split between transport models and UI state.

## How To Read The Complete Source

Use [../reference/frontend-source-reference.md](../reference/frontend-source-reference.md) and study in this order:

1. `frontend/lib/main.dart`
2. `frontend/lib/app.dart`
3. `frontend/lib/providers/providers.dart`
4. `frontend/lib/services/backend_api.dart`
5. `frontend/lib/widgets/chat/chat_view.dart`
6. `frontend/lib/widgets/tool_card/tool_card.dart`
7. `frontend/lib/screens/settings_screen.dart`
8. Remaining widgets and theme files

For each file:

1. Identify widget boundaries and state ownership.
2. Track where async calls happen and where results are stored.
3. Confirm rendering logic for loading/error/success states.
4. Cross-check model usage with backend schema contracts.