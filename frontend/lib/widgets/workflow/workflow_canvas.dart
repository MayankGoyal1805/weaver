import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../models/models.dart';
import '../common/common_widgets.dart';

// ── n8n-Style Workflow Canvas ─────────────────────────────────────────────────
class WorkflowCanvas extends StatefulWidget {
  final WorkflowModel workflow;

  const WorkflowCanvas({super.key, required this.workflow});

  @override
  State<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends State<WorkflowCanvas> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  String? _selectedNodeId;
  Offset? _dragStart;
  Offset? _nodeStartPos;

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowsProvider>(
      builder: (context, wfProv, _) {
        return Column(
          children: [
            _CanvasTopBar(workflow: widget.workflow, onRun: () => wfProv.runWorkflow(widget.workflow.id)),
            Expanded(
              child: Row(
                children: [
                  // Main canvas
                  Expanded(
                    child: Stack(
                      children: [
                        // Grid background
                        Positioned.fill(child: _GridBackground()),
                        // Canvas content
                        GestureDetector(
                          onPanUpdate: (d) {
                            if (_selectedNodeId == null) {
                              setState(() => _offset += d.delta);
                            }
                          },
                          child: ClipRect(
                            child: Transform(
                              transform: Matrix4.identity()
                                ..translate(_offset.dx, _offset.dy)
                                ..scale(_scale),
                              child: SizedBox.expand(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Draw edges
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _EdgePainter(
                                          nodes: widget.workflow.nodes,
                                          edges: widget.workflow.edges,
                                          status: widget.workflow.status,
                                        ),
                                      ),
                                    ),
                                    // Draw nodes
                                    ...widget.workflow.nodes.map((node) => _DraggableNode(
                                      key: Key(node.id),
                                      node: node,
                                      isSelected: _selectedNodeId == node.id,
                                      onTap: () => setState(() => _selectedNodeId = node.id == _selectedNodeId ? null : node.id),
                                      onDragUpdate: (delta) {
                                        wfProv.updateNodePosition(
                                          widget.workflow.id,
                                          node.id,
                                          node.position + delta / _scale,
                                        );
                                      },
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Zoom controls
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: _ZoomControls(
                            scale: _scale,
                            onZoomIn: () => setState(() => _scale = (_scale * 1.2).clamp(0.3, 3.0)),
                            onZoomOut: () => setState(() => _scale = (_scale / 1.2).clamp(0.3, 3.0)),
                            onReset: () => setState(() { _scale = 1.0; _offset = Offset.zero; }),
                          ),
                        ),
                        // Add node button
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: _AddNodeButton(workflowId: widget.workflow.id),
                        ),
                      ],
                    ),
                  ),
                  // Node config panel (when a node is selected)
                  if (_selectedNodeId != null)
                    _NodeConfigPanel(
                      node: widget.workflow.nodes.firstWhere((n) => n.id == _selectedNodeId, orElse: () => widget.workflow.nodes.first),
                      onClose: () => setState(() => _selectedNodeId = null),
                    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.05, end: 0),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Canvas top bar ────────────────────────────────────────────────────────────
class _CanvasTopBar extends StatelessWidget {
  final WorkflowModel workflow;
  final VoidCallback onRun;

  const _CanvasTopBar({required this.workflow, required this.onRun});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: WeaverColors.surface,
        border: Border(bottom: BorderSide(color: WeaverColors.cardBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            onPressed: () => Provider.of<WorkflowsProvider>(context, listen: false).closeWorkflow(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workflow.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
                Text('${workflow.nodes.length} nodes · ${workflow.runCount} runs', style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted)),
              ],
            ),
          ),
          WorkflowStatusBadge(status: workflow.status),
          const SizedBox(width: 12),
          // AI Build button
          OutlinedButton.icon(
            onPressed: () => _showAiBuildDialog(context, workflow),
            icon: const Icon(Icons.auto_awesome_rounded, size: 14),
            label: const Text('AI Build', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          // Run button
          ElevatedButton.icon(
            onPressed: workflow.status == WorkflowStatus.running ? null : onRun,
            icon: Icon(workflow.status == WorkflowStatus.running ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 15),
            label: Text(workflow.status == WorkflowStatus.running ? 'Running...' : 'Run', style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.save_rounded, size: 18), tooltip: 'Save', onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert_rounded, size: 18), tooltip: 'More', onPressed: () {}),
        ],
      ),
    );
  }

  void _showAiBuildDialog(BuildContext context, WorkflowModel workflow) {
    showDialog(
      context: context,
      builder: (ctx) => _AiBuildDialog(workflow: workflow),
    );
  }
}

class _AiBuildDialog extends StatefulWidget {
  final WorkflowModel workflow;
  const _AiBuildDialog({required this.workflow});

  @override
  State<_AiBuildDialog> createState() => _AiBuildDialogState();
}

class _AiBuildDialogState extends State<_AiBuildDialog> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: WeaverColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: WeaverColors.cardBorder)),
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: WeaverColors.accentGlow, borderRadius: BorderRadius.circular(8), border: Border.all(color: WeaverColors.accent.withOpacity(0.3))),
                    child: const Center(child: Icon(Icons.auto_awesome_rounded, color: WeaverColors.accent, size: 18)),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Workflow Builder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
                      Text('Describe what you want to automate', style: TextStyle(fontSize: 12, color: WeaverColors.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                maxLines: 4,
                autofocus: true,
                style: const TextStyle(fontSize: 14, color: WeaverColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g. "Every morning at 8am, fetch my unread Gmail emails, filter out newsletters, summarize with AI, and post digest to Discord"',
                  hintMaxLines: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The AI will create a workflow with the right nodes and connections for your description.',
                style: TextStyle(fontSize: 12, color: WeaverColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 20),
              // Quick templates
              const Text('TEMPLATES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: WeaverColors.textMuted, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _TemplateChip('Email to Discord digest', onTap: () => _controller.text = 'Fetch unread emails daily and post a summary to Discord'),
                  _TemplateChip('Drive file backup', onTap: () => _controller.text = 'Watch Drive for new files and back them up with timestamps'),
                  _TemplateChip('Web research report', onTap: () => _controller.text = 'Search the web on a topic and save AI-compiled report to Drive'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : () {
                      setState(() => _loading = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✨ Workflow generated by AI!'),
                            backgroundColor: WeaverColors.success,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      });
                    },
                    icon: _loading
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: WeaverColors.background))
                        : const Icon(Icons.auto_awesome_rounded, size: 15),
                    label: Text(_loading ? 'Generating...' : 'Generate'),
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

class _TemplateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TemplateChip(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: WeaverColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: WeaverColors.cardBorder),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, color: WeaverColors.textSecondary)),
      ),
    );
  }
}

// ── Grid Background ───────────────────────────────────────────────────────────
class _GridBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WeaverColors.cardBorder.withOpacity(0.3)
      ..strokeWidth = 0.5;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Dot grid overlay
    final dotPaint = Paint()
      ..color = WeaverColors.cardBorder.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Edge Painter (silk thread bezier curves) ──────────────────────────────────
class _EdgePainter extends CustomPainter {
  final List<WorkflowNode> nodes;
  final List<WorkflowEdge> edges;
  final WorkflowStatus status;

  const _EdgePainter({required this.nodes, required this.edges, required this.status});

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in edges) {
      final fromNode = nodes.where((n) => n.id == edge.fromNodeId).firstOrNull;
      final toNode = nodes.where((n) => n.id == edge.toNodeId).firstOrNull;
      if (fromNode == null || toNode == null) continue;

      const nodeW = 180.0;
      const nodeH = 60.0;

      final start = Offset(fromNode.position.dx + nodeW, fromNode.position.dy + nodeH / 2);
      final end = Offset(toNode.position.dx, toNode.position.dy + nodeH / 2);

      final cpDist = (end.dx - start.dx).abs() * 0.5;
      final cp1 = Offset(start.dx + cpDist, start.dy);
      final cp2 = Offset(end.dx - cpDist, end.dy);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

      // Glow effect
      final glowPaint = Paint()
        ..color = _edgeColor().withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, glowPaint);

      // Main line
      final linePaint = Paint()
        ..color = _edgeColor().withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);

      // Arrow head
      _drawArrow(canvas, cp2, end, _edgeColor().withOpacity(0.7));

      // Port circles
      _drawPort(canvas, start, fromNode.color);
      _drawPort(canvas, end, toNode.color);
    }
  }

  Color _edgeColor() => switch (status) {
        WorkflowStatus.running => WeaverColors.info,
        WorkflowStatus.success => WeaverColors.success,
        WorkflowStatus.error => WeaverColors.error,
        _ => WeaverColors.accent,
      };

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    final dir = (to - from);
    final len = dir.distance;
    if (len == 0) return;
    final norm = dir / len;
    final perp = Offset(-norm.dy, norm.dx);
    const arrowSize = 8.0;
    final p1 = to - norm * arrowSize + perp * arrowSize * 0.5;
    final p2 = to - norm * arrowSize - perp * arrowSize * 0.5;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawPort(Canvas canvas, Offset center, Color color) {
    canvas.drawCircle(center, 5, Paint()..color = color.withOpacity(0.8));
    canvas.drawCircle(center, 5, Paint()..color = WeaverColors.background..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) =>
      old.nodes != nodes || old.edges != edges || old.status != status;
}

// ── Draggable Node ────────────────────────────────────────────────────────────
class _DraggableNode extends StatefulWidget {
  final WorkflowNode node;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<Offset> onDragUpdate;

  const _DraggableNode({
    super.key,
    required this.node,
    required this.isSelected,
    required this.onTap,
    required this.onDragUpdate,
  });

  @override
  State<_DraggableNode> createState() => _DraggableNodeState();
}

class _DraggableNodeState extends State<_DraggableNode> {
  bool _dragging = false;
  Offset _lastPos = Offset.zero;

  @override
  Widget build(BuildContext context) {
    const w = 180.0;
    const h = 60.0;

    return Positioned(
      left: widget.node.position.dx,
      top: widget.node.position.dy,
      child: GestureDetector(
        onTap: widget.onTap,
        onPanStart: (d) {
          _dragging = true;
          _lastPos = d.globalPosition;
        },
        onPanUpdate: (d) {
          if (_dragging) {
            final delta = d.globalPosition - _lastPos;
            _lastPos = d.globalPosition;
            widget.onDragUpdate(delta);
          }
        },
        onPanEnd: (_) => _dragging = false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: WeaverColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? widget.node.color
                  : widget.node.color.withOpacity(0.35),
              width: widget.isSelected ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.node.color.withOpacity(widget.isSelected ? 0.3 : 0.1),
                blurRadius: widget.isSelected ? 12 : 6,
                spreadRadius: widget.isSelected ? 1 : 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Color strip
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: widget.node.color,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                ),
              ),
              const SizedBox(width: 10),
              // Icon
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: widget.node.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(child: Text(widget.node.icon, style: const TextStyle(fontSize: 14))),
              ),
              const SizedBox(width: 8),
              // Labels
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.node.label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.node.toolName,
                      style: TextStyle(fontSize: 10, color: widget.node.color, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Type pill
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _NodeTypePill(type: widget.node.type, color: widget.node.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NodeTypePill extends StatelessWidget {
  final NodeType type;
  final Color color;
  const _NodeTypePill({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      NodeType.trigger => 'T',
      NodeType.action => 'A',
      NodeType.condition => 'C',
      NodeType.transform => 'X',
      NodeType.output => 'O',
    };
    return Container(
      width: 18, height: 18,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Center(child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color))),
    );
  }
}

// ── Zoom Controls ─────────────────────────────────────────────────────────────
class _ZoomControls extends StatelessWidget {
  final double scale;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  const _ZoomControls({required this.scale, required this.onZoomIn, required this.onZoomOut, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WeaverColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WeaverColors.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomBtn(icon: Icons.add_rounded, onTap: onZoomIn),
          Container(width: 32, height: 1, color: WeaverColors.cardBorder),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('${(scale * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: WeaverColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          Container(width: 32, height: 1, color: WeaverColors.cardBorder),
          _ZoomBtn(icon: Icons.remove_rounded, onTap: onZoomOut),
          Container(width: 32, height: 1, color: WeaverColors.cardBorder),
          _ZoomBtn(icon: Icons.fit_screen_rounded, onTap: onReset),
        ],
      ),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      onPressed: onTap,
      style: IconButton.styleFrom(minimumSize: const Size(32, 32), padding: EdgeInsets.zero),
    );
  }
}

// ── Add Node Button ───────────────────────────────────────────────────────────
class _AddNodeButton extends StatelessWidget {
  final String workflowId;
  const _AddNodeButton({required this.workflowId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showAddNodeSheet(context),
      icon: const Icon(Icons.add_rounded, size: 15),
      label: const Text('Add Node', style: TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: WeaverColors.card,
        foregroundColor: WeaverColors.textPrimary,
        side: const BorderSide(color: WeaverColors.cardBorder),
        elevation: 2,
        shadowColor: WeaverColors.background,
      ),
    );
  }

  void _showAddNodeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: WeaverColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => _AddNodeSheet(workflowId: workflowId),
    );
  }
}

class _AddNodeSheet extends StatelessWidget {
  final String workflowId;
  const _AddNodeSheet({required this.workflowId});

  static const _nodeTypes = [
    (icon: '⏰', label: 'Schedule Trigger', type: NodeType.trigger, color: WeaverColors.triggerNode),
    (icon: '▶️', label: 'Manual Trigger', type: NodeType.trigger, color: WeaverColors.triggerNode),
    (icon: '🔗', label: 'Webhook Trigger', type: NodeType.trigger, color: WeaverColors.triggerNode),
    (icon: '✉️', label: 'Gmail Action', type: NodeType.action, color: WeaverColors.cloudColor),
    (icon: '🗂️', label: 'Drive Action', type: NodeType.action, color: WeaverColors.cloudColor),
    (icon: '🎮', label: 'Discord Action', type: NodeType.action, color: WeaverColors.messagingColor),
    (icon: '🗄️', label: 'Filesystem Action', type: NodeType.action, color: WeaverColors.filesColor),
    (icon: '🌐', label: 'Web Search', type: NodeType.action, color: WeaverColors.accentBright),
    (icon: '🔀', label: 'Condition / Filter', type: NodeType.condition, color: WeaverColors.conditionNode),
    (icon: '🧠', label: 'AI Transform', type: NodeType.transform, color: WeaverColors.accentBright),
    (icon: '🔄', label: 'Data Transform', type: NodeType.transform, color: WeaverColors.conditionNode),
    (icon: '📤', label: 'Output / Response', type: NodeType.output, color: WeaverColors.outputNode),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 36, height: 4,
          decoration: BoxDecoration(color: WeaverColors.cardBorder, borderRadius: BorderRadius.circular(2)),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Text('Add Node', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.4,
            ),
            itemCount: _nodeTypes.length,
            itemBuilder: (ctx, i) {
              final n = _nodeTypes[i];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Added "${n.label}" node'), duration: const Duration(seconds: 1), backgroundColor: WeaverColors.success),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: WeaverColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: n.color.withOpacity(0.35)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(n.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 5),
                      Text(n.label, style: const TextStyle(fontSize: 10, color: WeaverColors.textSecondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Node Config Panel (right side when node selected) ─────────────────────────
class _NodeConfigPanel extends StatelessWidget {
  final WorkflowNode node;
  final VoidCallback onClose;

  const _NodeConfigPanel({required this.node, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: WeaverColors.surface,
        border: Border(left: BorderSide(color: WeaverColors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: WeaverColors.cardBorder))),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: node.color.withOpacity(0.12), borderRadius: BorderRadius.circular(7)),
                  child: Center(child: Text(node.icon, style: const TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(node.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
                      Text(node.toolName, style: TextStyle(fontSize: 11, color: node.color, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close_rounded, size: 16), onPressed: onClose, style: IconButton.styleFrom(minimumSize: const Size(28, 28), padding: EdgeInsets.zero)),
              ],
            ),
          ),
          // Config fields
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                // Node type badge
                Row(
                  children: [
                    _ConfigLabel('NODE TYPE'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: node.color.withOpacity(0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: node.color.withOpacity(0.3))),
                      child: Text(_typeLabel(node.type), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: node.color)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ports
                _ConfigLabel('CONNECTIONS'),
                const SizedBox(height: 8),
                ...node.ports.map((port) => _PortRow(port: port, color: node.color)),
                const SizedBox(height: 16),

                // Config
                if (node.config.isNotEmpty) ...[
                  _ConfigLabel('CONFIGURATION'),
                  const SizedBox(height: 8),
                  ...node.config.entries.map((e) => _ConfigField(key_: e.key, value: e.value.toString())),
                  const SizedBox(height: 16),
                ],

                // Actions
                _ConfigLabel('ACTIONS'),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_rounded, size: 13),
                  label: const Text('Configure Node', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded, size: 13),
                  label: const Text('Test Node', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline_rounded, size: 13, color: WeaverColors.error),
                  label: const Text('Remove Node', style: TextStyle(fontSize: 12, color: WeaverColors.error)),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36), side: const BorderSide(color: WeaverColors.error)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(NodeType t) => switch (t) {
        NodeType.trigger => 'Trigger',
        NodeType.action => 'Action',
        NodeType.condition => 'Condition',
        NodeType.transform => 'Transform',
        NodeType.output => 'Output',
      };
}

class _ConfigLabel extends StatelessWidget {
  final String label;
  const _ConfigLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: WeaverColors.textMuted, letterSpacing: 0.8));
  }
}

class _PortRow extends StatelessWidget {
  final WorkflowPort port;
  final Color color;
  const _PortRow({required this.port, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(port.isInput ? Icons.input_rounded : Icons.output_rounded, size: 13, color: color.withOpacity(0.6)),
          const SizedBox(width: 8),
          Text(port.label, style: const TextStyle(fontSize: 12, color: WeaverColors.textSecondary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: WeaverColors.surface, borderRadius: BorderRadius.circular(4)),
            child: Text(port.isInput ? 'IN' : 'OUT', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: WeaverColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _ConfigField extends StatelessWidget {
  final String key_;
  final String value;
  const _ConfigField({required this.key_, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key_, style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: value),
            style: const TextStyle(fontSize: 12, color: WeaverColors.textPrimary, fontFamily: 'JetBrainsMono'),
            decoration: const InputDecoration(isDense: true),
          ),
        ],
      ),
    );
  }
}
