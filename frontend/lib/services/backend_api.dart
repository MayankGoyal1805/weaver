import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class BackendApi {
  BackendApi(this.baseUrl);

  String baseUrl;

  Uri _uri(String path) {
    final normalized = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$normalized$path');
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final res = await http.get(_uri(path));
    if (res.statusCode >= 400) {
      throw Exception('HTTP ${res.statusCode} from $path: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getJsonList(String path) async {
    final res = await http.get(_uri(path));
    if (res.statusCode >= 400) {
      throw Exception('HTTP ${res.statusCode} from $path: ${res.body}');
    }
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> payload) async {
    final res = await http.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 400) {
      throw Exception('HTTP ${res.statusCode} from $path: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

class BackendRuntime {
  Process? _process;
  bool _startedByApp = false;

  bool get startedByApp => _startedByApp;

  Future<bool> isHealthy(String baseUrl) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> ensureRunning(String baseUrl) async {
    if (kIsWeb) return;
    if (await isHealthy(baseUrl)) return;

    final parsed = Uri.parse(baseUrl);
    final host = parsed.host;
    final port = parsed.port == 0 ? 8000 : parsed.port;

    final backendDir = _resolveBackendDir();
    if (backendDir == null) {
      throw Exception('Could not locate backend directory for auto-start.');
    }

    final args = [
      '--project',
      backendDir.path,
      'run',
      'uvicorn',
      'app.main:app',
      '--app-dir',
      backendDir.path,
      '--host',
      host,
      '--port',
      '$port',
    ];

    _process = await Process.start('uv', args, workingDirectory: backendDir.path);
    _startedByApp = true;

    unawaited(_process!.stdout.transform(utf8.decoder).forEach((_) {}));
    unawaited(_process!.stderr.transform(utf8.decoder).forEach((_) {}));

    for (var i = 0; i < 80; i++) {
      if (await isHealthy(baseUrl)) return;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    throw Exception('Backend auto-start timed out for $baseUrl');
  }

  Future<void> stop() async {
    final p = _process;
    if (p == null) return;
    p.kill(ProcessSignal.sigterm);
    _process = null;
    _startedByApp = false;
  }

  Directory? _resolveBackendDir() {
    final cwd = Directory.current;
    final candidates = <Directory>[
      Directory('${cwd.path}/../backend'),
      Directory('${cwd.path}/backend'),
      Directory('/home/mayank/repos/weaver/backend'),
    ];

    for (final dir in candidates) {
      if (File('${dir.path}/pyproject.toml').existsSync()) {
        return dir;
      }
    }
    return null;
  }
}

class BackendPreferences {
  static const _keyBaseUrl = 'backend.baseUrl';
  static const _keyAutoStart = 'backend.autoStart';
  static const _keyDiscordChannelId = 'backend.discordChannelId';
  static const _keyLlmApiKey = 'backend.llmApiKey';
  static const _keyLlmBaseUrl = 'backend.llmBaseUrl';
  static const _keyFilesystemRoot = 'backend.filesystemRoot';
  static const _keyChatSessions = 'chat.sessions.v1';
  static const _keyChatActiveSession = 'chat.activeSession.v1';

  Future<String> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBaseUrl) ?? 'http://127.0.0.1:8000';
  }

  Future<void> saveBaseUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, value);
  }

  Future<bool> loadAutoStart() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoStart) ?? true;
  }

  Future<void> saveAutoStart(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoStart, value);
  }

  Future<String> loadDiscordChannelId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDiscordChannelId) ?? '';
  }

  Future<void> saveDiscordChannelId(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDiscordChannelId, value);
  }

  Future<String> loadLlmApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLlmApiKey) ?? '';
  }

  Future<void> saveLlmApiKey(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLlmApiKey, value);
  }

  Future<String> loadLlmBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLlmBaseUrl) ?? 'https://api.openai.com/v1';
  }

  Future<void> saveLlmBaseUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLlmBaseUrl, value);
  }

  Future<String> loadFilesystemRoot() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFilesystemRoot) ?? '';
  }

  Future<void> saveFilesystemRoot(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFilesystemRoot, value);
  }

  Future<String> loadChatSessionsJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyChatSessions) ?? '';
  }

  Future<void> saveChatSessionsJson(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyChatSessions, value);
  }

  Future<String?> loadActiveChatSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyChatActiveSession);
  }

  Future<void> saveActiveChatSessionId(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.isEmpty) {
      await prefs.remove(_keyChatActiveSession);
      return;
    }
    await prefs.setString(_keyChatActiveSession, value);
  }
}

Future<void> openExternalUrl(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
