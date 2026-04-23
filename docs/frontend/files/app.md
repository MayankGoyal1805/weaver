# Source Code Guide: `lib/app.dart`

The `app.dart` file defines the **Root Widget** of the Weaver application. If `main.dart` is the engine starter, `app.dart` is the cockpit. It sets up state management, global styling, and the main layout shell.

---

## 1. Complete Code

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'theme/app_theme.dart';
import 'widgets/shell/app_shell.dart';

class WeaverApp extends StatelessWidget {
  const WeaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Independent State
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => BackendProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ModelProvider()..initialize()),
        
        // 2. Dependent State (ProxyProviders)
        ChangeNotifierProxyProvider<BackendProvider, ToolsProvider>(
          create: (_) => ToolsProvider(),
          update: (_, backend, tools) => tools!..bindBackend(backend),
        ),
        ChangeNotifierProxyProvider3<BackendProvider, ToolsProvider,
            ModelProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, backend, tools, model, chat) =>
              chat!..bind(backend, tools, model),
        ),
        ChangeNotifierProvider(create: (_) => WorkflowsProvider()),
      ],
      
      // 3. The Visual Application
      child: MaterialApp(
        title: 'Weaver',
        debugShowCheckedModeBanner: false,
        theme: WeaverTheme.dark,
        home: const AppShell(),
      ),
    );
  }
}
```

---

## 2. Line-by-Line Deep Dive

### State Management (`MultiProvider`)

Weaver uses the **Provider** pattern for state management. This is very similar to "Global Context" in web development or using a "Singleton" in Python.

- **Line 12**: `return MultiProvider(`
  - **What**: Wraps the entire app in a list of data providers.
  - **Why**: This ensures that any button or screen in the app can easily access the chat history, the list of tools, or the backend connection status.

- **Lines 14-16**: `ChangeNotifierProvider`
  - **`AppState`**: Manages which tab is selected (Chat vs. Workflows).
  - **`BackendProvider()..initialize()`**: Manages the connection to the Python server. The `..` (Cascade operator) allows us to call `initialize()` immediately after the object is created.
  - **`ModelProvider`**: Stores which LLM you are currently using (e.g., GPT-4o).

### Dependency Injection (`ProxyProvider`)

In Weaver, some parts of the state depend on others.

- **Lines 17-20**: `ChangeNotifierProxyProvider`
  - **Logic**: The `ToolsProvider` needs the `BackendProvider` to actually fetch the tools from the server. By using a Proxy, Flutter automatically updates the tools whenever the backend connection status changes.

- **Lines 21-26**: `ChangeNotifierProxyProvider3`
  - **Logic**: The `ChatProvider` is the "Brain". It needs to talk to the Backend, use the Tools, and know the Model. It "Proxy-depends" on all three.

---

### The `MaterialApp`

- **Line 29**: `child: MaterialApp(`
  - **What**: The core Flutter configuration widget.
  - **`debugShowCheckedModeBanner: false`**: Removes that little "DEBUG" banner in the corner of the screen.
  - **`theme: WeaverTheme.dark`**: Applies our custom high-fidelity dark theme globally. This keeps the design consistent across every screen.
  - **`home: const AppShell()`**: The first screen the user sees. `AppShell` contains the sidebar and the main content area.

---

## 3. Educational Callouts

> [!IMPORTANT]
> **Stateless vs. Stateful Widgets**:
> `WeaverApp` is a `StatelessWidget`. This means its *own* properties never change. All the "Changing" stuff happens inside the **Providers**. This is a best practice in Flutter to keep code clean and performance high.

---

## Key References
- [Flutter Provider Package](https://pub.dev/packages/provider)
- [Flutter Material App class](https://api.flutter.dev/flutter/material/MaterialApp-class.html)
- [Dart Cascade operator (..)](https://dart.dev/guides/language/language-tour#cascade-notation)
