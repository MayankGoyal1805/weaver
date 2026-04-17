import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../models/models.dart';
import '../widgets/common/common_widgets.dart';
import '../widgets/workflow/workflow_canvas.dart';

class WorkflowsScreen extends StatelessWidget {
  const WorkflowsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowsProvider>(
      builder: (context, wfProv, _) {
        // If a workflow is open, show the canvas
        if (wfProv.openWorkflow != null) {
          return WorkflowCanvas(workflow: wfProv.openWorkflow!);
        }
        // Otherwise show the workflows dashboard
        return _WorkflowsDashboard();
      },
    );
  }
}

class _WorkflowsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkflowsProvider, ChatProvider>(
      builder: (context, wfProv, chatProv, _) {
        // Group workflows by chat session
        final Map<String, List<WorkflowModel>> bySession = {};
        for (final wf in wfProv.workflows) {
          bySession.putIfAbsent(wf.chatSessionId, () => []).add(wf);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WorkflowsHeader(wfProv: wfProv, chatProv: chatProv),
            Expanded(
              child: wfProv.workflows.isEmpty
                  ? const _EmptyWorkflowsState()
                  : ListView(
                      padding: const EdgeInsets.all(24),
                      children: bySession.entries.map((entry) {
                        final session = chatProv.sessions.where((s) => s.id == entry.key).firstOrNull;
                        return _WorkflowGroup(
                          sessionTitle: session?.title ?? 'Unknown Chat',
                          workflows: entry.value,
                          wfProv: wfProv,
                        ).animate().fadeIn(duration: 300.ms);
                      }).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _WorkflowsHeader extends StatelessWidget {
  final WorkflowsProvider wfProv;
  final ChatProvider chatProv;

  const _WorkflowsHeader({required this.wfProv, required this.chatProv});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: WeaverColors.cardBorder)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Workflows', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: WeaverColors.textPrimary)),
              Text('${wfProv.totalWorkflowCount} total · ${wfProv.activeWorkflowCount} running', style: const TextStyle(fontSize: 13, color: WeaverColors.textMuted)),
            ],
          ),
          const Spacer(),
          // Status filter chips
          _FilterChip(label: 'All', count: wfProv.workflows.length),
          const SizedBox(width: 6),
          _FilterChip(label: 'Active', count: wfProv.workflows.where((w) => w.isActive).length, color: WeaverColors.success),
          const SizedBox(width: 6),
          _FilterChip(label: 'Draft', count: wfProv.workflows.where((w) => w.status == WorkflowStatus.draft).length, color: WeaverColors.warning),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              wfProv.toggleCreateDialog();
              // Show create dialog as overlay
              showDialog(
                context: context,
                builder: (ctx) => _CreateWorkflowOverlay(chatProv: chatProv, wfProv: wfProv),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 15),
            label: const Text('New Workflow'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final int count;
  final Color? color;
  const _FilterChip({required this.label, required this.count, this.color});

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? WeaverColors.textMuted;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _hovered ? c.withOpacity(0.12) : c.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withOpacity(_hovered ? 0.4 : 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w500)),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text('${widget.count}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowGroup extends StatelessWidget {
  final String sessionTitle;
  final List<WorkflowModel> workflows;
  final WorkflowsProvider wfProv;

  const _WorkflowGroup({required this.sessionTitle, required this.workflows, required this.wfProv});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: WeaverColors.textMuted),
            const SizedBox(width: 6),
            Text(sessionTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WeaverColors.textSecondary)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: WeaverColors.surface, borderRadius: BorderRadius.circular(8)),
              child: Text('${workflows.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: WeaverColors.textMuted)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 165,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: workflows.length,
          itemBuilder: (context, i) => _WorkflowCard(workflow: workflows[i], wfProv: wfProv),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _WorkflowCard extends StatefulWidget {
  final WorkflowModel workflow;
  final WorkflowsProvider wfProv;
  const _WorkflowCard({required this.workflow, required this.wfProv});

  @override
  State<_WorkflowCard> createState() => _WorkflowCardState();
}

class _WorkflowCardState extends State<_WorkflowCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final wf = widget.workflow;
    final statusColor = switch (wf.status) {
      WorkflowStatus.running => WeaverColors.info,
      WorkflowStatus.success => WeaverColors.success,
      WorkflowStatus.error => WeaverColors.error,
      WorkflowStatus.draft => WeaverColors.warning,
      _ => WeaverColors.textMuted,
    };

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.wfProv.setOpenWorkflow(wf.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered ? WeaverColors.cardHover : WeaverColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? statusColor.withOpacity(0.5) : WeaverColors.cardBorder,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered ? [BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 12, spreadRadius: 1)] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini node preview
                  _MiniNodePreview(nodes: wf.nodes),
                  const Spacer(),
                  // Active toggle
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: wf.isActive,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Name
              Text(wf.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(wf.description, style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
              const Spacer(),
              // Footer
              Row(
                children: [
                  WorkflowStatusBadge(status: wf.status),
                  const Spacer(),
                  Text('${wf.runCount} runs', style: const TextStyle(fontSize: 10, color: WeaverColors.textMuted)),
                ],
              ),
              if (wf.lastRun != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Last: ${_formatTime(wf.lastRun!)}',
                  style: const TextStyle(fontSize: 10, color: WeaverColors.textDisabled),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _MiniNodePreview extends StatelessWidget {
  final List<WorkflowNode> nodes;
  const _MiniNodePreview({required this.nodes});

  @override
  Widget build(BuildContext context) {
    final displayNodes = nodes.take(4).toList();
    return Row(
      children: displayNodes.map((n) => Container(
        margin: const EdgeInsets.only(right: 4),
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: n.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: n.color.withOpacity(0.4)),
        ),
        child: Center(child: Text(n.icon, style: const TextStyle(fontSize: 11))),
      )).toList(),
    );
  }
}

class _EmptyWorkflowsState extends StatelessWidget {
  const _EmptyWorkflowsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🕸️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          const Text('No workflows yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Create a workflow to automate tasks across your tools', style: TextStyle(fontSize: 14, color: WeaverColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Provider.of<WorkflowsProvider>(context, listen: false).toggleCreateDialog(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Workflow'),
          ),
        ],
      ),
    );
  }
}

class _CreateWorkflowOverlay extends StatefulWidget {
  final ChatProvider chatProv;
  final WorkflowsProvider wfProv;
  const _CreateWorkflowOverlay({required this.chatProv, required this.wfProv});

  @override
  State<_CreateWorkflowOverlay> createState() => _CreateWorkflowOverlayState();
}

class _CreateWorkflowOverlayState extends State<_CreateWorkflowOverlay> {
  final _nameController = TextEditingController();
  String? _selectedChatId;

  @override
  void initState() {
    super.initState();
    _selectedChatId = widget.chatProv.activeSessionId ?? widget.chatProv.sessions.firstOrNull?.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: WeaverColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: WeaverColors.cardBorder)),
      child: SizedBox(
        width: 460,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Workflow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: WeaverColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Workflows are linked to a chat session', style: TextStyle(fontSize: 12, color: WeaverColors.textMuted)),
              const SizedBox(height: 20),
              const Text('NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WeaverColors.textMuted, letterSpacing: 0.8)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                autofocus: true,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(hintText: 'e.g. Morning Email Digest'),
              ),
              const SizedBox(height: 16),
              const Text('LINKED CHAT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WeaverColors.textMuted, letterSpacing: 0.8)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedChatId,
                dropdownColor: WeaverColors.card,
                decoration: const InputDecoration(isDense: true),
                style: const TextStyle(fontSize: 13, color: WeaverColors.textPrimary),
                items: widget.chatProv.sessions.map((s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(s.title, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => _selectedChatId = v),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.trim().isNotEmpty && _selectedChatId != null) {
                        widget.wfProv.createWorkflow(_nameController.text.trim(), _selectedChatId!);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Create & Open Canvas'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
