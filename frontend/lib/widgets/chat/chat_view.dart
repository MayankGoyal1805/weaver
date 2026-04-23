import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../models/models.dart';
import 'dart:convert';

import '../common/animated_widgets.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final session = chatProvider.activeSession;
        if (session == null) {
          return const _EmptyChatState();
        }
        return Column(
          children: [
            _ChatHeader(session: session),
            const _ToolChipStrip(),
            const Divider(height: 1),
            Expanded(child: _MessageList(session: session)),
            if (chatProvider.isTypingFor(session.id))
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TypingIndicator(agentName: session.agentName),
                ),
              ),
            _ChatInput(session: session),
          ],
        );
      },
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: WeaverColors.accentGlow,
              shape: BoxShape.circle,
              border: Border.all(color: WeaverColors.accent.withOpacity(0.3)),
            ),
            child: const Center(
              child: Text('⟆',
                  style: TextStyle(fontSize: 36, color: WeaverColors.accent)),
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'Start a conversation',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: WeaverColors.textPrimary),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          const Text(
            'Select a chat from the sidebar or create a new one',
            style: TextStyle(color: WeaverColors.textMuted, fontSize: 14),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 28),
          Consumer<ChatProvider>(
            builder: (ctx, chatProv, _) => ElevatedButton.icon(
              onPressed: () {
                chatProv.newChat();
                Provider.of<AppState>(ctx, listen: false).setNavIndex(0);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Chat'),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final ChatSession session;
  const _ChatHeader({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: WeaverColors.cardBorder)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: WeaverColors.textPrimary)),
              Consumer<ModelProvider>(
                builder: (_, modelProv, __) => Text(
                  '${session.agentName} • ${modelProv.modelName}',
                  style: const TextStyle(
                      fontSize: 11, color: WeaverColors.textMuted),
                ),
              ),
            ],
          ),
          const Spacer(),
          Consumer<WorkflowsProvider>(
            builder: (ctx, wfProv, _) {
              final count = wfProv.workflowsForSession(session.id).length;
              return TextButton.icon(
                onPressed: () {
                  Provider.of<AppState>(ctx, listen: false).setRightPanelTab(1);
                  wfProv.toggleCreateDialog();
                },
                icon: const Icon(Icons.account_tree_rounded, size: 14),
                label: Text(count > 0 ? '$count workflows' : 'Add workflow'),
                style: TextButton.styleFrom(
                    foregroundColor: WeaverColors.accent,
                    textStyle: const TextStyle(fontSize: 12)),
              );
            },
          ),
          const SizedBox(width: 4),
          Consumer<AppState>(
            builder: (ctx, appState, _) => IconButton(
              tooltip: 'Right panel',
              onPressed: appState.toggleRightSidebar,
              icon: const Icon(Icons.view_sidebar_outlined, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolChipStrip extends StatelessWidget {
  const _ToolChipStrip();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, ToolsProvider>(
      builder: (context, chatProv, toolsProv, _) {
        final session = chatProv.activeSession;
        if (session == null) return const SizedBox.shrink();
        final enabledTools = toolsProv.tools
            .where((t) => session.enabledToolIds.contains(t.id))
            .toList();

        return Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const Text('Tools:',
                  style: TextStyle(
                      fontSize: 12,
                      color: WeaverColors.textMuted,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...enabledTools
                        .map((t) => _ToolChip(tool: t, enabled: true)),
                    _AddToolChip(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToolChip extends StatefulWidget {
  final ToolModel tool;
  final bool enabled;
  const _ToolChip({required this.tool, required this.enabled});

  @override
  State<_ToolChip> createState() => _ToolChipState();
}

class _ToolChipState extends State<_ToolChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Provider.of<AppState>(context, listen: false).setRightPanelTab(0);
          Provider.of<ToolsProvider>(context, listen: false)
              .toggleExpanded(widget.tool.id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.tool.categoryColor.withOpacity(0.15)
                : widget.tool.categoryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: widget.tool.categoryColor
                    .withOpacity(_hovered ? 0.5 : 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.tool.logoEmoji, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 5),
              Text(widget.tool.name,
                  style: TextStyle(
                      fontSize: 11,
                      color: widget.tool.categoryColor,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddToolChip extends StatefulWidget {
  @override
  State<_AddToolChip> createState() => _AddToolChipState();
}

class _AddToolChipState extends State<_AddToolChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () =>
            Provider.of<AppState>(context, listen: false).setRightPanelTab(0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _hovered ? WeaverColors.cardHover : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: WeaverColors.cardBorder, style: BorderStyle.solid),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 12, color: WeaverColors.textMuted),
              SizedBox(width: 4),
              Text('Add tool',
                  style:
                      TextStyle(fontSize: 11, color: WeaverColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageList extends StatefulWidget {
  final ChatSession session;
  const _MessageList({required this.session});

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(_MessageList old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.session.messages;
    if (messages.isEmpty) {
      return const _WelcomePanel();
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, i) => MessageBubble(message: messages[i])
          .animate()
          .fadeIn(duration: 250.ms)
          .slideY(begin: 0.05, end: 0, duration: 250.ms),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      '📧 Fetch my latest emails and summarize them',
      '📁 List files in my Google Drive /Projects folder',
      '🎮 Fetch latest Gmail and send it to Discord',
      '🗄️ List files in backend sandbox root',
    ];
    return Center(
      child: SizedBox(
        width: 560,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('What can I help you with?',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: WeaverColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Use the tools in the right panel or ask me anything.',
                style: TextStyle(fontSize: 14, color: WeaverColors.textMuted)),
            const SizedBox(height: 28),
            ...suggestions.asMap().entries.map((e) => _SuggestionCard(
                  label: e.value,
                  delay: e.key * 60,
                )),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatefulWidget {
  final String label;
  final int delay;
  const _SuggestionCard({required this.label, required this.delay});

  @override
  State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Provider.of<ChatProvider>(context, listen: false)
              .inputController
              .text = widget.label.substring(2).trim();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? WeaverColors.cardHover : WeaverColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? WeaverColors.accent.withOpacity(0.4)
                  : WeaverColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                  child: Text(widget.label,
                      style: const TextStyle(
                          fontSize: 13, color: WeaverColors.textSecondary))),
              Icon(Icons.arrow_forward_rounded,
                  size: 15,
                  color: _hovered
                      ? WeaverColors.accent
                      : WeaverColors.textDisabled),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.delay)).slideY(
        begin: 0.1, end: 0, delay: Duration(milliseconds: widget.delay));
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isUser
          ? _UserBubble(message: message)
          : _AssistantBubble(message: message),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: WeaverColors.accentGlow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
              border: Border.all(color: WeaverColors.accent.withOpacity(0.3)),
            ),
            child: SelectableText(message.content,
                style: const TextStyle(
                    fontSize: 14,
                    color: WeaverColors.textPrimary,
                    height: 1.5)),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: WeaverColors.accent,
            shape: BoxShape.circle,
          ),
          child: const Center(
              child: Text('M',
                  style: TextStyle(
                      color: WeaverColors.background,
                      fontWeight: FontWeight.bold,
                      fontSize: 14))),
        ),
      ],
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  final ChatMessage message;
  const _AssistantBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: WeaverColors.accentGlow,
            shape: BoxShape.circle,
            border: Border.all(color: WeaverColors.accent.withOpacity(0.4)),
          ),
          child: const Center(
              child: Text('W',
                  style: TextStyle(
                      color: WeaverColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: WeaverColors.card,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: WeaverColors.cardBorder),
                ),
                child: _buildBlockList(message),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(message.timestamp),
                style: const TextStyle(
                    fontSize: 10, color: WeaverColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlockList(ChatMessage message) {
    // New: ordered blocks list
    if (message.blocks.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: message.blocks.map<Widget>((block) {
          if (block is ToolCallBlock) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ToolCallCard(toolCall: block.toolCall),
            );
          } else if (block is TextBlock && block.text.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(
                // Add top padding if there was a tool call before this
                top: message.blocks.indexOf(block) > 0 ? 4 : 0,
              ),
              child: _AssistantMessageContent(text: block.text),
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      );
    }
    // Legacy fallback: single toolCall + content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.toolCall != null) ...[
          _ToolCallCard(toolCall: message.toolCall!),
          const SizedBox(height: 8),
        ],
        if (message.content.isNotEmpty)
          _AssistantMessageContent(text: message.content),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}


class _ToolCallCard extends StatefulWidget {
  final ToolCallResult toolCall;
  const _ToolCallCard({required this.toolCall});

  @override
  State<_ToolCallCard> createState() => _ToolCallCardState();
}

class _ToolCallCardState extends State<_ToolCallCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final argsString = widget.toolCall.arguments.isEmpty 
        ? '{}' 
        : jsonEncode(widget.toolCall.arguments);
        
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: WeaverColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.toolCall.success
              ? WeaverColors.success.withOpacity(0.4)
              : WeaverColors.error.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.expand_more_rounded : Icons.chevron_right_rounded,
                    size: 16,
                    color: WeaverColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    widget.toolCall.success ? Icons.bolt_rounded : Icons.error_outline_rounded,
                    size: 14,
                    color: widget.toolCall.success ? WeaverColors.success : WeaverColors.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.toolCall.toolName,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WeaverColors.textSecondary,
                        fontFamily: 'JetBrainsMono'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      argsString,
                      style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted, fontFamily: 'JetBrainsMono'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.toolCall.success
                          ? WeaverColors.successDim
                          : WeaverColors.errorDim,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.toolCall.success ? 'OK' : 'ERR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: widget.toolCall.success
                            ? WeaverColors.success
                            : WeaverColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: WeaverColors.cardBorder)),
                color: WeaverColors.card.withOpacity(0.5),
              ),
              child: SelectableText(
                widget.toolCall.result,
                style: const TextStyle(
                  fontSize: 11,
                  color: WeaverColors.textSecondary,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssistantMessageContent extends StatelessWidget {
  final String text;
  const _AssistantMessageContent({required this.text});

  @override
  Widget build(BuildContext context) {
    final parsed = _ParsedAssistantBody.parse(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final think in parsed.thinkBlocks) ...[
          _ThinkBlock(content: think),
          const SizedBox(height: 10),
        ],
        for (final tool in parsed.toolBlocks) ...[
          _InlineToolBlock(content: tool),
          const SizedBox(height: 10),
        ],
        _MarkdownText(text: parsed.visibleMarkdown),
      ],
    );
  }
}

class _ThinkBlock extends StatefulWidget {
  final String content;
  const _ThinkBlock({required this.content});

  @override
  State<_ThinkBlock> createState() => _ThinkBlockState();
}

class _ThinkBlockState extends State<_ThinkBlock> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: WeaverColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WeaverColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 16,
                    color: WeaverColors.warning,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Thinking',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: WeaverColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _MarkdownText(text: widget.content),
            ),
        ],
      ),
    );
  }
}

class _InlineToolBlock extends StatelessWidget {
  final String content;
  const _InlineToolBlock({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: WeaverColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WeaverColors.accent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tool Output',
            style: TextStyle(
              fontSize: 11,
              color: WeaverColors.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          _MarkdownText(text: content),
        ],
      ),
    );
  }
}

class _MarkdownText extends StatelessWidget {
  final String text;
  const _MarkdownText({required this.text});

  @override
  Widget build(BuildContext context) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) {
      return const SizedBox.shrink();
    }
    return MarkdownBody(
      data: cleaned,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          fontSize: 14,
          color: WeaverColors.textPrimary,
          height: 1.55,
        ),
        code: const TextStyle(
          fontSize: 12,
          color: WeaverColors.textPrimary,
          fontFamily: 'JetBrainsMono',
        ),
        codeblockPadding: const EdgeInsets.all(10),
        codeblockDecoration: BoxDecoration(
          color: WeaverColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: WeaverColors.cardBorder),
        ),
        blockquote: const TextStyle(
          color: WeaverColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _ParsedAssistantBody {
  final String visibleMarkdown;
  final List<String> thinkBlocks;
  final List<String> toolBlocks;

  const _ParsedAssistantBody({
    required this.visibleMarkdown,
    required this.thinkBlocks,
    required this.toolBlocks,
  });

  static _ParsedAssistantBody parse(String raw) {
    var remaining = raw;
    final thinkBlocks = <String>[];
    final toolBlocks = <String>[];

    final thinkRegex = RegExp(r'<think>([\s\S]*?)</think>', caseSensitive: false);
    remaining = remaining.replaceAllMapped(thinkRegex, (m) {
      final content = (m.group(1) ?? '').trim();
      if (content.isNotEmpty) {
        thinkBlocks.add(content);
      }
      return '';
    });

    final toolFenceRegex = RegExp(
      r'```(?:tool|tools|tool_call|tool-result|tool_result)\s*\n([\s\S]*?)```',
      caseSensitive: false,
    );
    remaining = remaining.replaceAllMapped(toolFenceRegex, (m) {
      final content = (m.group(1) ?? '').trim();
      if (content.isNotEmpty) {
        toolBlocks.add(content);
      }
      return '';
    });

    return _ParsedAssistantBody(
      visibleMarkdown: remaining.trim(),
      thinkBlocks: thinkBlocks,
      toolBlocks: toolBlocks,
    );
  }
}

class _ChatInput extends StatefulWidget {
  final ChatSession session;
  const _ChatInput({required this.session});

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          final isShift = HardwareKeyboard.instance.isShiftPressed;
          final isCtrl = HardwareKeyboard.instance.isControlPressed;
          if (isShift || isCtrl) {
            return KeyEventResult.ignored; // allow new line
          } else {
            final chatProv = Provider.of<ChatProvider>(context, listen: false);
            if (chatProv.inputController.text.trim().isNotEmpty) {
              chatProv.sendMessage(chatProv.inputController.text);
            }
            return KeyEventResult.handled; // prevent new line
          }
        }
        return KeyEventResult.ignored;
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProv, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: WeaverColors.cardBorder)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: WeaverColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: WeaverColors.cardBorder),
            ),
            child: Column(
              children: [
                TextField(
                  controller: chatProv.inputController,
                  focusNode: _focusNode,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                      fontSize: 14,
                      color: WeaverColors.textPrimary,
                      height: 1.5),
                  decoration: const InputDecoration(
                    hintText: 'Message Weaver... (Shift+Enter for new line)',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                    fillColor: Colors.transparent,
                    filled: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Row(
                    children: [
                      // Quick action buttons
                      _InputAction(
                          icon: Icons.attach_file_rounded,
                          tooltip: 'Attach file'),
                      _InputAction(
                          icon: Icons.account_tree_rounded,
                          tooltip: 'Create workflow',
                          onTap: () {
                            Provider.of<AppState>(context, listen: false)
                                .setRightPanelTab(1);
                            Provider.of<WorkflowsProvider>(context,
                                    listen: false)
                                .toggleCreateDialog();
                          }),
                      _InputAction(
                          icon: Icons.code_rounded, tooltip: 'Code mode'),
                      const Spacer(),
                      // Model indicator
                      Consumer<ModelProvider>(
                        builder: (ctx, modelProv, _) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: WeaverColors.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            modelProv.modelName,
                            style: const TextStyle(
                                fontSize: 11,
                                color: WeaverColors.textMuted,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send button
                      GestureDetector(
                        onTap: () =>
                            chatProv.sendMessage(chatProv.inputController.text),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: WeaverColors.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_upward_rounded,
                                color: WeaverColors.background, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InputAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  const _InputAction({required this.icon, required this.tooltip, this.onTap});

  @override
  State<_InputAction> createState() => _InputActionState();
}

class _InputActionState extends State<_InputAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.only(right: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _hovered ? WeaverColors.cardHover : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(widget.icon,
                size: 15,
                color: _hovered
                    ? WeaverColors.textSecondary
                    : WeaverColors.textMuted),
          ),
        ),
      ),
    );
  }
}
