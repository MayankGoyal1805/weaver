# Source Code Guide: `ToolsProvider` (in `lib/providers/providers.dart`)

The `ToolsProvider` manages the **Catalog of Capabilities**. It handles the connection status of Google and Discord, the search/filtering of tools, and the OAuth "Handshake" process.

---

## 1. Core Logic Snippet

```dart
class ToolsProvider extends ChangeNotifier {
  List<ToolModel> _tools = [];
  
  // 1. Filtering Logic
  List<ToolModel> get filteredTools {
    return _tools.where((t) {
      final matchesSearch = t.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _filterCategory == null || t.category == _filterCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // 2. The OAuth Handshake
  Future<void> connectTool(String toolId) async {
    _applyProviderAuth(provider, AuthStatus.pending);
    notifyListeners();

    try {
      // A. Open the browser for Google/Discord login
      await _backend.startOAuth(provider);

      // B. Polling: Check every second if the user finished logging in
      for (var i = 0; i < 120; i++) {
        await Future.delayed(Duration(seconds: 1));
        final status = await _backend.fetchAuthStatus(provider);
        if (status['authenticated'] == true) {
           _applyProviderAuth(provider, AuthStatus.connected);
           return;
        }
      }
    } catch (exc) {
      _applyProviderAuth(provider, AuthStatus.error);
    }
  }
}
```

---

## 2. Line-by-Line Deep Dive

### Search & Filter

- **Lines 778-787**: `filteredTools`
  - This is a "Computed Property." Every time the user types in the search bar, this list updates.
  - **`toLowerCase()`**: We convert everything to lowercase so that searching for "GMAIL" or "gmail" both work.

### The Polling Loop

- **Lines 827-837**: The 120-second loop.
  - **The Problem**: When the user clicks "Connect," they leave our app and go to their web browser. Our app has no way of "Knowing" when they finish the Google login.
  - **The Solution**: We "Poll" (ask) the backend every second: "Are they logged in yet?". We do this for 2 minutes (120 attempts) before giving up and showing a timeout error.

### State Synchronization

- **Lines 850-880**: `refreshFromBackend`
  - This function syncs the frontend's list of tools with the backend's `catalog`.
  - It also fetches **Metadata** (like your Gmail address or your Discord bot's name) so we can display it on the "Tool Card."

### Auth Status Mapping

- **Lines 991-998**: `_mapAuthStatus`
  - The backend uses strings like `"auth_required"`. The frontend uses a type-safe `AuthStatus` enum. This function acts as a "Translator" between the two.

---

## 3. Educational Callouts

> [!IMPORTANT]
> **Why use `bindBackend`?**
> On line 771, we have `bindBackend(BackendProvider backend)`. 
> Because Weaver uses `ChangeNotifierProxyProvider`, the `ToolsProvider` is automatically "Bound" to the `BackendProvider`. If the backend URL changes, the tools list automatically refreshes itself!

---

## Key References
- [OAuth 2.0 Authorization Code Flow](https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow)
- [Dart: Iterable.where (Filtering)](https://api.dart.dev/stable/dart-core/Iterable/where.html)
- [Flutter: ProxyProvider Patterns](https://pub.dev/documentation/provider/latest/provider/ProxyProvider-class.html)
