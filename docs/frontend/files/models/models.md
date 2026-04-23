# Source Code Guide: `lib/models/models.dart`

This file is the **Data Backbone** of the frontend. In Python, you use Pydantic; in Dart, we use classes. These classes represent everything from a single "Chat Message" to a complex "Workflow Node."

---

## 1. Complete Code (Highlights)

```dart
enum MessageRole { user, assistant, system, tool }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final ToolCallResult? toolCall; // Optional: Only if the message is an action

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.toolCall,
  });
}

class ToolModel {
  final String id;
  final String name;
  final String description;
  final ToolCategory category;
  AuthStatus authStatus; // Can change (connected/disconnected)
  bool isEnabled;

  ToolModel({ ... });
}

class WorkflowNode {
  final String id;
  final String label;
  final NodeType type;
  Offset position; // The (X, Y) coordinates on the canvas
  final Map<String, dynamic> config;

  WorkflowNode({ ... });
}
```

---

## 2. Line-by-Line Deep Dive

### Enums (Enumerations)

- **Line 45**: `enum MessageRole { user, assistant, system, tool }`
  - **What**: Enums are a way to define a variable that can only be one of a few predefined values. 
  - **Why**: Instead of using strings like `"user"`, which are easy to typo, we use `MessageRole.user`. The compiler will catch any mistakes immediately.

### The `ChatMessage` Class

- **Line 66**: `final ToolCallResult? toolCall;`
  - **The `?` Symbol**: In Dart, this means the field is **Nullable**. 
  - **Logic**: A standard text message doesn't have a tool result, so it's `null`. A message where the agent "Sent an Email" will have a `ToolCallResult` object attached to it.

### Tool Modeling

- **Lines 15-43**: `ToolModel`
  - This is the frontend's version of the `ToolDefinition` from the backend. 
  - **`authStatus`**: Notice this is NOT `final`. That's because the status can change while the app is running (e.g., the user clicks "Connect").

### Workflow Nodes (Visual Data)

- **Line 120**: `Offset position;`
  - **What**: A Flutter class that stores an X and Y coordinate.
  - **Usage**: When you drag a node around on the Workflow Canvas, we update this `position`. This is how Weaver remembers where you put your icons.

---

## 3. Educational Callouts

> [!TIP]
> **Immutability (`final` and `const`)**:
> Most fields in these models are `final`. This means once the object is created, the data cannot be changed. This is a "Best Practice" in Flutter because it makes the app much easier to debug—you don't have to worry about data changing unexpectedly behind your back.

---

## Key References
- [Dart: Classes and Objects](https://dart.dev/guides/language/language-tour#classes)
- [Dart: Null Safety](https://dart.dev/null-safety)
- [Flutter: Offset class](https://api.flutter.dev/flutter/dart-ui/Offset-class.html)
