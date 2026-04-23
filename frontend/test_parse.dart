import 'dart:core';

class _ParsedAssistantBody {
  final String visibleMarkdown;
  final List<String> thinkBlocks;

  const _ParsedAssistantBody({
    required this.visibleMarkdown,
    required this.thinkBlocks,
  });

  static _ParsedAssistantBody parse(String raw) {
    var remaining = raw;
    final thinkBlocks = <String>[];

    final thinkRegex = RegExp(r'<think>([\s\S]*?)</think>', caseSensitive: false);
    remaining = remaining.replaceAllMapped(thinkRegex, (m) {
      final content = (m.group(1) ?? '').trim();
      if (content.isNotEmpty) {
        thinkBlocks.add(content);
      }
      return '';
    });

    return _ParsedAssistantBody(
      visibleMarkdown: remaining.trim(),
      thinkBlocks: thinkBlocks,
    );
  }
}

void main() {
  final res = _ParsedAssistantBody.parse("<think>\nHello world\n</think>\nFinal answer");
  print("Think Blocks: ${res.thinkBlocks}");
  print("Visible: ${res.visibleMarkdown}");
}
