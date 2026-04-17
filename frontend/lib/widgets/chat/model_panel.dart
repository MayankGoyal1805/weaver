import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';

class ModelPanel extends StatelessWidget {
  const ModelPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelProvider>(
      builder: (context, modelProv, _) {
        final localModels = modelProv.models.where((m) => m.isLocal).toList();
        final remoteModels = modelProv.models.where((m) => !m.isLocal).toList();

        return ListView(
          padding: const EdgeInsets.all(14),
          children: [
            // Selected model display
            _SelectedModelHeader(modelProv: modelProv),
            const SizedBox(height: 16),

            // Model selector
            _SectionLabel('Remote Models'),
            const SizedBox(height: 8),
            ...remoteModels.map((m) => _ModelTile(model: m, selected: modelProv.selectedModelId == m.id, onTap: () => modelProv.selectModel(m.id))),
            const SizedBox(height: 12),
            _SectionLabel('Local Models (Ollama)'),
            const SizedBox(height: 8),
            ...localModels.map((m) => _ModelTile(model: m, selected: modelProv.selectedModelId == m.id, onTap: () => modelProv.selectModel(m.id))),

            const SizedBox(height: 20),
            Container(height: 1, color: WeaverColors.cardBorder),
            const SizedBox(height: 16),

            // System prompt
            _SectionLabel('System Prompt'),
            const SizedBox(height: 8),
            TextField(
              maxLines: 5,
              controller: TextEditingController(text: modelProv.systemPrompt),
              style: const TextStyle(fontSize: 12, color: WeaverColors.textSecondary, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Enter system prompt...',
                isDense: true,
              ),
              onChanged: modelProv.setSystemPrompt,
            ),
            const SizedBox(height: 16),

            // Temperature
            _SliderRow(
              label: 'Temperature',
              value: modelProv.temperature,
              min: 0, max: 2,
              displayValue: modelProv.temperature.toStringAsFixed(2),
              onChanged: modelProv.setTemperature,
            ),
            const SizedBox(height: 12),

            // Max tokens
            _SliderRow(
              label: 'Max Tokens',
              value: modelProv.maxTokens.toDouble(),
              min: 256, max: 32768,
              displayValue: '${modelProv.maxTokens}',
              onChanged: (v) => modelProv.setMaxTokens(v.round()),
            ),
            const SizedBox(height: 20),

            // Context info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WeaverColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: WeaverColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.memory_rounded, size: 14, color: WeaverColors.textMuted),
                  const SizedBox(width: 8),
                  Text(
                    'Context: ${_formatCtx(modelProv.selectedModel.contextWindow)}',
                    style: const TextStyle(fontSize: 12, color: WeaverColors.textMuted),
                  ),
                  const Spacer(),
                  Text(
                    modelProv.selectedModel.provider,
                    style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatCtx(int n) => n >= 1000000 ? '${n ~/ 1000000}M' : '${n ~/ 1000}K';
}

class _SelectedModelHeader extends StatelessWidget {
  final ModelProvider modelProv;
  const _SelectedModelHeader({required this.modelProv});

  @override
  Widget build(BuildContext context) {
    final m = modelProv.selectedModel;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WeaverColors.accentGlow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WeaverColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: WeaverColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Icon(Icons.psychology_rounded, color: WeaverColors.accent, size: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
                Text(m.provider, style: const TextStyle(fontSize: 11, color: WeaverColors.accent)),
              ],
            ),
          ),
          if (m.isLocal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: WeaverColors.filesColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: WeaverColors.filesColor.withOpacity(0.3)),
              ),
              child: const Text('LOCAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: WeaverColors.filesColor, letterSpacing: 0.8)),
            ),
        ],
      ),
    );
  }
}

class _ModelTile extends StatefulWidget {
  final dynamic model;
  final bool selected;
  final VoidCallback onTap;
  const _ModelTile({required this.model, required this.selected, required this.onTap});

  @override
  State<_ModelTile> createState() => _ModelTileState();
}

class _ModelTileState extends State<_ModelTile> {
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
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? WeaverColors.accentGlow
                : _hovered ? WeaverColors.cardHover : WeaverColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.selected
                  ? WeaverColors.accent.withOpacity(0.4)
                  : WeaverColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.model.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: widget.selected ? WeaverColors.accent : WeaverColors.textPrimary)),
                    Text(widget.model.description, style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (widget.selected) const Icon(Icons.check_rounded, size: 16, color: WeaverColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: WeaverColors.textMuted, letterSpacing: 0.8),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderRow({required this.label, required this.value, required this.min, required this.max, required this.displayValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: WeaverColors.textSecondary, fontWeight: FontWeight.w500)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: WeaverColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: WeaverColors.cardBorder),
              ),
              child: Text(displayValue, style: const TextStyle(fontSize: 11, color: WeaverColors.accent, fontWeight: FontWeight.w600, fontFamily: 'JetBrainsMono')),
            ),
          ],
        ),
        Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
