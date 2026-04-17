import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../models/models.dart';
import '../common/common_widgets.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(),
          const SizedBox(height: 24),
          // Stats row
          const _StatsRow(),
          const SizedBox(height: 24),
          // Main grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                flex: 3,
                child: Column(
                  children: const [
                    _ToolStatusCard(),
                    SizedBox(height: 20),
                    _RecentActivityCard(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Right column
              Expanded(
                flex: 2,
                child: Column(
                  children: const [
                    _WorkflowsCard(),
                    SizedBox(height: 20),
                    _AgentCard(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: WeaverColors.textPrimary,
                    fontWeight: FontWeight.w700)),
            const Text('Your agentic workspace is ready',
                style: TextStyle(color: WeaverColors.textMuted, fontSize: 14)),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {
            Provider.of<ChatProvider>(context, listen: false).newChat();
            Provider.of<AppState>(context, listen: false).setNavIndex(0);
          },
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('New Chat'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () =>
              Provider.of<AppState>(context, listen: false).setNavIndex(2),
          icon: const Icon(Icons.account_tree_rounded, size: 14),
          label: const Text('Workflows'),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Consumer3<ChatProvider, ToolsProvider, WorkflowsProvider>(
      builder: (context, chatProv, toolsProv, wfProv, _) {
        final stats = [
          _StatData(
              value: '${chatProv.sessions.length}',
              label: 'Active Chats',
              icon: Icons.chat_bubble_rounded,
              color: WeaverColors.accent),
          _StatData(
              value: '${toolsProv.connectedCount}',
              label: 'Connected Tools',
              icon: Icons.extension_rounded,
              color: WeaverColors.success),
          _StatData(
              value: '${wfProv.totalWorkflowCount}',
              label: 'Workflows',
              icon: Icons.account_tree_rounded,
              color: WeaverColors.info),
          _StatData(
              value: '${wfProv.activeWorkflowCount}',
              label: 'Running Now',
              icon: Icons.bolt_rounded,
              color: WeaverColors.warning),
        ];
        return Row(
          children: stats
              .asMap()
              .entries
              .map((e) => Expanded(
                    child: _StatCard(data: e.value)
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: e.key * 80))
                        .slideY(
                            begin: 0.1,
                            end: 0,
                            delay: Duration(milliseconds: e.key * 80)),
                  ))
              .toList()
              .expand((w) => [w, const SizedBox(width: 16)])
              .toList()
            ..removeLast(),
        );
      },
    );
  }
}

class _StatData {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatData(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WeaverColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WeaverColors.cardBorder),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [WeaverColors.card, data.color.withOpacity(0.04)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(data.icon, color: data.color, size: 22)),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.value,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: data.color,
                      height: 1)),
              const SizedBox(height: 3),
              Text(data.label,
                  style: const TextStyle(
                      fontSize: 12, color: WeaverColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolStatusCard extends StatelessWidget {
  const _ToolStatusCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<ToolsProvider>(
      builder: (context, provider, _) {
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
                  const Icon(Icons.extension_rounded,
                      size: 18, color: WeaverColors.accent),
                  const SizedBox(width: 8),
                  const Text('Tool Status',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: WeaverColors.textPrimary)),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        Provider.of<AppState>(context, listen: false)
                            .setRightPanelTab(0),
                    child: const Text('Manage', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...provider.tools.map((t) => _ToolStatusRow(tool: t)),
            ],
          ),
        );
      },
    );
  }
}

class _ToolStatusRow extends StatelessWidget {
  final ToolModel tool;
  const _ToolStatusRow({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(tool.logoEmoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(tool.name,
                  style: const TextStyle(
                      fontSize: 13, color: WeaverColors.textSecondary))),
          StatusBadge(status: tool.authStatus),
          const SizedBox(width: 8),
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              color: WeaverColors.surface,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: tool.usageCount / 400,
              child: Container(
                decoration: BoxDecoration(
                  color: tool.categoryColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 32,
            child: Text('${tool.usageCount}',
                style: const TextStyle(
                    fontSize: 10, color: WeaverColors.textMuted),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  static const _activities = [
    (
      icon: '✉️',
      text: 'Gmail: Fetched 8 emails',
      time: '10m ago',
      color: WeaverColors.cloudColor
    ),
    (
      icon: '🔍',
      text: 'Web Search: Queried "AI frameworks 2025"',
      time: '25m ago',
      color: WeaverColors.accentBright
    ),
    (
      icon: '⏰',
      text: 'Workflow "Morning Digest" ran successfully',
      time: '4h ago',
      color: WeaverColors.success
    ),
    (
      icon: '🗂️',
      text: 'Drive Backup: Copied 3 files to /Backups',
      time: '4h 5m ago',
      color: WeaverColors.cloudColor
    ),
    (
      icon: '🗄️',
      text: 'Filesystem: Listed /Projects directory',
      time: '5h ago',
      color: WeaverColors.filesColor
    ),
  ];

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
          const Row(
            children: [
              Icon(Icons.timeline_rounded,
                  size: 18, color: WeaverColors.accent),
              SizedBox(width: 8),
              Text('Recent Activity',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: WeaverColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ..._activities.asMap().entries.map((e) => _ActivityRow(
                icon: e.value.icon,
                text: e.value.text,
                time: e.value.time,
                color: e.value.color,
                isLast: e.key == _activities.length - 1,
              )),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String icon;
  final String text;
  final String time;
  final Color color;
  final bool isLast;

  const _ActivityRow(
      {required this.icon,
      required this.text,
      required this.time,
      required this.color,
      required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 13))),
            ),
            if (!isLast)
              Container(width: 1, height: 18, color: WeaverColors.cardBorder),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            child: Row(
              children: [
                Expanded(
                    child: Text(text,
                        style: const TextStyle(
                            fontSize: 12, color: WeaverColors.textSecondary))),
                const SizedBox(width: 8),
                Text(time,
                    style: const TextStyle(
                        fontSize: 11, color: WeaverColors.textMuted)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkflowsCard extends StatelessWidget {
  const _WorkflowsCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowsProvider>(
      builder: (context, wfProv, _) {
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
                  const Icon(Icons.account_tree_rounded,
                      size: 18, color: WeaverColors.accent),
                  const SizedBox(width: 8),
                  const Text('Workflows',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: WeaverColors.textPrimary)),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        Provider.of<AppState>(context, listen: false)
                            .setNavIndex(2),
                    child:
                        const Text('View All', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...wfProv.workflows
                  .take(4)
                  .map((wf) => _WorkflowRow(workflow: wf, wfProv: wfProv)),
            ],
          ),
        );
      },
    );
  }
}

class _WorkflowRow extends StatelessWidget {
  final WorkflowModel workflow;
  final WorkflowsProvider wfProv;
  const _WorkflowRow({required this.workflow, required this.wfProv});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        wfProv.setOpenWorkflow(workflow.id);
        Provider.of<AppState>(context, listen: false).setNavIndex(2);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: WeaverColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: WeaverColors.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workflow.name,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: WeaverColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                      '${workflow.nodes.length} nodes · ${workflow.runCount} runs',
                      style: const TextStyle(
                          fontSize: 11, color: WeaverColors.textMuted)),
                ],
              ),
            ),
            WorkflowStatusBadge(status: workflow.status),
          ],
        ),
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  const _AgentCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelProvider>(
      builder: (context, modelProv, _) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WeaverColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: WeaverColors.cardBorder),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [WeaverColors.card, Color(0xFF1E1A2E)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology_rounded,
                    size: 18, color: WeaverColors.accent),
                SizedBox(width: 8),
                Text('Active Agent',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WeaverColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: WeaverColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: WeaverColors.accent.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: WeaverColors.success,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      const Text('Weaver Agent',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: WeaverColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(modelProv.modelName,
                      style: const TextStyle(
                          fontSize: 12,
                          color: WeaverColors.accent,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text(
                      'Custom model configured in the right sidebar model panel.',
                      style: TextStyle(
                          fontSize: 11, color: WeaverColors.textMuted),
                      maxLines: 2),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.memory_rounded,
                          size: 12, color: WeaverColors.textMuted),
                      const SizedBox(width: 4),
                      Text('${modelProv.maxTokens} max tokens',
                          style: const TextStyle(
                              fontSize: 11, color: WeaverColors.textMuted)),
                      const SizedBox(width: 10),
                      const Icon(Icons.thermostat_rounded,
                          size: 12, color: WeaverColors.textMuted),
                      const SizedBox(width: 4),
                      Text('T: ${modelProv.temperature.toStringAsFixed(1)}',
                          style: const TextStyle(
                              fontSize: 11, color: WeaverColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Provider.of<AppState>(context, listen: false)
                    .setRightPanelTab(2),
                icon: const Icon(Icons.tune_rounded, size: 13),
                label: const Text('Configure', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
