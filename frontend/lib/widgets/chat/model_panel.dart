import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/providers.dart';
import '../../theme/colors.dart';

class ModelPanel extends StatefulWidget {
  const ModelPanel({super.key});

  @override
  State<ModelPanel> createState() => _ModelPanelState();
}

class _ModelPanelState extends State<ModelPanel> {
  late final TextEditingController _modelNameController;
  late final TextEditingController _systemPromptController;

  @override
  void initState() {
    super.initState();
    _modelNameController = TextEditingController();
    _systemPromptController = TextEditingController();
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelProvider>(
      builder: (context, modelProv, _) {
        if (_modelNameController.text != modelProv.modelName) {
          _modelNameController.text = modelProv.modelName;
        }
        if (_systemPromptController.text != modelProv.systemPrompt) {
          _systemPromptController.text = modelProv.systemPrompt;
        }

        return ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _SectionLabel('Model'),
            const SizedBox(height: 8),
            TextField(
              controller: _modelNameController,
              decoration: const InputDecoration(
                hintText: 'Enter model name (e.g. gpt-4.1-mini, openrouter/model)',
                isDense: true,
              ),
              onSubmitted: modelProv.setModelName,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                onPressed: () => modelProv.setModelName(_modelNameController.text),
                child: const Text('Save Model Name'),
              ),
            ),
            const SizedBox(height: 18),

            _SectionLabel('System Prompt'),
            const SizedBox(height: 8),
            TextField(
              maxLines: 6,
              controller: _systemPromptController,
              style: const TextStyle(fontSize: 12, color: WeaverColors.textSecondary, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Enter system prompt...',
                isDense: true,
              ),
              onChanged: modelProv.setSystemPrompt,
            ),
            const SizedBox(height: 16),

            _SliderRow(
              label: 'Temperature',
              value: modelProv.temperature,
              min: 0,
              max: 2,
              displayValue: modelProv.temperature.toStringAsFixed(2),
              onChanged: modelProv.setTemperature,
            ),
            const SizedBox(height: 12),
            _SliderRow(
              label: 'Max Tokens',
              value: modelProv.maxTokens.toDouble(),
              min: 256,
              max: 32768,
              displayValue: '${modelProv.maxTokens}',
              onChanged: (v) => modelProv.setMaxTokens(v.round()),
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
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: WeaverColors.textMuted,
        letterSpacing: 0.8,
      ),
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

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: WeaverColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: WeaverColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: WeaverColors.cardBorder),
              ),
              child: Text(
                displayValue,
                style: const TextStyle(
                  fontSize: 11,
                  color: WeaverColors.accent,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
            ),
          ],
        ),
        Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
