import 'package:flutter/material.dart';

enum ToolCategory { cloud, messaging, files, dev, productivity, ai }

enum AuthStatus { connected, disconnected, pending, error }

class ToolCapability {
  final String name;
  final String description;
  final String icon;

  const ToolCapability({required this.name, required this.description, required this.icon});
}

class ToolModel {
  final String id;
  final String name;
  final String description;
  final String logoEmoji;
  final ToolCategory category;
  AuthStatus authStatus;
  bool isEnabled;
  final List<ToolCapability> capabilities;
  final int usageCount;
  final String? lastUsed;
  final Color categoryColor;
  final Map<String, dynamic> metadata;

  ToolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.logoEmoji,
    required this.category,
    required this.authStatus,
    required this.isEnabled,
    required this.capabilities,
    required this.usageCount,
    this.lastUsed,
    required this.categoryColor,
    this.metadata = const {},
  });
}

enum MessageRole { user, assistant, system, tool }

class ToolCallResult {
  final String toolName;
  final Map<String, dynamic> arguments;
  final String result;
  final bool success;

  const ToolCallResult({
    required this.toolName,
    required this.arguments,
    required this.result,
    required this.success,
  });
}

/// A single rendered "block" inside one agent response turn.
/// Each turn produces an ordered list of these: thinking text, tool calls,
/// more text, and so on — all inside the same chat bubble.
sealed class AgentBlock {}

class TextBlock extends AgentBlock {
  final String text;
  TextBlock(this.text);
}

class ToolCallBlock extends AgentBlock {
  final ToolCallResult toolCall;
  ToolCallBlock(this.toolCall);
}

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;       // kept for user messages & legacy serialisation
  final DateTime timestamp;
  final ToolCallResult? toolCall;  // kept for legacy serialisation
  final List<AgentBlock> blocks;   // ordered blocks for agent turns
  final bool isStreaming;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.toolCall,
    this.blocks = const [],
    this.isStreaming = false,
  });
}


class ChatSession {
  final String id;
  final String title;
  final String agentName;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final List<String> enabledToolIds;
  final bool isPinned;
  final int workflowCount;

  const ChatSession({
    required this.id,
    required this.title,
    required this.agentName,
    required this.updatedAt,
    required this.messages,
    required this.enabledToolIds,
    this.isPinned = false,
    this.workflowCount = 0,
  });
}

enum NodeType { trigger, action, condition, transform, output }

enum WorkflowStatus { idle, running, success, error, draft }

class WorkflowPort {
  final String id;
  final String label;
  final bool isInput;

  const WorkflowPort({required this.id, required this.label, required this.isInput});
}

class WorkflowNode {
  final String id;
  final String label;
  final NodeType type;
  final String toolId;
  final String toolName;
  final String icon;
  Offset position;
  final Map<String, dynamic> config;
  final List<WorkflowPort> ports;
  final Color color;

  WorkflowNode({
    required this.id,
    required this.label,
    required this.type,
    required this.toolId,
    required this.toolName,
    required this.icon,
    required this.position,
    required this.config,
    required this.ports,
    required this.color,
  });
}

class WorkflowEdge {
  final String id;
  final String fromNodeId;
  final String fromPortId;
  final String toNodeId;
  final String toPortId;

  const WorkflowEdge({
    required this.id,
    required this.fromNodeId,
    required this.fromPortId,
    required this.toNodeId,
    required this.toPortId,
  });
}

class WorkflowModel {
  final String id;
  final String name;
  final String description;
  final String chatSessionId;
  WorkflowStatus status;
  final DateTime createdAt;
  DateTime? lastRun;
  final int runCount;
  final List<WorkflowNode> nodes;
  final List<WorkflowEdge> edges;
  final bool isActive;

  WorkflowModel({
    required this.id,
    required this.name,
    required this.description,
    required this.chatSessionId,
    required this.status,
    required this.createdAt,
    this.lastRun,
    required this.runCount,
    required this.nodes,
    required this.edges,
    required this.isActive,
  });
}

class AgentModel {
  final String id;
  final String name;
  final String description;
  final String model;
  final String systemPrompt;
  final List<String> enabledToolIds;
  final bool isActive;

  const AgentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.model,
    required this.systemPrompt,
    required this.enabledToolIds,
    required this.isActive,
  });
}

class LlmModel {
  final String id;
  final String name;
  final String provider;
  final int contextWindow;
  final bool isLocal;
  final String description;

  const LlmModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.contextWindow,
    required this.isLocal,
    required this.description,
  });
}
