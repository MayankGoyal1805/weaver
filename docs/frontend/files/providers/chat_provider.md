# Source Code Guide: `ChatProvider` (in `lib/providers/providers.dart`)

The `ChatProvider` is the most complex logic center in the frontend. It manages your conversation history, the VS-Code style tabs, and the interaction with the LLM via the backend.

---

## 1. Complete Code (Highlights)

```dart
class ChatProvider extends ChangeNotifier {
  // 1. Data Structures
  List<ChatSession> _sessions = [];
  final List<String> _openTabIds = [];
  String? _activeSessionId;

  // 2. The Main Action: Sending a Message
  Future<void> sendMessage(String content) async {
    // A. Create and add the User Message locally
    final userMsg = ChatMessage(role: MessageRole.user, content: content, ...);
    _appendMessage(userMsg);
    
    _isTyping = true;
    notifyListeners(); // UI shows "Typing..."

    try {
      // B. Call the Backend
      final out = await _backend.sendAgentPrompt(
        prompt: content,
        enabledToolIds: _toolsProvider.enabledIds,
        history: _getRecentHistory(),
        ...
      );

      // C. Handle Tool Results
      for (final toolCall in out['tool_calls']) {
        _appendMessage(ChatMessage(role: MessageRole.assistant, toolCall: ...));
      }

      // D. Add the Assistant's final response
      _appendMessage(ChatMessage(role: MessageRole.assistant, content: out['chat']['content']));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  // 3. Persistence (Hydration)
  Future<void> _hydrateIfNeeded() async {
    final raw = await _prefs.loadChatSessionsJson();
    _sessions = _parseSessions(raw);
    notifyListeners();
  }
}
```

---

## 2. Line-by-Line Deep Dive

### Tab Management (VS-Code Style)

- **Lines 298-303**: `_openTabIds` and `_activeTabId`
  - Weaver doesn't just show one chat at a time. It allows you to have multiple chats open in tabs.
  - **`List.unmodifiable`**: We return an unmodifiable list to the UI. This prevents a widget from accidentally trying to "Delete" a tab without going through the `closeTab()` method.

### The Message Loop

- **Line 357**: `Future<void> sendMessage(String content) async`
  - This is an "Optimistic UI" pattern. We add the user's message to the screen **before** the backend responds. This makes the app feel snappy.
  - **Tool Handling (Lines 413-434)**: The provider now extracts the `arguments` from each tool call.
  - **Pretty Printing (Lines 418-428)**: We use `JsonEncoder.withIndent('  ')` to turn raw tool results (which are often messy JSON) into beautiful, readable text blocks before they are saved to the `ChatMessage`. This ensures that when the user expands a tool card in the UI, they see a clean, professional view.
  - **`_isTyping`**: While waiting for the LLM, we set this to `true`. This triggers the "Typing Indicator" (the three bouncing dots) in the UI.


### Context Management

- **Lines 517-535**: `_historyForBackend`
  - LLMs have memory limits. We don't send the *entire* chat history (which could be thousands of words).
  - **`sublist(out.length - 20)`**: We only send the last 20 messages. This is called a "Sliding Window" history.

### Serialization (JSON)

- **Lines 627-708**: `_sessionToJson` and `_messageFromJson`
  - Because Dart is strictly typed, we can't just save a `ChatSession` object to disk. We have to manually convert it to a `Map` (JSON) and back. 
  - This is where we handle the complex mapping of `MessageRole` enums to strings.

---

## 3. Educational Callouts

> [!TIP]
> **What is Hydration?**
> On line 322, we call `_hydrateIfNeeded()`. In programming, "Hydration" is the process of taking "Dry" data (a text file or JSON on disk) and turning it into "Live" objects in memory that the app can use.

---

## Key References
- [Flutter: Optimistic UI Patterns](https://docs.flutter.dev/perf/optimistic-ui)
- [Dart: JSON and Serialization](https://dart.dev/guides/libraries/library-tour#dartconvert---decoding-and-encoding-json)
- [LLM Token Limits & Context Windows](https://platform.openai.com/docs/guides/text-generation/managing-tokens)
