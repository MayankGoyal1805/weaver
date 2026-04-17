import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/backend_api.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

// ── App State Provider ────────────────────────────────────────────────────────
class AppState extends ChangeNotifier {
  // Navigation
  int _navIndex = 0;
  int get navIndex => _navIndex;

  void setNavIndex(int i) {
    _navIndex = i;
    notifyListeners();
  }

  // Right sidebar
  bool _rightSidebarOpen = true;
  bool get rightSidebarOpen => _rightSidebarOpen;

  int _rightPanelTab = 0; // 0=tools, 1=workflows, 2=model
  int get rightPanelTab => _rightPanelTab;

  void setRightPanelTab(int i) {
    _rightPanelTab = i;
    _rightSidebarOpen = true;
    notifyListeners();
  }

  void toggleRightSidebar() {
    _rightSidebarOpen = !_rightSidebarOpen;
    notifyListeners();
  }

  // Left sidebar
  bool _leftSidebarOpen = true;
  bool get leftSidebarOpen => _leftSidebarOpen;

  void toggleLeftSidebar() {
    _leftSidebarOpen = !_leftSidebarOpen;
    notifyListeners();
  }
}

// ── Backend Provider ──────────────────────────────────────────────────────────
class BackendProvider extends ChangeNotifier {
  final BackendPreferences _prefs = BackendPreferences();
  final BackendRuntime _runtime = BackendRuntime();

  late BackendApi _api;
  String _baseUrl = 'http://127.0.0.1:8000';
  String _discordChannelId = '';
  String _llmApiKey = '';
  String _llmBaseUrl = 'https://api.openai.com/v1';
  String _filesystemRoot = '';
  Map<String, dynamic> _googleUserInfo = const {};
  Map<String, dynamic> _discordUserInfo = const {};
  Map<String, dynamic> _discordBotStatus = const {};
  bool _autoStartBackend = true;
  bool _isConnected = false;
  bool _isStarting = false;
  String? _lastError;

  String get baseUrl => _baseUrl;
  String get discordChannelId => _discordChannelId;
  String get llmApiKey => _llmApiKey;
  String get llmBaseUrl => _llmBaseUrl;
  String get filesystemRoot => _filesystemRoot;
  Map<String, dynamic> get googleUserInfo => _googleUserInfo;
  Map<String, dynamic> get discordUserInfo => _discordUserInfo;
  Map<String, dynamic> get discordBotStatus => _discordBotStatus;
  bool get autoStartBackend => _autoStartBackend;
  bool get isConnected => _isConnected;
  bool get isStarting => _isStarting;
  String? get lastError => _lastError;

  Future<void> initialize() async {
    _baseUrl = await _prefs.loadBaseUrl();
    _discordChannelId = await _prefs.loadDiscordChannelId();
    _llmApiKey = await _prefs.loadLlmApiKey();
    _llmBaseUrl = await _prefs.loadLlmBaseUrl();
    _filesystemRoot = await _prefs.loadFilesystemRoot();
    _autoStartBackend = await _prefs.loadAutoStart();
    _api = BackendApi(_baseUrl);

    if (_autoStartBackend) {
      await ensureBackendRunning();
    } else {
      await refreshHealth();
    }

    if (_isConnected) {
      await _syncFilesystemRootIfNeeded();
      await refreshUserInfo();
      await refreshDiscordBotStatus();
    }
  }

  Future<void> setBaseUrl(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _baseUrl = trimmed;
    _api.baseUrl = trimmed;
    await _prefs.saveBaseUrl(trimmed);
    await refreshHealth();
    notifyListeners();
  }

  Future<void> setDiscordChannelId(String value) async {
    _discordChannelId = value.trim();
    await _prefs.saveDiscordChannelId(_discordChannelId);
    notifyListeners();
  }

  Future<void> setLlmApiKey(String value) async {
    _llmApiKey = value.trim();
    await _prefs.saveLlmApiKey(_llmApiKey);
    notifyListeners();
  }

  Future<void> setLlmBaseUrl(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _llmBaseUrl = trimmed;
    await _prefs.saveLlmBaseUrl(_llmBaseUrl);
    notifyListeners();
  }

  Future<void> setFilesystemRoot(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    await ensureBackendRunning();
    final out = await _api.postJson('/api/v1/tools/filesystem/root', {'allowed_root': trimmed});
    _filesystemRoot = out['allowed_root']?.toString() ?? trimmed;
    await _prefs.saveFilesystemRoot(_filesystemRoot);
    notifyListeners();
  }

  Future<void> setAutoStartBackend(bool value) async {
    _autoStartBackend = value;
    await _prefs.saveAutoStart(value);
    if (value) {
      await ensureBackendRunning();
    }
    notifyListeners();
  }

  Future<void> refreshHealth() async {
    final ok = await _runtime.isHealthy(_baseUrl);
    _isConnected = ok;
    if (ok) {
      _lastError = null;
    }
    notifyListeners();
  }

  Future<void> ensureBackendRunning() async {
    _isStarting = true;
    _lastError = null;
    notifyListeners();
    try {
      await _runtime.ensureRunning(_baseUrl);
      _isConnected = true;
    } catch (exc) {
      _isConnected = false;
      _lastError = '$exc';
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> fetchToolCatalog() async {
    final out = await _api.getJsonList('/api/v1/tools/catalog');
    return out.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchToolStates() async {
    final out = await _api.getJsonList('/api/v1/tools/cards/state');
    return out.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> fetchAuthStatus(String provider) async {
    return _api.getJson('/api/v1/auth/$provider/status');
  }

  Future<Map<String, dynamic>> fetchProviderUserInfo(String provider) async {
    return _api.getJson('/api/v1/auth/$provider/userinfo');
  }

  Future<void> refreshUserInfo() async {
    await ensureBackendRunning();
    try {
      _googleUserInfo = await fetchProviderUserInfo('google');
    } catch (_) {
      _googleUserInfo = const {};
    }
    try {
      _discordUserInfo = await fetchProviderUserInfo('discord');
    } catch (_) {
      _discordUserInfo = const {};
    }
    notifyListeners();
  }

  Future<void> refreshDiscordBotStatus() async {
    await ensureBackendRunning();
    try {
      _discordBotStatus = await _api.getJson('/api/v1/auth/discord/bot-status');
    } catch (_) {
      _discordBotStatus = const {};
    }
    notifyListeners();
  }

  Future<void> refreshFilesystemRoot() async {
    await ensureBackendRunning();
    try {
      final out = await _api.getJson('/api/v1/tools/filesystem/root');
      _filesystemRoot = out['allowed_root']?.toString() ?? _filesystemRoot;
      await _prefs.saveFilesystemRoot(_filesystemRoot);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> startOAuth(String provider) async {
    await ensureBackendRunning();
    final out = await _api.getJson('/api/v1/auth/$provider/connect');
    final url = out['auth_url']?.toString();
    if (url == null || url.isEmpty) {
      throw Exception('Missing auth URL for provider $provider');
    }
    await openExternalUrl(url);
  }

  Future<Map<String, dynamic>> sendAgentPrompt({
    required String prompt,
    required List<String> enabledToolIds,
    String? modelName,
    String? systemPrompt,
    String? discordChannelId,
    String? llmApiKey,
    String? llmBaseUrl,
    List<Map<String, String>> history = const [],
  }) async {
    await ensureBackendRunning();
    return _api.postJson('/api/v1/chat/agent', {
      'prompt': prompt,
      'enabled_tool_ids': enabledToolIds,
      'model_name': modelName,
      'system_prompt': systemPrompt,
      'discord_channel_id': discordChannelId,
      'llm_api_key': llmApiKey,
      'llm_base_url': llmBaseUrl,
      'history': history,
    });
  }

  Future<void> _syncFilesystemRootIfNeeded() async {
    if (_filesystemRoot.isEmpty) {
      await refreshFilesystemRoot();
      return;
    }
    try {
      await _api.postJson('/api/v1/tools/filesystem/root', {'allowed_root': _filesystemRoot});
    } catch (_) {
      await refreshFilesystemRoot();
    }
  }

  @override
  void dispose() {
    _runtime.stop();
    super.dispose();
  }
}

// ── Chat Provider ─────────────────────────────────────────────────────────────
class ChatProvider extends ChangeNotifier {
  final BackendPreferences _prefs = BackendPreferences();

  List<ChatSession> _sessions = [];
  List<ChatSession> get sessions => _sessions;

  String? _activeSessionId;
  String? get activeSessionId => _activeSessionId;

  ChatSession? get activeSession =>
      _sessions.where((s) => s.id == _activeSessionId).firstOrNull;

  // Open tabs (VSCode style)
  final List<String> _openTabIds = [];
  List<String> get openTabIds => List.unmodifiable(_openTabIds);

  String? _activeTabId;
  String? get activeTabId => _activeTabId;

  BackendProvider? _backend;
  ToolsProvider? _toolsProvider;
  ModelProvider? _modelProvider;
  bool _didHydrate = false;

  final TextEditingController inputController = TextEditingController();
  bool _isTyping = false;
  bool get isTyping => _isTyping;

  void bind(BackendProvider backend, ToolsProvider toolsProvider, ModelProvider modelProvider) {
    _backend = backend;
    _toolsProvider = toolsProvider;
    _modelProvider = modelProvider;
    _hydrateIfNeeded();
    if (_sessions.isEmpty && !_didHydrate) {
      final initial = ChatSession(
        id: 'chat-${DateTime.now().millisecondsSinceEpoch}',
        title: 'New conversation',
        agentName: 'Weaver Agent',
        updatedAt: DateTime.now(),
        messages: const [],
        enabledToolIds: const ['gmail', 'google-drive', 'discord', 'filesystem'],
      );
      _sessions = [initial];
      openSession(initial.id);
    }
  }

  void openSession(String sessionId) {
    if (!_openTabIds.contains(sessionId)) {
      _openTabIds.add(sessionId);
    }
    _activeSessionId = sessionId;
    _activeTabId = sessionId;
    _persistState();
    notifyListeners();
  }

  void closeTab(String sessionId) {
    _openTabIds.remove(sessionId);
    if (_activeTabId == sessionId) {
      _activeTabId = _openTabIds.isNotEmpty ? _openTabIds.last : null;
      _activeSessionId = _activeTabId;
    }
    _persistState();
    notifyListeners();
  }

  void setActiveTab(String sessionId) {
    _activeTabId = sessionId;
    _activeSessionId = sessionId;
    _persistState();
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _activeSessionId == null) return;
    final idx = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (idx == -1) return;

    final userMsg = ChatMessage(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    // Add user message
    final updated = List<ChatMessage>.from(_sessions[idx].messages)..add(userMsg);
    _sessions[idx] = ChatSession(
      id: _sessions[idx].id,
      title: _sessions[idx].title,
      agentName: _sessions[idx].agentName,
      updatedAt: DateTime.now(),
      messages: updated,
      enabledToolIds: _sessions[idx].enabledToolIds,
      isPinned: _sessions[idx].isPinned,
      workflowCount: _sessions[idx].workflowCount,
    );
    inputController.clear();
    _isTyping = true;
    notifyListeners();

    try {
      final backend = _backend;
      final toolsProvider = _toolsProvider;
      final modelProvider = _modelProvider;
      if (backend == null || toolsProvider == null || modelProvider == null) {
        throw Exception('Backend integration is not initialized.');
      }

      final activeTools = toolsProvider.tools
          .where((t) => t.isEnabled)
          .map((t) => t.id)
          .toList(growable: false);

      final out = await backend.sendAgentPrompt(
        prompt: content.trim(),
        enabledToolIds: activeTools,
        modelName: modelProvider.modelName,
        systemPrompt: modelProvider.systemPrompt,
        discordChannelId: backend.discordChannelId.isEmpty ? null : backend.discordChannelId,
        llmApiKey: backend.llmApiKey.isEmpty ? null : backend.llmApiKey,
        llmBaseUrl: backend.llmBaseUrl,
        history: _historyForBackend(_sessions[idx].messages),
      );

      final toolCalls = (out['tool_calls'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
      for (final toolCall in toolCalls) {
        final result = (toolCall['result'] as Map<String, dynamic>? ?? const {});
        final status = result['status']?.toString() ?? 'unknown';
        final summary = result['result']?.toString() ?? status;

        final toolMsg = ChatMessage(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-${toolCall['tool_id']}',
          role: MessageRole.assistant,
          content: '',
          timestamp: DateTime.now(),
          toolCall: ToolCallResult(
            toolName: toolCall['tool_id']?.toString() ?? 'tool',
            arguments: const {},
            result: summary,
            success: status == 'ok',
          ),
        );
        _appendMessage(idx, toolMsg);
      }

      final chat = (out['chat'] as Map<String, dynamic>? ?? const {});
      final chatError = out['chat_error']?.toString();
      final assistantContent = (chat['content']?.toString().trim().isNotEmpty ?? false)
          ? chat['content'].toString()
          : (chatError != null && chatError.isNotEmpty
              ? 'Agent note: $chatError'
              : 'Request completed.');

      final assistantMsg = ChatMessage(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.assistant,
        content: assistantContent,
        timestamp: DateTime.now(),
      );
      _appendMessage(idx, assistantMsg);
      _refreshSessionTitle(idx);
    } catch (exc) {
      final assistantMsg = ChatMessage(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.assistant,
        content: 'Failed to process request: $exc',
        timestamp: DateTime.now(),
      );
      _appendMessage(idx, assistantMsg);
    } finally {
      _isTyping = false;
      _persistState();
      notifyListeners();
    }
  }

  void newChat() {
    final id = 'chat-new-${DateTime.now().millisecondsSinceEpoch}';
    final session = ChatSession(
      id: id,
      title: 'New conversation',
      agentName: 'Weaver Agent',
      updatedAt: DateTime.now(),
      messages: [],
      enabledToolIds: const ['gmail', 'google-drive', 'discord', 'filesystem'],
    );
    _sessions.insert(0, session);
    openSession(id);
    _persistState();
    notifyListeners();
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  void _appendMessage(int idx, ChatMessage message) {
    final updated = List<ChatMessage>.from(_sessions[idx].messages)..add(message);
    _sessions[idx] = ChatSession(
      id: _sessions[idx].id,
      title: _sessions[idx].title,
      agentName: _sessions[idx].agentName,
      updatedAt: DateTime.now(),
      messages: updated,
      enabledToolIds: _sessions[idx].enabledToolIds,
      isPinned: _sessions[idx].isPinned,
      workflowCount: _sessions[idx].workflowCount,
    );
    _persistState();
  }

  List<Map<String, String>> _historyForBackend(List<ChatMessage> messages) {
    final out = <Map<String, String>>[];
    for (final msg in messages) {
      if (msg.content.trim().isEmpty) {
        continue;
      }
      final role = switch (msg.role) {
        MessageRole.user => 'user',
        MessageRole.assistant => 'assistant',
        MessageRole.system => 'system',
        MessageRole.tool => 'assistant',
      };
      out.add({'role': role, 'content': msg.content});
    }
    if (out.length > 20) {
      return out.sublist(out.length - 20);
    }
    return out;
  }

  void _refreshSessionTitle(int idx) {
    final session = _sessions[idx];
    if (session.title != 'New conversation') {
      return;
    }
    final firstUser = session.messages.where((m) => m.role == MessageRole.user).firstOrNull;
    if (firstUser == null) {
      return;
    }
    final cleaned = firstUser.content.trim().replaceAll('\n', ' ');
    if (cleaned.isEmpty) {
      return;
    }
    final title = cleaned.length > 48 ? '${cleaned.substring(0, 48)}...' : cleaned;
    _sessions[idx] = ChatSession(
      id: session.id,
      title: title,
      agentName: session.agentName,
      updatedAt: session.updatedAt,
      messages: session.messages,
      enabledToolIds: session.enabledToolIds,
      isPinned: session.isPinned,
      workflowCount: session.workflowCount,
    );
  }

  Future<void> _hydrateIfNeeded() async {
    if (_didHydrate) {
      return;
    }
    _didHydrate = true;
    final raw = await _prefs.loadChatSessionsJson();
    if (raw.isEmpty) {
      if (_sessions.isEmpty) {
        final initial = ChatSession(
          id: 'chat-${DateTime.now().millisecondsSinceEpoch}',
          title: 'New conversation',
          agentName: 'Weaver Agent',
          updatedAt: DateTime.now(),
          messages: const [],
          enabledToolIds: const ['gmail', 'google-drive', 'discord', 'filesystem'],
        );
        _sessions = [initial];
        _activeSessionId = initial.id;
        _activeTabId = initial.id;
        _openTabIds
          ..clear()
          ..add(initial.id);
        notifyListeners();
      }
      return;
    }

    try {
      final parsed = jsonDecode(raw) as List<dynamic>;
      _sessions = parsed.map((e) => _sessionFromJson(e as Map<String, dynamic>)).toList();
      final savedActive = await _prefs.loadActiveChatSessionId();
      if (_sessions.isNotEmpty) {
        final active = _sessions.any((s) => s.id == savedActive) ? savedActive : _sessions.first.id;
        _activeSessionId = active;
        _activeTabId = active;
        _openTabIds
          ..clear()
          ..add(active!);
      }
      notifyListeners();
    } catch (_) {
      _sessions = [];
    }
  }

  void _persistState() {
    final jsonList = jsonEncode(_sessions.map(_sessionToJson).toList(growable: false));
    _prefs.saveChatSessionsJson(jsonList);
    _prefs.saveActiveChatSessionId(_activeSessionId);
  }

  Map<String, dynamic> _sessionToJson(ChatSession session) {
    return {
      'id': session.id,
      'title': session.title,
      'agentName': session.agentName,
      'updatedAt': session.updatedAt.toIso8601String(),
      'enabledToolIds': session.enabledToolIds,
      'isPinned': session.isPinned,
      'workflowCount': session.workflowCount,
      'messages': session.messages.map(_messageToJson).toList(growable: false),
    };
  }

  ChatSession _sessionFromJson(Map<String, dynamic> data) {
    return ChatSession(
      id: data['id']?.toString() ?? 'chat-${DateTime.now().millisecondsSinceEpoch}',
      title: data['title']?.toString() ?? 'New conversation',
      agentName: data['agentName']?.toString() ?? 'Weaver Agent',
      updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      messages: ((data['messages'] as List<dynamic>? ?? const [])
          .map((e) => _messageFromJson(e as Map<String, dynamic>))
          .toList()),
      enabledToolIds: ((data['enabledToolIds'] as List<dynamic>? ?? const ['gmail', 'google-drive', 'discord', 'filesystem'])
          .map((e) => e.toString())
          .toList()),
      isPinned: data['isPinned'] == true,
      workflowCount: (data['workflowCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> _messageToJson(ChatMessage msg) {
    return {
      'id': msg.id,
      'role': msg.role.name,
      'content': msg.content,
      'timestamp': msg.timestamp.toIso8601String(),
      'toolCall': msg.toolCall == null
          ? null
          : {
              'toolName': msg.toolCall!.toolName,
              'arguments': msg.toolCall!.arguments,
              'result': msg.toolCall!.result,
              'success': msg.toolCall!.success,
            },
    };
  }

  ChatMessage _messageFromJson(Map<String, dynamic> data) {
    final toolCallRaw = data['toolCall'];
    ToolCallResult? toolCall;
    if (toolCallRaw is Map<String, dynamic>) {
      toolCall = ToolCallResult(
        toolName: toolCallRaw['toolName']?.toString() ?? 'tool',
        arguments: (toolCallRaw['arguments'] as Map<String, dynamic>? ?? const {}),
        result: toolCallRaw['result']?.toString() ?? '',
        success: toolCallRaw['success'] == true,
      );
    }
    final roleName = data['role']?.toString() ?? 'assistant';
    final role = MessageRole.values.firstWhere(
      (e) => e.name == roleName,
      orElse: () => MessageRole.assistant,
    );
    return ChatMessage(
      id: data['id']?.toString() ?? 'm-${DateTime.now().millisecondsSinceEpoch}',
      role: role,
      content: data['content']?.toString() ?? '',
      timestamp: DateTime.tryParse(data['timestamp']?.toString() ?? '') ?? DateTime.now(),
      toolCall: toolCall,
    );
  }
}

// ── Tools Provider ────────────────────────────────────────────────────────────
class ToolsProvider extends ChangeNotifier {
  List<ToolModel> _tools = [];
  List<ToolModel> get tools => _tools;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  ToolCategory? _filterCategory;
  ToolCategory? get filterCategory => _filterCategory;

  String? _expandedToolId;
  String? get expandedToolId => _expandedToolId;

  BackendProvider? _backend;
  bool _loading = false;
  bool get isLoading => _loading;
  String? _lastError;
  String? get lastError => _lastError;
  final Map<String, Map<String, dynamic>> _cardMetadataByProvider = {};

  Map<String, dynamic> metadataForProvider(String provider) =>
      _cardMetadataByProvider[provider] ?? const {};

  void bindBackend(BackendProvider backend) {
    _backend = backend;
    if (_tools.isEmpty || (backend.isConnected && !_loading)) {
      refreshFromBackend();
    }
  }

  List<ToolModel> get filteredTools {
    return _tools.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _filterCategory == null || t.category == _filterCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setCategory(ToolCategory? c) {
    _filterCategory = c;
    notifyListeners();
  }

  void toggleExpanded(String toolId) {
    _expandedToolId = _expandedToolId == toolId ? null : toolId;
    notifyListeners();
  }

  void toggleEnabled(String toolId) {
    final idx = _tools.indexWhere((t) => t.id == toolId);
    if (idx == -1) return;
    _tools[idx].isEnabled = !_tools[idx].isEnabled;
    notifyListeners();
  }

  Future<void> connectTool(String toolId) async {
    final backend = _backend;
    if (backend == null) return;

    final provider = switch (toolId) {
      'gmail' || 'google-drive' => 'google',
      'discord' => 'discord',
      _ => null,
    };

    if (provider == null) return;
    _applyProviderAuth(provider, AuthStatus.pending);
    notifyListeners();

    try {
      await backend.startOAuth(provider);
      for (var i = 0; i < 120; i++) {
        await Future<void>.delayed(const Duration(seconds: 1));
        final status = await backend.fetchAuthStatus(provider);
        if (status['authenticated'] == true) {
          await backend.refreshUserInfo();
          await refreshFromBackend();
          _applyProviderAuth(provider, AuthStatus.connected);
          notifyListeners();
          return;
        }
      }
      _applyProviderAuth(provider, AuthStatus.disconnected);
      notifyListeners();
    } catch (_) {
      _applyProviderAuth(provider, AuthStatus.error);
      notifyListeners();
    }
  }

  int get connectedCount => _tools.where((t) => t.authStatus == AuthStatus.connected).length;
  int get enabledCount => _tools.where((t) => t.isEnabled).length;

  Future<void> refreshFromBackend() async {
    final backend = _backend;
    if (backend == null) return;
    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      await backend.ensureBackendRunning();
      final catalog = await backend.fetchToolCatalog();
      final cards = await backend.fetchToolStates();
      _cardMetadataByProvider
        ..clear()
        ..addEntries(cards.map((card) => MapEntry(
              card['provider']?.toString() ?? '',
              (card['metadata'] as Map<String, dynamic>? ?? const {}),
            )));
      await backend.refreshFilesystemRoot();
      await backend.refreshUserInfo();
      await backend.refreshDiscordBotStatus();
      _tools = _buildTools(catalog, cards, previous: _tools);
    } catch (exc) {
      _lastError = '$exc';
      if (_tools.isEmpty) {
        _tools = _fallbackTools();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _applyProviderAuth(String provider, AuthStatus status) {
    for (final tool in _tools) {
      final belongs = (provider == 'google' && (tool.id == 'gmail' || tool.id == 'google-drive')) ||
          (provider == 'discord' && tool.id == 'discord');
      if (!belongs) continue;
      tool.authStatus = status;
      if (status == AuthStatus.connected) {
        tool.isEnabled = true;
      }
    }
  }

  List<ToolModel> _buildTools(
    List<Map<String, dynamic>> catalog,
    List<Map<String, dynamic>> cards, {
    required List<ToolModel> previous,
  }) {
    final previousEnabled = {for (final t in previous) t.id: t.isEnabled};
    final statusByProvider = <String, AuthStatus>{
      for (final card in cards) card['provider'].toString(): _mapAuthStatus(card['status']?.toString() ?? ''),
    };

    List<ToolCapability> capsForPrefix(String prefix) {
      final matching = catalog.where((e) => (e['tool_id']?.toString() ?? '').startsWith(prefix)).toList();
      return matching
          .map((e) => ToolCapability(
                name: e['display_name']?.toString() ?? e['tool_id']?.toString() ?? 'Capability',
                description: e['description']?.toString() ?? '',
                icon: '•',
              ))
          .toList();
    }

    return [
      ToolModel(
        id: 'gmail',
        name: 'Gmail',
        description: 'Read latest emails and thread summaries via Google APIs.',
        logoEmoji: '✉️',
        category: ToolCategory.cloud,
        authStatus: statusByProvider['google'] ?? AuthStatus.disconnected,
        isEnabled: previousEnabled['gmail'] ?? true,
        capabilities: capsForPrefix('google.gmail.'),
        usageCount: 0,
        lastUsed: null,
        categoryColor: const Color(0xFF42A5F5),
        metadata: _cardMetadataByProvider['google'] ?? const {},
      ),
      ToolModel(
        id: 'google-drive',
        name: 'Google Drive',
        description: 'Browse Drive files and metadata from your connected account.',
        logoEmoji: '🗂️',
        category: ToolCategory.cloud,
        authStatus: statusByProvider['google'] ?? AuthStatus.disconnected,
        isEnabled: previousEnabled['google-drive'] ?? true,
        capabilities: capsForPrefix('google.drive.'),
        usageCount: 0,
        lastUsed: null,
        categoryColor: const Color(0xFF42A5F5),
        metadata: _cardMetadataByProvider['google'] ?? const {},
      ),
      ToolModel(
        id: 'discord',
        name: 'Discord',
        description: 'Send messages to configured channels using your bot token.',
        logoEmoji: '🎮',
        category: ToolCategory.messaging,
        authStatus: statusByProvider['discord'] ?? AuthStatus.disconnected,
        isEnabled: previousEnabled['discord'] ?? true,
        capabilities: capsForPrefix('discord.'),
        usageCount: 0,
        lastUsed: null,
        categoryColor: const Color(0xFF8B5CF6),
        metadata: _cardMetadataByProvider['discord'] ?? const {},
      ),
      ToolModel(
        id: 'filesystem',
        name: 'Filesystem',
        description: 'Read/write files in backend sandbox root.',
        logoEmoji: '🗄️',
        category: ToolCategory.files,
        authStatus: statusByProvider['filesystem'] ?? AuthStatus.connected,
        isEnabled: previousEnabled['filesystem'] ?? true,
        capabilities: capsForPrefix('filesystem.'),
        usageCount: 0,
        lastUsed: null,
        categoryColor: const Color(0xFF22C55E),
        metadata: _cardMetadataByProvider['filesystem'] ?? const {},
      ),
    ];
  }

  Future<void> setFilesystemRoot(String rootPath) async {
    final backend = _backend;
    if (backend == null) return;
    await backend.setFilesystemRoot(rootPath);
    await refreshFromBackend();
  }

  AuthStatus _mapAuthStatus(String status) {
    return switch (status) {
      'connected' => AuthStatus.connected,
      'pending' => AuthStatus.pending,
      'auth_required' || 'disconnected' => AuthStatus.disconnected,
      _ => AuthStatus.error,
    };
  }

  List<ToolModel> _fallbackTools() {
    return [
      ToolModel(
        id: 'gmail',
        name: 'Gmail',
        description: 'Connect Google OAuth to enable Gmail tools.',
        logoEmoji: '✉️',
        category: ToolCategory.cloud,
        authStatus: AuthStatus.disconnected,
        isEnabled: true,
        capabilities: const [],
        usageCount: 0,
        categoryColor: const Color(0xFF42A5F5),
      ),
      ToolModel(
        id: 'google-drive',
        name: 'Google Drive',
        description: 'Connect Google OAuth to enable Drive tools.',
        logoEmoji: '🗂️',
        category: ToolCategory.cloud,
        authStatus: AuthStatus.disconnected,
        isEnabled: true,
        capabilities: const [],
        usageCount: 0,
        categoryColor: const Color(0xFF42A5F5),
      ),
      ToolModel(
        id: 'discord',
        name: 'Discord',
        description: 'Use bot token and channel id to send messages.',
        logoEmoji: '🎮',
        category: ToolCategory.messaging,
        authStatus: AuthStatus.disconnected,
        isEnabled: true,
        capabilities: const [],
        usageCount: 0,
        categoryColor: const Color(0xFF8B5CF6),
      ),
      ToolModel(
        id: 'filesystem',
        name: 'Filesystem',
        description: 'Backend local sandbox filesystem tools.',
        logoEmoji: '🗄️',
        category: ToolCategory.files,
        authStatus: AuthStatus.connected,
        isEnabled: true,
        capabilities: const [],
        usageCount: 0,
        categoryColor: const Color(0xFF22C55E),
      ),
    ];
  }
}

// ── Workflows Provider ────────────────────────────────────────────────────────
class WorkflowsProvider extends ChangeNotifier {
  List<WorkflowModel> _workflows = MockData.workflows;
  List<WorkflowModel> get workflows => _workflows;

  String? _openWorkflowId;
  String? get openWorkflowId => _openWorkflowId;

  WorkflowModel? get openWorkflow =>
      _workflows.where((w) => w.id == _openWorkflowId).firstOrNull;

  bool _showCreateDialog = false;
  bool get showCreateDialog => _showCreateDialog;

  // Node being dragged on canvas
  String? _draggingNodeId;
  Offset _dragOffset = Offset.zero;

  void setOpenWorkflow(String id) {
    _openWorkflowId = id;
    notifyListeners();
  }

  void closeWorkflow() {
    _openWorkflowId = null;
    notifyListeners();
  }

  void toggleCreateDialog() {
    _showCreateDialog = !_showCreateDialog;
    notifyListeners();
  }

  void runWorkflow(String id) {
    final idx = _workflows.indexWhere((w) => w.id == id);
    if (idx == -1) return;
    _workflows[idx].status = WorkflowStatus.running;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _workflows[idx].status = WorkflowStatus.success;
      _workflows[idx].lastRun = DateTime.now();
      notifyListeners();
    });
  }

  void updateNodePosition(String workflowId, String nodeId, Offset pos) {
    final wfIdx = _workflows.indexWhere((w) => w.id == workflowId);
    if (wfIdx == -1) return;
    final nodeIdx = _workflows[wfIdx].nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIdx == -1) return;
    _workflows[wfIdx].nodes[nodeIdx].position = pos;
    notifyListeners();
  }

  void createWorkflow(String name, String chatSessionId) {
    final id = 'wf-new-${DateTime.now().millisecondsSinceEpoch}';
    _workflows.insert(0, WorkflowModel(
      id: id,
      name: name,
      description: 'New workflow',
      chatSessionId: chatSessionId,
      status: WorkflowStatus.draft,
      createdAt: DateTime.now(),
      runCount: 0,
      nodes: [
        WorkflowNode(
          id: 'start-trigger',
          label: 'Start',
          type: NodeType.trigger,
          toolId: 'manual',
          toolName: 'Manual',
          icon: '▶️',
          position: const Offset(80, 160),
          config: {},
          color: const Color(0xFF7B61FF),
          ports: const [WorkflowPort(id: 'out-1', label: 'start', isInput: false)],
        ),
      ],
      edges: const [],
      isActive: false,
    ));
    _openWorkflowId = id;
    _showCreateDialog = false;
    notifyListeners();
  }

  List<WorkflowModel> workflowsForSession(String sessionId) =>
      _workflows.where((w) => w.chatSessionId == sessionId).toList();

  int get activeWorkflowCount =>
      _workflows.where((w) => w.status == WorkflowStatus.running).length;
  int get totalWorkflowCount => _workflows.length;
}

// ── Model Provider ────────────────────────────────────────────────────────────
class ModelProvider extends ChangeNotifier {
  final BackendPreferences _prefs = BackendPreferences();
  bool _didLoad = false;

  String _modelName = 'gpt-4.1-mini';
  String get modelName => _modelName;

  String _systemPrompt =
      'You are Weaver, an intelligent multi-agent assistant. You have access to a rich set of tools and can help with automation, file management, communication, and research. Be concise, precise, and proactive.';
  String get systemPrompt => _systemPrompt;

  double _temperature = 0.7;
  double get temperature => _temperature;

  int _maxTokens = 4096;
  int get maxTokens => _maxTokens;

  Future<void> initialize() async {
    if (_didLoad) return;
    _didLoad = true;
    _modelName = await _prefs.loadModelName();
    _systemPrompt = await _prefs.loadSystemPrompt();
    _temperature = await _prefs.loadTemperature();
    _maxTokens = await _prefs.loadMaxTokens();
    notifyListeners();
  }

  Future<void> setModelName(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _modelName = trimmed;
    await _prefs.saveModelName(_modelName);
    notifyListeners();
  }

  Future<void> setSystemPrompt(String p) async {
    _systemPrompt = p;
    await _prefs.saveSystemPrompt(_systemPrompt);
    notifyListeners();
  }

  Future<void> setTemperature(double t) async {
    _temperature = t;
    await _prefs.saveTemperature(_temperature);
    notifyListeners();
  }

  Future<void> setMaxTokens(int t) async {
    _maxTokens = t;
    await _prefs.saveMaxTokens(_maxTokens);
    notifyListeners();
  }
}
