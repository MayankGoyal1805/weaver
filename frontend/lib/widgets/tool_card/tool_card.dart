import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../common/common_widgets.dart';
import '../common/animated_widgets.dart';

class ToolCard extends StatelessWidget {
  final ToolModel tool;

  const ToolCard({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return Consumer<ToolsProvider>(
      builder: (context, provider, _) {
        final isExpanded = provider.expandedToolId == tool.id;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isExpanded ? WeaverColors.cardHover : WeaverColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpanded ? tool.categoryColor.withOpacity(0.5) : WeaverColors.cardBorder,
              width: isExpanded ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              _ToolCardHeader(tool: tool, isExpanded: isExpanded, provider: provider),
              if (isExpanded)
                _ToolCardBody(tool: tool, provider: provider)
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .slideY(begin: -0.05, end: 0, duration: 200.ms),
            ],
          ),
        );
      },
    );
  }
}

class _ToolCardHeader extends StatefulWidget {
  final ToolModel tool;
  final bool isExpanded;
  final ToolsProvider provider;

  const _ToolCardHeader({required this.tool, required this.isExpanded, required this.provider});

  @override
  State<_ToolCardHeader> createState() => _ToolCardHeaderState();
}

class _ToolCardHeaderState extends State<_ToolCardHeader> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.provider.toggleExpanded(tool.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered && !widget.isExpanded ? WeaverColors.cardHover : Colors.transparent,
            borderRadius: widget.isExpanded
                ? const BorderRadius.vertical(top: Radius.circular(12))
                : BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Logo container
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tool.categoryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: tool.categoryColor.withOpacity(0.25)),
                ),
                child: Center(child: Text(tool.logoEmoji, style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 11),
              // Name + status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tool.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WeaverColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        StatusBadge(status: tool.authStatus, compact: true),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _categoryLabel(tool.category),
                      style: TextStyle(fontSize: 11, color: tool.categoryColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // Usage count
              if (tool.usageCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: WeaverColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tool.usageCount}',
                    style: const TextStyle(fontSize: 10, color: WeaverColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Toggle switch
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: tool.isEnabled,
                  onChanged: (v) {
                    widget.provider.toggleEnabled(tool.id);
                  },
                ),
              ),
              // Expand arrow
              AnimatedRotation(
                turns: widget.isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more_rounded, color: WeaverColors.textMuted, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(ToolCategory cat) => switch (cat) {
        ToolCategory.cloud => 'Cloud',
        ToolCategory.messaging => 'Messaging',
        ToolCategory.files => 'Files',
        ToolCategory.dev => 'Development',
        ToolCategory.productivity => 'Productivity',
        ToolCategory.ai => 'AI / Web',
      };
}

class _ToolCardBody extends StatelessWidget {
  final ToolModel tool;
  final ToolsProvider provider;

  const _ToolCardBody({required this.tool, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1, color: WeaverColors.cardBorder.withOpacity(0.4)),
          const SizedBox(height: 12),

          // Description
          Text(tool.description, style: const TextStyle(fontSize: 12, color: WeaverColors.textSecondary, height: 1.5)),
          const SizedBox(height: 12),

          // Auth status bar
          _AuthStatusBar(tool: tool, provider: provider),
          if (_connectedAccount(tool).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Connected as: ${_connectedAccount(tool)}',
              style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted),
            ),
          ],
          if (tool.id == 'filesystem') ...[
            const SizedBox(height: 10),
            _FilesystemRootEditor(tool: tool, provider: provider),
          ],
          const SizedBox(height: 14),

          // Capabilities
          const Text('Capabilities', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WeaverColors.textMuted, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          ...tool.capabilities.map((cap) => _CapabilityRow(cap: cap, color: tool.categoryColor)),

          // Last used
          if (tool.lastUsed != null) ...[
            const SizedBox(height: 12),
            Container(height: 1, color: WeaverColors.cardBorder.withOpacity(0.4)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 12, color: WeaverColors.textMuted),
                const SizedBox(width: 5),
                Text('Last used ${tool.lastUsed}', style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted)),
                const Spacer(),
                Text('${tool.usageCount} calls total', style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _connectedAccount(ToolModel tool) {
    final metadata = tool.metadata;
    final profile = metadata['profile'] as Map<String, dynamic>?;
    if (profile == null) return '';
    if (tool.id == 'discord') {
      return profile['display_name']?.toString() ?? profile['username']?.toString() ?? '';
    }
    return profile['email']?.toString() ?? profile['name']?.toString() ?? '';
  }
}

class _FilesystemRootEditor extends StatefulWidget {
  final ToolModel tool;
  final ToolsProvider provider;

  const _FilesystemRootEditor({required this.tool, required this.provider});

  @override
  State<_FilesystemRootEditor> createState() => _FilesystemRootEditorState();
}

class _FilesystemRootEditorState extends State<_FilesystemRootEditor> {
  late final TextEditingController _rootController;

  @override
  void initState() {
    super.initState();
    _rootController = TextEditingController(
      text: widget.tool.metadata['allowed_root']?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _FilesystemRootEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final root = widget.tool.metadata['allowed_root']?.toString() ?? '';
    if (root.isNotEmpty && _rootController.text != root) {
      _rootController.text = root;
    }
  }

  @override
  void dispose() {
    _rootController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: WeaverColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WeaverColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Allowed Root Directory',
            style: TextStyle(fontSize: 11, color: WeaverColors.textMuted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _rootController,
            style: const TextStyle(fontSize: 12, color: WeaverColors.textPrimary),
            decoration: const InputDecoration(
              hintText: '/home/user/projects/allowed-dir',
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: ElevatedButton.icon(
              onPressed: () => widget.provider.setFilesystemRoot(_rootController.text),
              icon: const Icon(Icons.save_rounded, size: 13),
              label: const Text('Save Root', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthStatusBar extends StatelessWidget {
  final ToolModel tool;
  final ToolsProvider provider;

  const _AuthStatusBar({required this.tool, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: WeaverColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WeaverColors.cardBorder),
      ),
      child: Row(
        children: [
          StatusBadge(status: tool.authStatus),
          const Spacer(),
          if (tool.authStatus == AuthStatus.disconnected)
            SizedBox(
              height: 28,
              child: ElevatedButton.icon(
                onPressed: () => provider.connectTool(tool.id),
                icon: const Icon(Icons.link_rounded, size: 13),
                label: const Text('Connect', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
              ),
            )
          else if (tool.authStatus == AuthStatus.pending)
            const SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: WeaverColors.warning),
            )
          else if (tool.authStatus == AuthStatus.connected)
            SizedBox(
              height: 28,
              child: OutlinedButton.icon(
                onPressed: () => Provider.of<AppState>(context, listen: false).setNavIndex(3),
                icon: const Icon(Icons.settings_rounded, size: 12),
                label: const Text('Settings', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
              ),
            ),
        ],
      ),
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  final ToolCapability cap;
  final Color color;

  const _CapabilityRow({required this.cap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(child: Text(cap.icon, style: const TextStyle(fontSize: 12))),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cap.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: WeaverColors.textPrimary)),
                Text(cap.description, style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
