# Source Code Guide: `lib/models/models.dart`

This file defines the data structures (Data Models) used throughout the Flutter application. These models ensure that data is structured consistently and provide type safety across different widgets and services.

## Core Models

### 1. Tool Management
- **`ToolCategory` (Line 3)**: An enum for grouping tools (e.g., `cloud`, `messaging`, `files`).
- **`ToolModel` (Line 15)**: Represents a single tool (like Gmail).
    - Includes metadata like `id`, `name`, `logoEmoji`, and `authStatus`.
    - `capabilities`: A list of specific actions the tool can perform.

---

### 2. Chat & Agents
- **`MessageRole` (Line 45)**: Defines who sent a message (`user`, `assistant`, `system`, or `tool`).
- **`ChatMessage` (Line 61)**: Represents a single bubble in the chat UI.
    - `toolCall`: Optional metadata if the message represents a tool execution result.
- **`ChatSession` (Line 79)**: A collection of messages forming a single conversation.
    - Includes metadata like `title`, `updatedAt`, and which tools were enabled during the session.

---

### 3. Workflow & Automation
- **`NodeType` (Line 101)**: Defines the role of a node in the workflow canvas (`trigger`, `action`, etc.).
- **`WorkflowNode` (Line 113)**: Represents a visual box on the canvas.
    - Includes `position` (where it is on the screen), `config` (tool-specific settings), and `ports` (connection points).
- **`WorkflowEdge` (Line 139)**: Represents a line connecting two nodes.
- **`WorkflowModel` (Line 155)**: The parent structure for a complete automation flow.

---

### 4. LLM & Agents
- **`AgentModel` (Line 183)**: Defines a pre-configured AI persona with a specific system prompt and set of tools.
- **`LlmModel` (Line 203)**: Metadata for a specific AI model (e.g., GPT-4), including its context window size.

---

## Why use Classes for Data?

In Flutter/Dart, using classes instead of generic `Map<String, dynamic>` provides several benefits:
1.  **Autocomplete**: Your IDE can suggest field names (e.g., typing `session.` will suggest `title`, `messages`, etc.).
2.  **Refactoring**: If you rename a field in the class, the IDE can automatically update all usages across the app.
3.  **Validation**: You can add logic to the constructor to ensure data is valid (e.g., ensuring a URL is properly formatted).

## Key References
- [Dart Classes & Objects](https://dart.dev/guides/language/language-tour#classes)
- [Dart Enums](https://dart.dev/guides/language/language-tour#enums)
