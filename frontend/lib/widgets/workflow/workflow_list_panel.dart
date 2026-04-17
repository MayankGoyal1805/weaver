import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../models/models.dart';
import '../common/common_widgets.dart';

// ── Workflow List Panel (in right sidebar) ────────────────────────────────────
class WorkflowListPanel extends StatelessWidget {
  const WorkflowListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkflowsProvider, ChatProvider>(
      builder: (context, wfProv, chatProv, _) {
        final sessionId = chatProv.activeSessionId;
        final sessionWorkflows = sessionId != null
            ? wfProv.workflowsForSession(sessionId)
            : <WorkflowModel>[];
        final allOther = wfProv.workflows.where((w) => w.chatSessionId != sessionId).toList();

        return Column(
          children: [
            // Create workflow button
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: wfProv.toggleCreateDialog,
                  icon: const Icon(Icons.add_rounded, size: 15),
                  label: const Text('Create Workflow', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
            ),

            // Create dialog
            if (wfProv.showCreateDialog)
              _CreateWorkflowDialog(chatSessionId: sessionId ?? 'chat-1'),

            // Stats bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  _StatChip(label: '${wfProv.totalWorkflowCount} total', color: WeaverColors.textMuted),
                  const SizedBox(width: 6),
                  _StatChip(label: '${wfProv.activeWorkflowCount} running', color: WeaverColors.info),
                ],
              ),
            ),

            Container(height: 1, color: WeaverColors.cardBorder.withOpacity(0.4)),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  if (sessionWorkflows.isNotEmpty) ...[
                    const _PanelLabel('This Chat'),
                    ...sessionWorkflows.map((w) => _WorkflowMiniCard(workflow: w)),
                    const SizedBox(height: 12),
                  ],
                  if (allOther.isNotEmpty) ...[
                    const _PanelLabel('Other Chats'),
                    ...allOther.map((w) => _WorkflowMiniCard(workflow: w)),
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

class _CreateWorkflowDialog extends StatefulWidget {
  final String chatSessionId;
  const _CreateWorkflowDialog({required this.chatSessionId});

  @override
  State<_CreateWorkflowDialog> createState() => _CreateWorkflowDialogState();
}

class _CreateWorkflowDialogState extends State<_CreateWorkflowDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WeaverColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WeaverColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('New Workflow', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(hintText: 'Workflow name...', isDense: true),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Provider.of<WorkflowsProvider>(context, listen: false).toggleCreateDialog(),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      Provider.of<WorkflowsProvider>(context, listen: false)
                          .createWorkflow(_controller.text.trim(), widget.chatSessionId);
                      // Open the canvas
                      Provider.of<AppState>(context, listen: false).setNavIndex(2);
                    }
                  },
                  child: const Text('Create', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1);
  }
}

class _WorkflowMiniCard extends StatefulWidget {
  final WorkflowModel workflow;
  const _WorkflowMiniCard({required this.workflow});

  @override
  State<_WorkflowMiniCard> createState() => _WorkflowMiniCardState();
}

class _WorkflowMiniCardState extends State<_WorkflowMiniCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Provider.of<WorkflowsProvider>(context, listen: false).setOpenWorkflow(widget.workflow.id);
          Provider.of<AppState>(context, listen: false).setNavIndex(2);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _hovered ? WeaverColors.cardHover : WeaverColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _hovered ? WeaverColors.accent.withOpacity(0.3) : WeaverColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(widget.workflow.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: WeaverColors.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  WorkflowStatusBadge(status: widget.workflow.status),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.hub_rounded, size: 11, color: WeaverColors.textMuted),
                  const SizedBox(width: 4),
                  Text('${widget.workflow.nodes.length} nodes', style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted)),
                  const SizedBox(width: 8),
                  if (widget.workflow.lastRun != null) ...[
                    Icon(Icons.play_circle_outline_rounded, size: 11, color: WeaverColors.textMuted),
                    const SizedBox(width: 4),
                    Text(_formatTime(widget.workflow.lastRun!), style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted)),
                  ],
                ],
              ),
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

class _PanelLabel extends StatelessWidget {
  final String label;
  const _PanelLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 6),
      child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: WeaverColors.textDisabled, letterSpacing: 0.8)),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

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
