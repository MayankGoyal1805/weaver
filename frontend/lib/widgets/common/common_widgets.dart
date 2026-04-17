import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../models/models.dart';

class StatusBadge extends StatelessWidget {
  final AuthStatus status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      AuthStatus.connected => (WeaverColors.success, 'Connected', Icons.check_circle_rounded),
      AuthStatus.disconnected => (WeaverColors.textMuted, 'Not Connected', Icons.circle_outlined),
      AuthStatus.pending => (WeaverColors.warning, 'Connecting...', Icons.sync_rounded),
      AuthStatus.error => (WeaverColors.error, 'Error', Icons.error_rounded),
    };

    if (compact) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class WorkflowStatusBadge extends StatelessWidget {
  final WorkflowStatus status;

  const WorkflowStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      WorkflowStatus.idle => (WeaverColors.textMuted, 'Idle'),
      WorkflowStatus.running => (WeaverColors.info, 'Running'),
      WorkflowStatus.success => (WeaverColors.success, 'Success'),
      WorkflowStatus.error => (WeaverColors.error, 'Error'),
      WorkflowStatus.draft => (WeaverColors.warning, 'Draft'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == WorkflowStatus.running)
            SizedBox(
              width: 8, height: 8,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
            )
          else
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class WeaverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final bool isSelected;

  const WeaverCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderColor,
    this.isSelected = false,
  });

  @override
  State<WeaverCard> createState() => _WeaverCardState();
}

class _WeaverCardState extends State<WeaverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? WeaverColors.accentGlow
                : _hovered
                    ? WeaverColors.cardHover
                    : WeaverColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? WeaverColors.accent
                  : widget.borderColor ?? (_hovered ? WeaverColors.accent.withOpacity(0.3) : WeaverColors.cardBorder),
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class CategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const CategoryChip({super.key, required this.label, required this.isSelected, required this.onTap, required this.color});

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.isSelected ? widget.color.withOpacity(0.18) : (_hovered ? WeaverColors.cardHover : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? widget.color : (_hovered ? WeaverColors.cardBorder : Colors.transparent),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: widget.isSelected ? widget.color : WeaverColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class SilkDivider extends StatelessWidget {
  const SilkDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: WeaverColors.cardBorder.withOpacity(0.5));
  }
}
