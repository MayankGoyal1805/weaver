import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../models/models.dart';
import '../common/animated_widgets.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Container(
          width: appState.leftSidebarOpen ? 260 : 64,
          decoration: const BoxDecoration(
            color: WeaverColors.surface,
            border: Border(right: BorderSide(color: WeaverColors.cardBorder)),
          ),
          child: Column(
            children: [
              // Logo
              _LogoSection(collapsed: !appState.leftSidebarOpen, onToggle: appState.toggleLeftSidebar),
              // Nav rail items
              _NavSection(collapsed: !appState.leftSidebarOpen, appState: appState),
              const SizedBox(height: 8),
              Container(height: 1, color: WeaverColors.cardBorder),
              // Chat list (only when expanded)
              if (appState.leftSidebarOpen)
                const Expanded(child: _ChatListSection()),
            ],
          ),
        );
      },
    );
  }
}

class _LogoSection extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;

  const _LogoSection({required this.collapsed, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        height: 56,
        padding: collapsed ? const EdgeInsets.symmetric(horizontal: 14) : const EdgeInsets.symmetric(horizontal: 16),
        alignment: collapsed ? Alignment.center : Alignment.centerLeft,
        child: Row(
          children: [
            WeaverLogo(size: 32, showLabel: !collapsed),
          ],
        ),
      ),
    );
  }
}

class _NavSection extends StatelessWidget {
  final bool collapsed;
  final AppState appState;

  const _NavSection({required this.collapsed, required this.appState});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.chat_bubble_rounded, label: 'Chats', index: 0),
      (icon: Icons.dashboard_rounded, label: 'Dashboard', index: 1),
      (icon: Icons.account_tree_rounded, label: 'Workflows', index: 2),
      (icon: Icons.settings_rounded, label: 'Settings', index: 3),
    ];

    return Column(
      children: items.map((item) => _NavItem(
        icon: item.icon,
        label: item.label,
        index: item.index,
        collapsed: collapsed,
        appState: appState,
      )).toList(),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool collapsed;
  final AppState appState;

  const _NavItem({required this.icon, required this.label, required this.index, required this.collapsed, required this.appState});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.appState.navIndex == widget.index;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.collapsed ? widget.label : '',
        child: GestureDetector(
          onTap: () => widget.appState.setNavIndex(widget.index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? WeaverColors.accentGlow
                  : _hovered
                      ? WeaverColors.cardHover
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: selected ? Border.all(color: WeaverColors.accent.withOpacity(0.3)) : null,
            ),
            child: widget.collapsed
                ? Center(child: Icon(widget.icon, color: selected ? WeaverColors.accent : WeaverColors.textMuted, size: 20))
                : Row(
                    children: [
                      Icon(widget.icon, color: selected ? WeaverColors.accent : WeaverColors.textMuted, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? WeaverColors.accent : WeaverColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Chat List Section ──────────────────────────────────────────────────────────
class _ChatListSection extends StatelessWidget {
  const _ChatListSection();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, AppState>(
      builder: (context, chatProvider, appState, _) {
        final sessions = chatProvider.sessions;
        final pinned = sessions.where((s) => s.isPinned).toList();
        final today = sessions.where((s) {
          final diff = DateTime.now().difference(s.updatedAt);
          return !s.isPinned && diff.inHours < 24;
        }).toList();
        final older = sessions.where((s) {
          final diff = DateTime.now().difference(s.updatedAt);
          return !s.isPinned && diff.inHours >= 24;
        }).toList();

        return Column(
          children: [
            // New chat button
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    chatProvider.newChat();
                    appState.setNavIndex(0);
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('New Chat'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  if (pinned.isNotEmpty) ...[
                    _SectionLabel('Pinned'),
                    ...pinned.map((s) => _ChatSessionTile(session: s)),
                  ],
                  if (today.isNotEmpty) ...[
                    _SectionLabel('Today'),
                    ...today.map((s) => _ChatSessionTile(session: s)),
                  ],
                  if (older.isNotEmpty) ...[
                    _SectionLabel('Earlier'),
                    ...older.map((s) => _ChatSessionTile(session: s)),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: WeaverColors.textDisabled, letterSpacing: 1),
      ),
    );
  }
}

class _ChatSessionTile extends StatefulWidget {
  final ChatSession session;
  const _ChatSessionTile({required this.session});

  @override
  State<_ChatSessionTile> createState() => _ChatSessionTileState();
}

class _ChatSessionTileState extends State<_ChatSessionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, AppState>(
      builder: (context, chatProv, appState, _) {
        final isActive = chatProv.activeSessionId == widget.session.id;
        return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              chatProv.openSession(widget.session.id);
              appState.setNavIndex(0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? WeaverColors.accentGlow
                    : _hovered
                        ? WeaverColors.cardHover
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isActive ? Border.all(color: WeaverColors.accent.withOpacity(0.3)) : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.session.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                            color: isActive ? WeaverColors.textPrimary : WeaverColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              _formatTime(widget.session.updatedAt),
                              style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted),
                            ),
                            if (widget.session.workflowCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 4, height: 4,
                                decoration: const BoxDecoration(color: WeaverColors.textDisabled, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.account_tree_rounded, size: 11, color: WeaverColors.accent.withOpacity(0.6)),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.session.workflowCount}',
                                style: TextStyle(fontSize: 11, color: WeaverColors.accent.withOpacity(0.6)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.session.isPinned)
                    const Icon(Icons.push_pin_rounded, size: 12, color: WeaverColors.accent),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
