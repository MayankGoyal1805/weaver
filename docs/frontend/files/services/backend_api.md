# Source Code Guide: `lib/services/backend_api.dart`

This file is the **Bridge** between the Flutter frontend and the Python backend. It handles three distinct responsibilities:
1. **Networking**: Sending JSON requests to the API.
2. **Process Management**: Auto-starting the Python server if it's not running.
3. **Persistence**: Saving user settings (like API keys) to the local disk.

---

## 1. Complete Code (Highlights)

```dart
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackendApi {
  // 1. Networking Wrapper
  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> payload) async {
    final res = await http.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return jsonDecode(res.body);
  }
}

class BackendRuntime {
  // 2. The Auto-Starter
  Future<void> ensureRunning(String baseUrl) async {
    if (await isHealthy(baseUrl)) return;
    
    // Logic: Run 'uv run uvicorn app.main:app'
    _process = await Process.start('uv', args, workingDirectory: backendDir.path);
  }
}

class BackendPreferences {
  // 3. Disk Storage (Settings)
  Future<void> saveLlmApiKey(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backend.llmApiKey', value);
  }
}
```

---

## 2. Line-by-Line Deep Dive

### The `BackendApi` Class

- **Lines 15-20**: `_uri(String path)`
  - **What**: A helper to build full URLs. 
  - **Why**: It handles the "Trailing Slash" problem. If the user enters `http://localhost:8000/` or `http://localhost:8000`, this function ensures the final URL is always correct.

### The `BackendRuntime` (Advanced)

- **Line 69**: `ensureRunning(String baseUrl) async`
  - This is unique to Desktop apps. If the backend isn't running, the frontend **starts it**.
  - **`Process.start('uv', ...)`**: It literally opens a hidden terminal and runs the Python command. 
  - **Health Check (Lines 103-106)**: After starting the process, it waits and "Pings" the `/health` endpoint every 250ms until the server is ready. It tries up to 80 times (20 seconds).

### The `BackendPreferences`

- **Line 151**: `SharedPreferences.getInstance()`
  - **What**: A cross-platform library for saving simple data.
  - **Python Equivalent**: Similar to saving a `.json` or `.ini` config file in the user's home directory. 
  - **Keys**: Every setting has a unique key (e.g., `backend.llmApiKey`).

---

## 3. Educational Callouts

> [!TIP]
> **What is `unawaited`?**
> On lines 100-101, we see `unawaited(_process!.stdout...)`. 
> Normally, we `await` things. But here, we want the log stream to run in the **background** forever without stopping our main function. `unawaited` tells the Dart compiler: "I know this is a Future, but I don't want to wait for it to finish."

---

## Key References
- [Dart: Process class (Running CLI commands)](https://api.dart.dev/stable/dart-io/Process-class.html)
- [Flutter: SharedPreferences](https://pub.dev/packages/shared_preferences)
- [HTTP Package for Flutter](https://pub.dev/packages/http)
