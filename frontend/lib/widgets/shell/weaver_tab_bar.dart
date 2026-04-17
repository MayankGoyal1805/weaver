import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';

class WeaverTabBar extends StatelessWidget {
  const WeaverTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        if (chatProvider.openTabIds.isEmpty) return const SizedBox.shrink();
        return Container(
          height: 38,
          decoration: const BoxDecoration(
            color: WeaverColors.background,
            border: Border(bottom: BorderSide(color: WeaverColors.cardBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chatProvider.openTabIds.length,
                  itemBuilder: (context, i) {
                    final sessionId = chatProvider.openTabIds[i];
                    final session = chatProvider.sessions
                        .where((s) => s.id == sessionId)
                        .firstOrNull;
                    if (session == null) return const SizedBox.shrink();
                    return _ChatTab(
                      session: session,
                      isActive: chatProvider.activeTabId == sessionId,
                      onTap: () => chatProvider.setActiveTab(sessionId),
                      onClose: () => chatProvider.closeTab(sessionId),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatTab extends StatefulWidget {
  final dynamic session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _ChatTab({required this.session, required this.isActive, required this.onTap, required this.onClose});

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  bool _hovered = false;
  bool _closeHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _closeHovered = false;
      }),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(maxWidth: 220, minWidth: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isActive ? WeaverColors.surface : Colors.transparent,
            border: Border(
              right: const BorderSide(color: WeaverColors.cardBorder),
              bottom: widget.isActive
                  ? const BorderSide(color: WeaverColors.accent, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 13,
                color: widget.isActive ? WeaverColors.accent : WeaverColors.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.session.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isActive ? WeaverColors.textPrimary : WeaverColors.textMuted,
                    fontWeight: widget.isActive ? FontWeight.w500 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              // Close button
              MouseRegion(
                onEnter: (_) => setState(() => _closeHovered = true),
                onExit: (_) => setState(() => _closeHovered = false),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _closeHovered ? WeaverColors.cardBorder : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 11,
                        color: _closeHovered ? WeaverColors.textPrimary : (_hovered ? WeaverColors.textMuted : Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
