# Frontend Source Code Index

This guide provides a file-by-file breakdown of the Weaver Flutter application. Click on any file to see its complete source code and a line-by-line explanation of how it works.

---

## 🚀 Entry Point
- [**main.dart**](main.md): The application bootstrapping and theme setup.
- [**app.dart**](app.md): The root widget and provider tree configuration.

## 🎨 Theme & Styling
- [**app_theme.dart**](theme/app_theme.md): Material 3 design system and typography.
- [**colors.dart**](theme/colors.md): The "Obsidian" custom color palette.

## 🧠 State Management (Providers)
- [**Overview**](providers/providers.md): How Weaver uses the Provider pattern.
- [**AppState**](providers/app_state.md): Navigation and global UI state.
- [**BackendProvider**](providers/backend_provider.md): Health monitoring and low-level API calls.
- [**ChatProvider**](providers/chat_provider.md): History, sessions, and LLM orchestration.
- [**ToolsProvider**](providers/tools_provider.md): Tool catalog, search, and OAuth polling.

## 📦 Data Models
- [**models.dart**](models/models.md): Enums and classes for Chats, Tools, and Workflows.

## 🧩 Key Widgets
- [**AppShell**](widgets/shell/app_shell.md): The root layout (Sidebar + Content).
- [**ChatView**](widgets/chat/chat_view.md): The main interactive conversation interface.
- [**ToolCard**](widgets/tool_card.md): Collapsible cards for tool management and auth.
- [**AnimatedWidgets**](widgets/common/animated_widgets.md): Spinners, typing indicators, and motion effects.

## 🗺️ Screens
- [**WorkflowsScreen**](screens/workflows_screen.md): The automation dashboard and canvas toggle.

---

## 🌐 Services
- [**backend_api.dart**](services/backend_api.md): Networking, auto-start logic, and local preferences.

---

### [← Back to Documentation Hub](../README.md)
