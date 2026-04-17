import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _discordChannelController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final backend = context.read<BackendProvider>();
    _baseUrlController.text = backend.baseUrl;
    _discordChannelController.text = backend.discordChannelId;
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _discordChannelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BackendProvider, ToolsProvider>(
      builder: (context, backend, tools, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: WeaverColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Configure backend, auth flows, and tool defaults.',
                style: TextStyle(fontSize: 13, color: WeaverColors.textMuted),
              ),
              const SizedBox(height: 28),
              _Section(
                title: 'Backend Runtime',
                icon: Icons.dns_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledField(
                      label: 'API Base URL',
                      controller: _baseUrlController,
                      hint: 'http://127.0.0.1:8000',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await backend.setBaseUrl(_baseUrlController.text);
                            await tools.refreshFromBackend();
                          },
                          icon: const Icon(Icons.save_rounded, size: 14),
                          label: const Text('Save URL'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await backend.ensureBackendRunning();
                            await tools.refreshFromBackend();
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 14),
                          label: const Text('Start Backend'),
                        ),
                        const Spacer(),
                        _ConnectionPill(
                          connected: backend.isConnected,
                          starting: backend.isStarting,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Auto-start backend with app', style: TextStyle(color: WeaverColors.textSecondary, fontSize: 13)),
                        const Spacer(),
                        Switch(
                          value: backend.autoStartBackend,
                          onChanged: (v) => backend.setAutoStartBackend(v),
                        ),
                      ],
                    ),
                    if (backend.lastError != null && backend.lastError!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          backend.lastError!,
                          style: const TextStyle(fontSize: 12, color: WeaverColors.error),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Auth & Tools',
                icon: Icons.key_rounded,
                child: Column(
                  children: [
                    _AuthRow(
                      title: 'Google OAuth (Gmail + Drive)',
                      status: _googleStatus(tools),
                      onConnect: () => tools.connectTool('gmail'),
                    ),
                    const SizedBox(height: 10),
                    _AuthRow(
                      title: 'Discord Bot / OAuth',
                      status: _findTool(tools, 'discord')?.authStatus,
                      onConnect: () => tools.connectTool('discord'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => tools.refreshFromBackend(),
                          icon: const Icon(Icons.refresh_rounded, size: 14),
                          label: const Text('Refresh Tool Status'),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tools.lastError ?? '',
                          style: const TextStyle(fontSize: 12, color: WeaverColors.error),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Agent Defaults',
                icon: Icons.smart_toy_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledField(
                      label: 'Default Discord Channel ID',
                      controller: _discordChannelController,
                      hint: '1494502217703620731',
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => backend.setDiscordChannelId(_discordChannelController.text),
                      icon: const Icon(Icons.save_rounded, size: 14),
                      label: const Text('Save Channel ID'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This channel is used when prompt includes Discord send intent.',
                      style: TextStyle(fontSize: 12, color: WeaverColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ToolModel? _findTool(ToolsProvider tools, String id) {
    for (final t in tools.tools) {
      if (t.id == id) return t;
    }
    return null;
  }

  AuthStatus _googleStatus(ToolsProvider tools) {
    final gmail = _findTool(tools, 'gmail')?.authStatus;
    final drive = _findTool(tools, 'google-drive')?.authStatus;
    if (gmail == AuthStatus.connected && drive == AuthStatus.connected) {
      return AuthStatus.connected;
    }
    if (gmail == AuthStatus.pending || drive == AuthStatus.pending) {
      return AuthStatus.pending;
    }
    if (gmail == AuthStatus.error || drive == AuthStatus.error) {
      return AuthStatus.error;
    }
    return AuthStatus.disconnected;
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Section({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WeaverColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WeaverColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: WeaverColors.accent),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _LabeledField({required this.label, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: WeaverColors.textMuted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 12, color: WeaverColors.textPrimary),
          decoration: InputDecoration(hintText: hint, isDense: true),
        ),
      ],
    );
  }
}

class _ConnectionPill extends StatelessWidget {
  final bool connected;
  final bool starting;

  const _ConnectionPill({required this.connected, required this.starting});

  @override
  Widget build(BuildContext context) {
    if (starting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: WeaverColors.warningDim,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: WeaverColors.warning.withOpacity(0.4)),
        ),
        child: const Text('Starting...', style: TextStyle(fontSize: 11, color: WeaverColors.warning, fontWeight: FontWeight.w600)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: connected ? WeaverColors.successDim : WeaverColors.errorDim,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (connected ? WeaverColors.success : WeaverColors.error).withOpacity(0.4)),
      ),
      child: Text(
        connected ? 'Connected' : 'Disconnected',
        style: TextStyle(fontSize: 11, color: connected ? WeaverColors.success : WeaverColors.error, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AuthRow extends StatelessWidget {
  final String title;
  final AuthStatus? status;
  final Future<void> Function() onConnect;

  const _AuthRow({required this.title, required this.status, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = status ?? AuthStatus.disconnected;
    final (label, color) = switch (effectiveStatus) {
      AuthStatus.connected => ('Connected', WeaverColors.success),
      AuthStatus.pending => ('Pending', WeaverColors.warning),
      AuthStatus.error => ('Error', WeaverColors.error),
      AuthStatus.disconnected => ('Disconnected', WeaverColors.textMuted),
    };

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: WeaverColors.textPrimary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
        if (effectiveStatus == AuthStatus.connected)
          OutlinedButton(
            onPressed: onConnect,
            child: const Text('Reconnect'),
          )
        else
          ElevatedButton(
            onPressed: onConnect,
            child: const Text('Connect'),
          ),
      ],
    );
  }
}
