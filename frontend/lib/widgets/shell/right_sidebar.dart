import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../models/models.dart';
import '../tool_card/tool_card.dart';
import '../common/common_widgets.dart';
import '../workflow/workflow_list_panel.dart';
import '../chat/model_panel.dart';

class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (!appState.rightSidebarOpen) return const SizedBox.shrink();
        return Container(
          width: 320,
          decoration: const BoxDecoration(
            color: WeaverColors.surface,
            border: Border(left: BorderSide(color: WeaverColors.cardBorder)),
          ),
          child: Column(
            children: [
              // Panel tab bar
              _RightSidebarTabBar(appState: appState),
              const SizedBox(height: 1),
              // Content
              Expanded(
                child: IndexedStack(
                  index: appState.rightPanelTab,
                  children: const [
                    _ToolsPanel(),
                    WorkflowListPanel(),
                    ModelPanel(),
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

class _RightSidebarTabBar extends StatelessWidget {
  final AppState appState;
  const _RightSidebarTabBar({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: WeaverColors.cardBorder)),
      ),
      child: Row(
        children: [
          _TabButton(label: 'Tools', icon: Icons.extension_rounded, index: 0, current: appState.rightPanelTab, onTap: () => appState.setRightPanelTab(0)),
          const SizedBox(width: 4),
          _TabButton(label: 'Workflows', icon: Icons.account_tree_rounded, index: 1, current: appState.rightPanelTab, onTap: () => appState.setRightPanelTab(1)),
          const SizedBox(width: 4),
          _TabButton(label: 'Model', icon: Icons.psychology_rounded, index: 2, current: appState.rightPanelTab, onTap: () => appState.setRightPanelTab(2)),
          const Spacer(),
          IconButton(
            onPressed: appState.toggleRightSidebar,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            style: IconButton.styleFrom(
              minimumSize: const Size(28, 28),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final int index;
  final int current;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.icon, required this.index, required this.current, required this.onTap});

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.index == widget.current;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? WeaverColors.accentGlow : (_hovered ? WeaverColors.cardHover : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
            border: selected ? Border.all(color: WeaverColors.accent.withOpacity(0.4)) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 13, color: selected ? WeaverColors.accent : WeaverColors.textMuted),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? WeaverColors.accent : WeaverColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tools Panel ───────────────────────────────────────────────────────────────
class _ToolsPanel extends StatelessWidget {
  const _ToolsPanel();

  @override
  Widget build(BuildContext context) {
    return Consumer<ToolsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.tools.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Search + stats
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                children: [
                  if (provider.lastError != null && provider.lastError!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: WeaverColors.errorDim,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: WeaverColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 14, color: WeaverColors.error),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              provider.lastError!,
                              style: const TextStyle(fontSize: 11, color: WeaverColors.error),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: provider.refreshFromBackend,
                            child: const Icon(Icons.refresh_rounded, size: 14, color: WeaverColors.error),
                          ),
                        ],
                      ),
                    ),
                  // stats
                  Row(
                    children: [
                      _StatPill(label: '${provider.connectedCount} connected', color: WeaverColors.success),
                      const SizedBox(width: 6),
                      _StatPill(label: '${provider.enabledCount} active', color: WeaverColors.accent),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Refresh tools',
                        onPressed: provider.refreshFromBackend,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        style: IconButton.styleFrom(minimumSize: const Size(24, 24), padding: EdgeInsets.zero),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Search
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search tools...',
                      prefixIcon: Icon(Icons.search_rounded, size: 17),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: provider.setSearch,
                  ),
                  const SizedBox(height: 8),
                  // Category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryChip(
                          label: 'All',
                          isSelected: provider.filterCategory == null,
                          onTap: () => provider.setCategory(null),
                          color: WeaverColors.accent,
                        ),
                        const SizedBox(width: 4),
                        ...ToolCategory.values.map((c) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: CategoryChip(
                            label: _catLabel(c),
                            isSelected: provider.filterCategory == c,
                            onTap: () => provider.setCategory(provider.filterCategory == c ? null : c),
                            color: _catColor(c),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: WeaverColors.cardBorder.withOpacity(0.4)),
            // Tool list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: provider.filteredTools.length,
                itemBuilder: (context, i) => ToolCard(tool: provider.filteredTools[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  String _catLabel(ToolCategory c) => switch (c) {
        ToolCategory.cloud => 'Cloud',
        ToolCategory.messaging => 'Messaging',
        ToolCategory.files => 'Files',
        ToolCategory.dev => 'Dev',
        ToolCategory.productivity => 'Productivity',
        ToolCategory.ai => 'AI',
      };

  Color _catColor(ToolCategory c) => switch (c) {
        ToolCategory.cloud => WeaverColors.cloudColor,
        ToolCategory.messaging => WeaverColors.messagingColor,
        ToolCategory.files => WeaverColors.filesColor,
        ToolCategory.dev => WeaverColors.devColor,
        ToolCategory.productivity => WeaverColors.productivityColor,
        ToolCategory.ai => WeaverColors.accentBright,
      };
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
