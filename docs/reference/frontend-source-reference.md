# Frontend Source Reference

This document includes every line from all Dart files under frontend/lib with line numbers.

## frontend/lib/app.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:provider/provider.dart';
     3	import 'providers/providers.dart';
     4	import 'theme/app_theme.dart';
     5	import 'widgets/shell/app_shell.dart';
     6	
     7	class WeaverApp extends StatelessWidget {
     8	  const WeaverApp({super.key});
     9	
    10	  @override
    11	  Widget build(BuildContext context) {
    12	    return MultiProvider(
    13	      providers: [
    14	        ChangeNotifierProvider(create: (_) => AppState()),
    15	        ChangeNotifierProvider(create: (_) => BackendProvider()..initialize()),
    16	        ChangeNotifierProvider(create: (_) => ModelProvider()..initialize()),
    17	        ChangeNotifierProxyProvider<BackendProvider, ToolsProvider>(
    18	          create: (_) => ToolsProvider(),
    19	          update: (_, backend, tools) => tools!..bindBackend(backend),
    20	        ),
    21	        ChangeNotifierProxyProvider3<BackendProvider, ToolsProvider,
    22	            ModelProvider, ChatProvider>(
    23	          create: (_) => ChatProvider(),
    24	          update: (_, backend, tools, model, chat) =>
    25	              chat!..bind(backend, tools, model),
    26	        ),
    27	        ChangeNotifierProvider(create: (_) => WorkflowsProvider()),
    28	      ],
    29	      child: MaterialApp(
    30	        title: 'Weaver',
    31	        debugShowCheckedModeBanner: false,
    32	        theme: WeaverTheme.dark,
    33	        home: const AppShell(),
    34	      ),
    35	    );
    36	  }
    37	}
```

## frontend/lib/data/mock_data.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import '../models/models.dart';
     3	import '../theme/colors.dart';
     4	
     5	class MockData {
     6	  MockData._();
     7	
     8	  // ── LLM Models ──────────────────────────────────────────────────────────────
     9	  static final List<LlmModel> llmModels = [
    10	    const LlmModel(id: 'gemini-2.5-pro', name: 'Gemini 2.5 Pro', provider: 'Google', contextWindow: 1000000, isLocal: false, description: 'Most capable model with 1M context'),
    11	    const LlmModel(id: 'gemini-2.0-flash', name: 'Gemini 2.0 Flash', provider: 'Google', contextWindow: 128000, isLocal: false, description: 'Fast and efficient multimodal model'),
    12	    const LlmModel(id: 'claude-sonnet-4', name: 'Claude Sonnet 4', provider: 'Anthropic', contextWindow: 200000, isLocal: false, description: 'Balanced reasoning and speed'),
    13	    const LlmModel(id: 'gpt-4o', name: 'GPT-4o', provider: 'OpenAI', contextWindow: 128000, isLocal: false, description: 'Omni model with vision'),
    14	    const LlmModel(id: 'llama-3.3-70b', name: 'Llama 3.3 70B', provider: 'Local (Ollama)', contextWindow: 128000, isLocal: true, description: 'Meta\'s latest open model'),
    15	    const LlmModel(id: 'mistral-24b', name: 'Mistral Small 3.1', provider: 'Local (Ollama)', contextWindow: 128000, isLocal: true, description: 'Efficient European open model'),
    16	    const LlmModel(id: 'qwen-2.5-72b', name: 'Qwen 2.5 72B', provider: 'Local (Ollama)', contextWindow: 128000, isLocal: true, description: 'Alibaba\'s flagship open model'),
    17	  ];
    18	
    19	  // ── Tools ────────────────────────────────────────────────────────────────────
    20	  static final List<ToolModel> tools = [
    21	    ToolModel(
    22	      id: 'google-drive',
    23	      name: 'Google Drive',
    24	      description: 'Read, write, search, and manage files in Google Drive',
    25	      logoEmoji: '🗂️',
    26	      category: ToolCategory.cloud,
    27	      authStatus: AuthStatus.connected,
    28	      isEnabled: true,
    29	      categoryColor: WeaverColors.cloudColor,
    30	      usageCount: 142,
    31	      lastUsed: '2 hours ago',
    32	      capabilities: const [
    33	        ToolCapability(name: 'List Files', description: 'Browse files and folders', icon: '📁'),
    34	        ToolCapability(name: 'Read File', description: 'Read file contents', icon: '📄'),
    35	        ToolCapability(name: 'Write File', description: 'Create and update files', icon: '✏️'),
    36	        ToolCapability(name: 'Search', description: 'Full-text search across Drive', icon: '🔍'),
    37	        ToolCapability(name: 'Share', description: 'Manage file permissions', icon: '🔗'),
    38	      ],
    39	    ),
    40	    ToolModel(
    41	      id: 'gmail',
    42	      name: 'Gmail',
    43	      description: 'Read, send, search, and manage emails in your Gmail account',
    44	      logoEmoji: '✉️',
    45	      category: ToolCategory.cloud,
    46	      authStatus: AuthStatus.connected,
    47	      isEnabled: true,
    48	      categoryColor: WeaverColors.cloudColor,
    49	      usageCount: 89,
    50	      lastUsed: '30 minutes ago',
    51	      capabilities: const [
    52	        ToolCapability(name: 'Read Emails', description: 'Fetch and parse emails', icon: '📧'),
    53	        ToolCapability(name: 'Send Email', description: 'Compose and send emails', icon: '📤'),
    54	        ToolCapability(name: 'Search', description: 'Search emails with Gmail query syntax', icon: '🔍'),
    55	        ToolCapability(name: 'Labels', description: 'Manage labels and folders', icon: '🏷️'),
    56	        ToolCapability(name: 'Attachments', description: 'Download and process attachments', icon: '📎'),
    57	      ],
    58	    ),
    59	    ToolModel(
    60	      id: 'google-classroom',
    61	      name: 'Google Classroom',
    62	      description: 'Manage courses, assignments, and student work in Google Classroom',
    63	      logoEmoji: '🎓',
    64	      category: ToolCategory.cloud,
    65	      authStatus: AuthStatus.connected,
    66	      isEnabled: false,
    67	      categoryColor: WeaverColors.cloudColor,
    68	      usageCount: 12,
    69	      lastUsed: '3 days ago',
    70	      capabilities: const [
    71	        ToolCapability(name: 'List Courses', description: 'Browse all courses', icon: '📚'),
    72	        ToolCapability(name: 'Assignments', description: 'Create and manage assignments', icon: '📝'),
    73	        ToolCapability(name: 'Student Work', description: 'Review student submissions', icon: '👨‍🎓'),
    74	        ToolCapability(name: 'Announcements', description: 'Post course announcements', icon: '📢'),
    75	      ],
    76	    ),
    77	    ToolModel(
    78	      id: 'discord',
    79	      name: 'Discord',
    80	      description: 'Send messages, manage channels, and interact with Discord servers',
    81	      logoEmoji: '🎮',
    82	      category: ToolCategory.messaging,
    83	      authStatus: AuthStatus.connected,
    84	      isEnabled: true,
    85	      categoryColor: WeaverColors.messagingColor,
    86	      usageCount: 67,
    87	      lastUsed: '1 hour ago',
    88	      capabilities: const [
    89	        ToolCapability(name: 'Send Message', description: 'Send messages to channels', icon: '💬'),
    90	        ToolCapability(name: 'Read Messages', description: 'Fetch channel history', icon: '📜'),
    91	        ToolCapability(name: 'Manage Channels', description: 'Create and configure channels', icon: '📡'),
    92	        ToolCapability(name: 'Webhooks', description: 'Send via webhooks', icon: '🔗'),
    93	      ],
    94	    ),
    95	    ToolModel(
    96	      id: 'slack',
    97	      name: 'Slack',
    98	      description: 'Post messages, search conversations, and manage Slack workspaces',
    99	      logoEmoji: '💬',
   100	      category: ToolCategory.messaging,
   101	      authStatus: AuthStatus.disconnected,
   102	      isEnabled: false,
   103	      categoryColor: WeaverColors.messagingColor,
   104	      usageCount: 0,
   105	      capabilities: const [
   106	        ToolCapability(name: 'Post Message', description: 'Send messages to channels or DMs', icon: '📨'),
   107	        ToolCapability(name: 'Search', description: 'Search Slack conversations', icon: '🔍'),
   108	        ToolCapability(name: 'Reactions', description: 'Add emoji reactions', icon: '😄'),
   109	        ToolCapability(name: 'Files', description: 'Upload and share files', icon: '📎'),
   110	      ],
   111	    ),
   112	    ToolModel(
   113	      id: 'filesystem',
   114	      name: 'Filesystem',
   115	      description: 'Read, write, copy, move, and delete local files within a sandbox',
   116	      logoEmoji: '🗄️',
   117	      category: ToolCategory.files,
   118	      authStatus: AuthStatus.connected,
   119	      isEnabled: true,
   120	      categoryColor: WeaverColors.filesColor,
   121	      usageCount: 201,
   122	      lastUsed: '5 minutes ago',
   123	      capabilities: const [
   124	        ToolCapability(name: 'List Directory', description: 'Browse file tree', icon: '📂'),
   125	        ToolCapability(name: 'Read File', description: 'Read file contents', icon: '📄'),
   126	        ToolCapability(name: 'Write File', description: 'Create and update files', icon: '✏️'),
   127	        ToolCapability(name: 'Copy / Move', description: 'Copy and move files', icon: '🔄'),
   128	        ToolCapability(name: 'Delete', description: 'Delete files safely', icon: '🗑️'),
   129	        ToolCapability(name: 'Search', description: 'Find files by name or content', icon: '🔍'),
   130	      ],
   131	    ),
   132	    ToolModel(
   133	      id: 'github',
   134	      name: 'GitHub',
   135	      description: 'Create issues, manage PRs, browse repos, and search code',
   136	      logoEmoji: '🐙',
   137	      category: ToolCategory.dev,
   138	      authStatus: AuthStatus.pending,
   139	      isEnabled: false,
   140	      categoryColor: WeaverColors.devColor,
   141	      usageCount: 0,
   142	      capabilities: const [
   143	        ToolCapability(name: 'Issues', description: 'Create and manage issues', icon: '🐛'),
   144	        ToolCapability(name: 'Pull Requests', description: 'Review and merge PRs', icon: '🔀'),
   145	        ToolCapability(name: 'Code Search', description: 'Search code across repos', icon: '🔍'),
   146	        ToolCapability(name: 'Commits', description: 'Browse commit history', icon: '📊'),
   147	      ],
   148	    ),
   149	    ToolModel(
   150	      id: 'web-search',
   151	      name: 'Web Search',
   152	      description: 'Search the internet and fetch web page contents',
   153	      logoEmoji: '🌐',
   154	      category: ToolCategory.ai,
   155	      authStatus: AuthStatus.connected,
   156	      isEnabled: true,
   157	      categoryColor: WeaverColors.accentBright,
   158	      usageCount: 334,
   159	      lastUsed: '10 minutes ago',
   160	      capabilities: const [
   161	        ToolCapability(name: 'Search', description: 'Query the web', icon: '🔍'),
   162	        ToolCapability(name: 'Fetch Page', description: 'Get content from any URL', icon: '📥'),
   163	        ToolCapability(name: 'News', description: 'Search recent news articles', icon: '📰'),
   164	      ],
   165	    ),
   166	    ToolModel(
   167	      id: 'notion',
   168	      name: 'Notion',
   169	      description: 'Read and write Notion pages, databases, and blocks',
   170	      logoEmoji: '📓',
   171	      category: ToolCategory.productivity,
   172	      authStatus: AuthStatus.disconnected,
   173	      isEnabled: false,
   174	      categoryColor: WeaverColors.productivityColor,
   175	      usageCount: 0,
   176	      capabilities: const [
   177	        ToolCapability(name: 'Pages', description: 'Read and create pages', icon: '📄'),
   178	        ToolCapability(name: 'Databases', description: 'Query and update databases', icon: '🗃️'),
   179	        ToolCapability(name: 'Blocks', description: 'Manage block-level content', icon: '🧱'),
   180	        ToolCapability(name: 'Search', description: 'Search across workspace', icon: '🔍'),
   181	      ],
   182	    ),
   183	    ToolModel(
   184	      id: 'google-calendar',
   185	      name: 'Google Calendar',
   186	      description: 'Create events, check availability, and manage your calendar',
   187	      logoEmoji: '📅',
   188	      category: ToolCategory.productivity,
   189	      authStatus: AuthStatus.connected,
   190	      isEnabled: false,
   191	      categoryColor: WeaverColors.productivityColor,
   192	      usageCount: 28,
   193	      lastUsed: '1 day ago',
   194	      capabilities: const [
   195	        ToolCapability(name: 'List Events', description: 'Browse upcoming events', icon: '📋'),
   196	        ToolCapability(name: 'Create Event', description: 'Add new events', icon: '➕'),
   197	        ToolCapability(name: 'Availability', description: 'Check free/busy slots', icon: '⏰'),
   198	        ToolCapability(name: 'Invites', description: 'Send and manage invitations', icon: '✉️'),
   199	      ],
   200	    ),
   201	  ];
   202	
   203	  // ── Chat Sessions ────────────────────────────────────────────────────────────
   204	  static final List<ChatSession> chatSessions = [
   205	    ChatSession(
   206	      id: 'chat-1',
   207	      title: 'Morning email digest automation',
   208	      agentName: 'Weaver Agent',
   209	      updatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
   210	      enabledToolIds: ['gmail', 'discord', 'web-search'],
   211	      isPinned: true,
   212	      workflowCount: 2,
   213	      messages: [
   214	        ChatMessage(id: 'm1', role: MessageRole.user, content: 'Set up a workflow that reads my latest emails every morning and summarizes them in Discord', timestamp: DateTime.now().subtract(const Duration(minutes: 25))),
   215	        ChatMessage(id: 'm2', role: MessageRole.assistant, content: 'I\'ll set up a morning email digest automation for you. Let me first check your Gmail for recent emails to understand the structure, then I\'ll create the workflow.\n\nHere\'s what I\'ll build:\n1. **Trigger**: Daily schedule at 8:00 AM\n2. **Fetch**: Last 10 unread Gmail emails\n3. **Process**: AI-summarize each thread\n4. **Send**: Post digest to your `#daily-digest` Discord channel', timestamp: DateTime.now().subtract(const Duration(minutes: 24)),
   216	          toolCall: ToolCallResult(toolName: 'gmail.list_emails', arguments: {'count': 10, 'unread': true}, result: 'Found 8 unread emails', success: true),
   217	        ),
   218	        ChatMessage(id: 'm3', role: MessageRole.user, content: 'Looks great! Also add a filter to skip promotional emails', timestamp: DateTime.now().subtract(const Duration(minutes: 22))),
   219	        ChatMessage(id: 'm4', role: MessageRole.assistant, content: 'Done! I\'ve added a condition node that filters out emails with the `CATEGORY_PROMOTIONS` label. The workflow is ready — want me to do a test run now?', timestamp: DateTime.now().subtract(const Duration(minutes: 21))),
   220	      ],
   221	    ),
   222	    ChatSession(
   223	      id: 'chat-2',
   224	      title: 'Code review helper',
   225	      agentName: 'Dev Agent',
   226	      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
   227	      enabledToolIds: ['github', 'filesystem', 'web-search'],
   228	      workflowCount: 0,
   229	      messages: [
   230	        ChatMessage(id: 'm5', role: MessageRole.user, content: 'Help me review the PR #142 in the weaver repo', timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 5))),
   231	        ChatMessage(id: 'm6', role: MessageRole.assistant, content: 'I see GitHub is not yet authenticated. Let me help you connect it so I can access the PR.', timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 4))),
   232	      ],
   233	    ),
   234	    ChatSession(
   235	      id: 'chat-3',
   236	      title: 'Research: AI agent frameworks',
   237	      agentName: 'Research Agent',
   238	      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
   239	      enabledToolIds: ['web-search', 'filesystem'],
   240	      workflowCount: 1,
   241	      messages: [
   242	        ChatMessage(id: 'm7', role: MessageRole.user, content: 'Research the top AI agent frameworks in 2025 and save a report to my Drive', timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 10))),
   243	        ChatMessage(id: 'm8', role: MessageRole.assistant, content: 'I\'ll research the top AI agent frameworks and compile a comprehensive report. Let me start by searching the web for the latest information.\n\nI found these leading frameworks:\n- **LangGraph** — stateful multi-agent orchestration by LangChain\n- **CrewAI** — role-based agent crews\n- **AutoGen** — Microsoft\'s conversational agent framework\n- **Pydantic AI** — type-safe agent framework\n- **Weaver** — tool-card-first automation platform 😄\n\nSaving the full report to Google Drive now...', timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 2)),
   244	          toolCall: ToolCallResult(toolName: 'web_search.query', arguments: {'query': 'best AI agent frameworks 2025'}, result: 'Fetched 12 results', success: true),
   245	        ),
   246	      ],
   247	    ),
   248	    ChatSession(
   249	      id: 'chat-4',
   250	      title: 'Classroom grade summary',
   251	      agentName: 'Weaver Agent',
   252	      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
   253	      enabledToolIds: ['google-classroom', 'gmail'],
   254	      workflowCount: 0,
   255	      messages: [
   256	        ChatMessage(id: 'm9', role: MessageRole.user, content: 'Summarize this week\'s assignment submissions', timestamp: DateTime.now().subtract(const Duration(days: 1))),
   257	      ],
   258	    ),
   259	    ChatSession(
   260	      id: 'chat-5',
   261	      title: 'Filesystem organizer',
   262	      agentName: 'File Agent',
   263	      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
   264	      enabledToolIds: ['filesystem'],
   265	      workflowCount: 3,
   266	      messages: [
   267	        ChatMessage(id: 'm10', role: MessageRole.user, content: 'Organize my Downloads folder by file type', timestamp: DateTime.now().subtract(const Duration(days: 2))),
   268	      ],
   269	    ),
   270	  ];
   271	
   272	  // ── Workflows ────────────────────────────────────────────────────────────────
   273	  static List<WorkflowModel> get workflows => [
   274	        WorkflowModel(
   275	          id: 'wf-1',
   276	          name: 'Morning Email Digest',
   277	          description: 'Fetches Gmail emails daily at 8 AM, summarizes, and posts to Discord',
   278	          chatSessionId: 'chat-1',
   279	          status: WorkflowStatus.success,
   280	          createdAt: DateTime.now().subtract(const Duration(days: 3)),
   281	          lastRun: DateTime.now().subtract(const Duration(hours: 4)),
   282	          runCount: 7,
   283	          isActive: true,
   284	          nodes: [
   285	            WorkflowNode(
   286	              id: 'node-trigger',
   287	              label: 'Daily Schedule',
   288	              type: NodeType.trigger,
   289	              toolId: 'scheduler',
   290	              toolName: 'Scheduler',
   291	              icon: '⏰',
   292	              position: const Offset(60, 160),
   293	              config: {'cron': '0 8 * * *', 'timezone': 'Asia/Kolkata'},
   294	              color: WeaverColors.triggerNode,
   295	              ports: const [WorkflowPort(id: 'out-1', label: 'trigger', isInput: false)],
   296	            ),
   297	            WorkflowNode(
   298	              id: 'node-fetch',
   299	              label: 'Fetch Emails',
   300	              type: NodeType.action,
   301	              toolId: 'gmail',
   302	              toolName: 'Gmail',
   303	              icon: '✉️',
   304	              position: const Offset(280, 160),
   305	              config: {'count': 10, 'unread': true},
   306	              color: WeaverColors.cloudColor,
   307	              ports: const [
   308	                WorkflowPort(id: 'in-1', label: 'trigger', isInput: true),
   309	                WorkflowPort(id: 'out-1', label: 'emails', isInput: false),
   310	              ],
   311	            ),
   312	            WorkflowNode(
   313	              id: 'node-filter',
   314	              label: 'Filter Promotions',
   315	              type: NodeType.condition,
   316	              toolId: 'logic',
   317	              toolName: 'Logic',
   318	              icon: '🔀',
   319	              position: const Offset(500, 160),
   320	              config: {'condition': 'label != CATEGORY_PROMOTIONS'},
   321	              color: WeaverColors.conditionNode,
   322	              ports: const [
   323	                WorkflowPort(id: 'in-1', label: 'emails', isInput: true),
   324	                WorkflowPort(id: 'out-true', label: 'pass', isInput: false),
   325	                WorkflowPort(id: 'out-false', label: 'skip', isInput: false),
   326	              ],
   327	            ),
   328	            WorkflowNode(
   329	              id: 'node-summarize',
   330	              label: 'AI Summarize',
   331	              type: NodeType.transform,
   332	              toolId: 'llm',
   333	              toolName: 'LLM',
   334	              icon: '🧠',
   335	              position: const Offset(720, 100),
   336	              config: {'prompt': 'Summarize these emails in bullet points'},
   337	              color: WeaverColors.accentBright,
   338	              ports: const [
   339	                WorkflowPort(id: 'in-1', label: 'emails', isInput: true),
   340	                WorkflowPort(id: 'out-1', label: 'summary', isInput: false),
   341	              ],
   342	            ),
   343	            WorkflowNode(
   344	              id: 'node-discord',
   345	              label: 'Post to Discord',
   346	              type: NodeType.output,
   347	              toolId: 'discord',
   348	              toolName: 'Discord',
   349	              icon: '🎮',
   350	              position: const Offset(940, 100),
   351	              config: {'channel_id': '1234567890', 'format': 'digest'},
   352	              color: WeaverColors.messagingColor,
   353	              ports: const [
   354	                WorkflowPort(id: 'in-1', label: 'message', isInput: true),
   355	              ],
   356	            ),
   357	          ],
   358	          edges: const [
   359	            WorkflowEdge(id: 'e1', fromNodeId: 'node-trigger', fromPortId: 'out-1', toNodeId: 'node-fetch', toPortId: 'in-1'),
   360	            WorkflowEdge(id: 'e2', fromNodeId: 'node-fetch', fromPortId: 'out-1', toNodeId: 'node-filter', toPortId: 'in-1'),
   361	            WorkflowEdge(id: 'e3', fromNodeId: 'node-filter', fromPortId: 'out-true', toNodeId: 'node-summarize', toPortId: 'in-1'),
   362	            WorkflowEdge(id: 'e4', fromNodeId: 'node-summarize', fromPortId: 'out-1', toNodeId: 'node-discord', toPortId: 'in-1'),
   363	          ],
   364	        ),
   365	        WorkflowModel(
   366	          id: 'wf-2',
   367	          name: 'Drive Backup on Edit',
   368	          description: 'Detects file changes in Drive and backs up to a timestamped folder',
   369	          chatSessionId: 'chat-1',
   370	          status: WorkflowStatus.running,
   371	          createdAt: DateTime.now().subtract(const Duration(days: 1)),
   372	          lastRun: DateTime.now().subtract(const Duration(minutes: 5)),
   373	          runCount: 23,
   374	          isActive: true,
   375	          nodes: [
   376	            WorkflowNode(
   377	              id: 'wf2-trigger',
   378	              label: 'Drive Change',
   379	              type: NodeType.trigger,
   380	              toolId: 'google-drive',
   381	              toolName: 'Google Drive',
   382	              icon: '🗂️',
   383	              position: const Offset(60, 160),
   384	              config: {'watch_folder': '/Projects'},
   385	              color: WeaverColors.triggerNode,
   386	              ports: const [WorkflowPort(id: 'out-1', label: 'file', isInput: false)],
   387	            ),
   388	            WorkflowNode(
   389	              id: 'wf2-copy',
   390	              label: 'Copy File',
   391	              type: NodeType.action,
   392	              toolId: 'google-drive',
   393	              toolName: 'Google Drive',
   394	              icon: '🗂️',
   395	              position: const Offset(280, 160),
   396	              config: {'destination': '/Backups/{{date}}'},
   397	              color: WeaverColors.cloudColor,
   398	              ports: const [
   399	                WorkflowPort(id: 'in-1', label: 'file', isInput: true),
   400	                WorkflowPort(id: 'out-1', label: 'done', isInput: false),
   401	              ],
   402	            ),
   403	            WorkflowNode(
   404	              id: 'wf2-notify',
   405	              label: 'Notify Gmail',
   406	              type: NodeType.output,
   407	              toolId: 'gmail',
   408	              toolName: 'Gmail',
   409	              icon: '✉️',
   410	              position: const Offset(500, 160),
   411	              config: {'to': 'me', 'subject': 'Backup complete'},
   412	              color: WeaverColors.cloudColor,
   413	              ports: const [WorkflowPort(id: 'in-1', label: 'done', isInput: true)],
   414	            ),
   415	          ],
   416	          edges: const [
   417	            WorkflowEdge(id: 'e1', fromNodeId: 'wf2-trigger', fromPortId: 'out-1', toNodeId: 'wf2-copy', toPortId: 'in-1'),
   418	            WorkflowEdge(id: 'e2', fromNodeId: 'wf2-copy', fromPortId: 'out-1', toNodeId: 'wf2-notify', toPortId: 'in-1'),
   419	          ],
   420	        ),
   421	        WorkflowModel(
   422	          id: 'wf-3',
   423	          name: 'Web Research → Report',
   424	          description: 'Searches the web, compiles findings, and saves to Google Drive as a report',
   425	          chatSessionId: 'chat-3',
   426	          status: WorkflowStatus.idle,
   427	          createdAt: DateTime.now().subtract(const Duration(days: 5)),
   428	          lastRun: DateTime.now().subtract(const Duration(days: 1)),
   429	          runCount: 4,
   430	          isActive: false,
   431	          nodes: [
   432	            WorkflowNode(id: 'wf3-t', label: 'Manual Trigger', type: NodeType.trigger, toolId: 'manual', toolName: 'Manual', icon: '▶️', position: const Offset(60, 160), config: {}, color: WeaverColors.triggerNode, ports: const [WorkflowPort(id: 'out-1', label: 'query', isInput: false)]),
   433	            WorkflowNode(id: 'wf3-s', label: 'Web Search', type: NodeType.action, toolId: 'web-search', toolName: 'Web Search', icon: '🌐', position: const Offset(280, 160), config: {'results': 10}, color: WeaverColors.accentBright, ports: const [WorkflowPort(id: 'in-1', label: 'query', isInput: true), WorkflowPort(id: 'out-1', label: 'results', isInput: false)]),
   434	            WorkflowNode(id: 'wf3-a', label: 'AI Compile', type: NodeType.transform, toolId: 'llm', toolName: 'LLM', icon: '🧠', position: const Offset(500, 160), config: {}, color: WeaverColors.accentBright, ports: const [WorkflowPort(id: 'in-1', label: 'results', isInput: true), WorkflowPort(id: 'out-1', label: 'report', isInput: false)]),
   435	            WorkflowNode(id: 'wf3-d', label: 'Save to Drive', type: NodeType.output, toolId: 'google-drive', toolName: 'Google Drive', icon: '🗂️', position: const Offset(720, 160), config: {'folder': '/Research'}, color: WeaverColors.cloudColor, ports: const [WorkflowPort(id: 'in-1', label: 'report', isInput: true)]),
   436	          ],
   437	          edges: const [
   438	            WorkflowEdge(id: 'e1', fromNodeId: 'wf3-t', fromPortId: 'out-1', toNodeId: 'wf3-s', toPortId: 'in-1'),
   439	            WorkflowEdge(id: 'e2', fromNodeId: 'wf3-s', fromPortId: 'out-1', toNodeId: 'wf3-a', toPortId: 'in-1'),
   440	            WorkflowEdge(id: 'e3', fromNodeId: 'wf3-a', fromPortId: 'out-1', toNodeId: 'wf3-d', toPortId: 'in-1'),
   441	          ],
   442	        ),
   443	        WorkflowModel(
   444	          id: 'wf-4',
   445	          name: 'Download Organizer',
   446	          description: 'Watches Downloads folder and sorts files into subdirectories by type',
   447	          chatSessionId: 'chat-5',
   448	          status: WorkflowStatus.error,
   449	          createdAt: DateTime.now().subtract(const Duration(days: 7)),
   450	          lastRun: DateTime.now().subtract(const Duration(hours: 1)),
   451	          runCount: 15,
   452	          isActive: false,
   453	          nodes: [
   454	            WorkflowNode(id: 'wf4-t', label: 'File Created', type: NodeType.trigger, toolId: 'filesystem', toolName: 'Filesystem', icon: '🗄️', position: const Offset(60, 160), config: {'watch': '~/Downloads'}, color: WeaverColors.triggerNode, ports: const [WorkflowPort(id: 'out-1', label: 'file', isInput: false)]),
   455	            WorkflowNode(id: 'wf4-c', label: 'Get Ext', type: NodeType.condition, toolId: 'logic', toolName: 'Logic', icon: '🔀', position: const Offset(280, 160), config: {}, color: WeaverColors.conditionNode, ports: const [WorkflowPort(id: 'in-1', label: 'file', isInput: true), WorkflowPort(id: 'out-1', label: 'category', isInput: false)]),
   456	            WorkflowNode(id: 'wf4-m', label: 'Move File', type: NodeType.action, toolId: 'filesystem', toolName: 'Filesystem', icon: '🗄️', position: const Offset(500, 160), config: {}, color: WeaverColors.filesColor, ports: const [WorkflowPort(id: 'in-1', label: 'category', isInput: true)]),
   457	          ],
   458	          edges: const [
   459	            WorkflowEdge(id: 'e1', fromNodeId: 'wf4-t', fromPortId: 'out-1', toNodeId: 'wf4-c', toPortId: 'in-1'),
   460	            WorkflowEdge(id: 'e2', fromNodeId: 'wf4-c', fromPortId: 'out-1', toNodeId: 'wf4-m', toPortId: 'in-1'),
   461	          ],
   462	        ),
   463	      ];
   464	}
```

## frontend/lib/main.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'app.dart';
     3	
     4	void main() {
     5	  WidgetsFlutterBinding.ensureInitialized();
     6	  runApp(const WeaverApp());
     7	}
```

## frontend/lib/models/models.dart

```dart
     1	import 'package:flutter/material.dart';
     2	
     3	enum ToolCategory { cloud, messaging, files, dev, productivity, ai }
     4	
     5	enum AuthStatus { connected, disconnected, pending, error }
     6	
     7	class ToolCapability {
     8	  final String name;
     9	  final String description;
    10	  final String icon;
    11	
    12	  const ToolCapability({required this.name, required this.description, required this.icon});
    13	}
    14	
    15	class ToolModel {
    16	  final String id;
    17	  final String name;
    18	  final String description;
    19	  final String logoEmoji;
    20	  final ToolCategory category;
    21	  AuthStatus authStatus;
    22	  bool isEnabled;
    23	  final List<ToolCapability> capabilities;
    24	  final int usageCount;
    25	  final String? lastUsed;
    26	  final Color categoryColor;
    27	  final Map<String, dynamic> metadata;
    28	
    29	  ToolModel({
    30	    required this.id,
    31	    required this.name,
    32	    required this.description,
    33	    required this.logoEmoji,
    34	    required this.category,
    35	    required this.authStatus,
    36	    required this.isEnabled,
    37	    required this.capabilities,
    38	    required this.usageCount,
    39	    this.lastUsed,
    40	    required this.categoryColor,
    41	    this.metadata = const {},
    42	  });
    43	}
    44	
    45	enum MessageRole { user, assistant, system, tool }
    46	
    47	class ToolCallResult {
    48	  final String toolName;
    49	  final Map<String, dynamic> arguments;
    50	  final String result;
    51	  final bool success;
    52	
    53	  const ToolCallResult({
    54	    required this.toolName,
    55	    required this.arguments,
    56	    required this.result,
    57	    required this.success,
    58	  });
    59	}
    60	
    61	class ChatMessage {
    62	  final String id;
    63	  final MessageRole role;
    64	  final String content;
    65	  final DateTime timestamp;
    66	  final ToolCallResult? toolCall;
    67	  final bool isStreaming;
    68	
    69	  const ChatMessage({
    70	    required this.id,
    71	    required this.role,
    72	    required this.content,
    73	    required this.timestamp,
    74	    this.toolCall,
    75	    this.isStreaming = false,
    76	  });
    77	}
    78	
    79	class ChatSession {
    80	  final String id;
    81	  final String title;
    82	  final String agentName;
    83	  final DateTime updatedAt;
    84	  final List<ChatMessage> messages;
    85	  final List<String> enabledToolIds;
    86	  final bool isPinned;
    87	  final int workflowCount;
    88	
    89	  const ChatSession({
    90	    required this.id,
    91	    required this.title,
    92	    required this.agentName,
    93	    required this.updatedAt,
    94	    required this.messages,
    95	    required this.enabledToolIds,
    96	    this.isPinned = false,
    97	    this.workflowCount = 0,
    98	  });
    99	}
   100	
   101	enum NodeType { trigger, action, condition, transform, output }
   102	
   103	enum WorkflowStatus { idle, running, success, error, draft }
   104	
   105	class WorkflowPort {
   106	  final String id;
   107	  final String label;
   108	  final bool isInput;
   109	
   110	  const WorkflowPort({required this.id, required this.label, required this.isInput});
   111	}
   112	
   113	class WorkflowNode {
   114	  final String id;
   115	  final String label;
   116	  final NodeType type;
   117	  final String toolId;
   118	  final String toolName;
   119	  final String icon;
   120	  Offset position;
   121	  final Map<String, dynamic> config;
   122	  final List<WorkflowPort> ports;
   123	  final Color color;
   124	
   125	  WorkflowNode({
   126	    required this.id,
   127	    required this.label,
   128	    required this.type,
   129	    required this.toolId,
   130	    required this.toolName,
   131	    required this.icon,
   132	    required this.position,
   133	    required this.config,
   134	    required this.ports,
   135	    required this.color,
   136	  });
   137	}
   138	
   139	class WorkflowEdge {
   140	  final String id;
   141	  final String fromNodeId;
   142	  final String fromPortId;
   143	  final String toNodeId;
   144	  final String toPortId;
   145	
   146	  const WorkflowEdge({
   147	    required this.id,
   148	    required this.fromNodeId,
   149	    required this.fromPortId,
   150	    required this.toNodeId,
   151	    required this.toPortId,
   152	  });
   153	}
   154	
   155	class WorkflowModel {
   156	  final String id;
   157	  final String name;
   158	  final String description;
   159	  final String chatSessionId;
   160	  WorkflowStatus status;
   161	  final DateTime createdAt;
   162	  DateTime? lastRun;
   163	  final int runCount;
   164	  final List<WorkflowNode> nodes;
   165	  final List<WorkflowEdge> edges;
   166	  final bool isActive;
   167	
   168	  WorkflowModel({
   169	    required this.id,
   170	    required this.name,
   171	    required this.description,
   172	    required this.chatSessionId,
   173	    required this.status,
   174	    required this.createdAt,
   175	    this.lastRun,
   176	    required this.runCount,
   177	    required this.nodes,
   178	    required this.edges,
   179	    required this.isActive,
   180	  });
   181	}
   182	
   183	class AgentModel {
   184	  final String id;
   185	  final String name;
   186	  final String description;
   187	  final String model;
   188	  final String systemPrompt;
   189	  final List<String> enabledToolIds;
   190	  final bool isActive;
   191	
   192	  const AgentModel({
   193	    required this.id,
   194	    required this.name,
   195	    required this.description,
   196	    required this.model,
   197	    required this.systemPrompt,
   198	    required this.enabledToolIds,
   199	    required this.isActive,
   200	  });
   201	}
   202	
   203	class LlmModel {
   204	  final String id;
   205	  final String name;
   206	  final String provider;
   207	  final int contextWindow;
   208	  final bool isLocal;
   209	  final String description;
   210	
   211	  const LlmModel({
   212	    required this.id,
   213	    required this.name,
   214	    required this.provider,
   215	    required this.contextWindow,
   216	    required this.isLocal,
   217	    required this.description,
   218	  });
   219	}
```

## frontend/lib/providers/providers.dart

```dart
     1	import 'dart:convert';
     2	
     3	import 'package:flutter/material.dart';
     4	import 'package:uuid/uuid.dart';
     5	import '../services/backend_api.dart';
     6	import '../models/models.dart';
     7	import '../data/mock_data.dart';
     8	
     9	// ── App State Provider ────────────────────────────────────────────────────────
    10	class AppState extends ChangeNotifier {
    11	  // Navigation
    12	  int _navIndex = 0;
    13	  int get navIndex => _navIndex;
    14	
    15	  void setNavIndex(int i) {
    16	    _navIndex = i;
    17	    notifyListeners();
    18	  }
    19	
    20	  // Right sidebar
    21	  bool _rightSidebarOpen = true;
    22	  bool get rightSidebarOpen => _rightSidebarOpen;
    23	
    24	  int _rightPanelTab = 0; // 0=tools, 1=workflows, 2=model
    25	  int get rightPanelTab => _rightPanelTab;
    26	
    27	  void setRightPanelTab(int i) {
    28	    _rightPanelTab = i;
    29	    _rightSidebarOpen = true;
    30	    notifyListeners();
    31	  }
    32	
    33	  void toggleRightSidebar() {
    34	    _rightSidebarOpen = !_rightSidebarOpen;
    35	    notifyListeners();
    36	  }
    37	
    38	  // Left sidebar
    39	  bool _leftSidebarOpen = true;
    40	  bool get leftSidebarOpen => _leftSidebarOpen;
    41	
    42	  void toggleLeftSidebar() {
    43	    _leftSidebarOpen = !_leftSidebarOpen;
    44	    notifyListeners();
    45	  }
    46	}
    47	
    48	// ── Backend Provider ──────────────────────────────────────────────────────────
    49	class BackendProvider extends ChangeNotifier {
    50	  final BackendPreferences _prefs = BackendPreferences();
    51	  final BackendRuntime _runtime = BackendRuntime();
    52	
    53	  late BackendApi _api;
    54	  String _baseUrl = 'http://127.0.0.1:8000';
    55	  String _discordChannelId = '';
    56	  String _llmApiKey = '';
    57	  String _llmBaseUrl = 'https://api.openai.com/v1';
    58	  String _filesystemRoot = '';
    59	  Map<String, dynamic> _googleUserInfo = const {};
    60	  Map<String, dynamic> _discordUserInfo = const {};
    61	  Map<String, dynamic> _discordBotStatus = const {};
    62	  bool _autoStartBackend = true;
    63	  bool _isConnected = false;
    64	  bool _isStarting = false;
    65	  String? _lastError;
    66	
    67	  String get baseUrl => _baseUrl;
    68	  String get discordChannelId => _discordChannelId;
    69	  String get llmApiKey => _llmApiKey;
    70	  String get llmBaseUrl => _llmBaseUrl;
    71	  String get filesystemRoot => _filesystemRoot;
    72	  Map<String, dynamic> get googleUserInfo => _googleUserInfo;
    73	  Map<String, dynamic> get discordUserInfo => _discordUserInfo;
    74	  Map<String, dynamic> get discordBotStatus => _discordBotStatus;
    75	  bool get autoStartBackend => _autoStartBackend;
    76	  bool get isConnected => _isConnected;
    77	  bool get isStarting => _isStarting;
    78	  String? get lastError => _lastError;
    79	
    80	  Future<void> initialize() async {
    81	    _baseUrl = await _prefs.loadBaseUrl();
    82	    _discordChannelId = await _prefs.loadDiscordChannelId();
    83	    _llmApiKey = await _prefs.loadLlmApiKey();
    84	    _llmBaseUrl = await _prefs.loadLlmBaseUrl();
    85	    _filesystemRoot = await _prefs.loadFilesystemRoot();
    86	    _autoStartBackend = await _prefs.loadAutoStart();
    87	    _api = BackendApi(_baseUrl);
    88	
    89	    if (_autoStartBackend) {
    90	      await ensureBackendRunning();
    91	    } else {
    92	      await refreshHealth();
    93	    }
    94	
    95	    if (_isConnected) {
    96	      await _syncFilesystemRootIfNeeded();
    97	      await refreshUserInfo();
    98	      await refreshDiscordBotStatus();
    99	    }
   100	  }
   101	
   102	  Future<void> setBaseUrl(String value) async {
   103	    final trimmed = value.trim();
   104	    if (trimmed.isEmpty) return;
   105	    _baseUrl = trimmed;
   106	    _api.baseUrl = trimmed;
   107	    await _prefs.saveBaseUrl(trimmed);
   108	    await refreshHealth();
   109	    notifyListeners();
   110	  }
   111	
   112	  Future<void> setDiscordChannelId(String value) async {
   113	    _discordChannelId = value.trim();
   114	    await _prefs.saveDiscordChannelId(_discordChannelId);
   115	    notifyListeners();
   116	  }
   117	
   118	  Future<void> setLlmApiKey(String value) async {
   119	    _llmApiKey = value.trim();
   120	    await _prefs.saveLlmApiKey(_llmApiKey);
   121	    notifyListeners();
   122	  }
   123	
   124	  Future<void> setLlmBaseUrl(String value) async {
   125	    final trimmed = value.trim();
   126	    if (trimmed.isEmpty) return;
   127	    _llmBaseUrl = trimmed;
   128	    await _prefs.saveLlmBaseUrl(_llmBaseUrl);
   129	    notifyListeners();
   130	  }
   131	
   132	  Future<void> setFilesystemRoot(String value) async {
   133	    final trimmed = value.trim();
   134	    if (trimmed.isEmpty) return;
   135	    await ensureBackendRunning();
   136	    final out = await _api
   137	        .postJson('/api/v1/tools/filesystem/root', {'allowed_root': trimmed});
   138	    _filesystemRoot = out['allowed_root']?.toString() ?? trimmed;
   139	    await _prefs.saveFilesystemRoot(_filesystemRoot);
   140	    notifyListeners();
   141	  }
   142	
   143	  Future<void> setAutoStartBackend(bool value) async {
   144	    _autoStartBackend = value;
   145	    await _prefs.saveAutoStart(value);
   146	    if (value) {
   147	      await ensureBackendRunning();
   148	    }
   149	    notifyListeners();
   150	  }
   151	
   152	  Future<void> refreshHealth() async {
   153	    final ok = await _runtime.isHealthy(_baseUrl);
   154	    _isConnected = ok;
   155	    if (ok) {
   156	      _lastError = null;
   157	    }
   158	    notifyListeners();
   159	  }
   160	
   161	  Future<void> ensureBackendRunning() async {
   162	    _isStarting = true;
   163	    _lastError = null;
   164	    notifyListeners();
   165	    try {
   166	      await _runtime.ensureRunning(_baseUrl);
   167	      _isConnected = true;
   168	    } catch (exc) {
   169	      _isConnected = false;
   170	      _lastError = '$exc';
   171	    } finally {
   172	      _isStarting = false;
   173	      notifyListeners();
   174	    }
   175	  }
   176	
   177	  Future<List<Map<String, dynamic>>> fetchToolCatalog() async {
   178	    final out = await _api.getJsonList('/api/v1/tools/catalog');
   179	    return out.cast<Map<String, dynamic>>();
   180	  }
   181	
   182	  Future<List<Map<String, dynamic>>> fetchToolStates() async {
   183	    final out = await _api.getJsonList('/api/v1/tools/cards/state');
   184	    return out.cast<Map<String, dynamic>>();
   185	  }
   186	
   187	  Future<Map<String, dynamic>> fetchAuthStatus(String provider) async {
   188	    return _api.getJson('/api/v1/auth/$provider/status');
   189	  }
   190	
   191	  Future<Map<String, dynamic>> fetchProviderUserInfo(String provider) async {
   192	    return _api.getJson('/api/v1/auth/$provider/userinfo');
   193	  }
   194	
   195	  Future<void> refreshUserInfo() async {
   196	    await ensureBackendRunning();
   197	    try {
   198	      _googleUserInfo = await fetchProviderUserInfo('google');
   199	    } catch (_) {
   200	      _googleUserInfo = const {};
   201	    }
   202	    try {
   203	      _discordUserInfo = await fetchProviderUserInfo('discord');
   204	    } catch (_) {
   205	      _discordUserInfo = const {};
   206	    }
   207	    notifyListeners();
   208	  }
   209	
   210	  Future<void> refreshDiscordBotStatus() async {
   211	    await ensureBackendRunning();
   212	    try {
   213	      _discordBotStatus = await _api.getJson('/api/v1/auth/discord/bot-status');
   214	    } catch (_) {
   215	      _discordBotStatus = const {};
   216	    }
   217	    notifyListeners();
   218	  }
   219	
   220	  Future<void> refreshFilesystemRoot() async {
   221	    await ensureBackendRunning();
   222	    try {
   223	      final out = await _api.getJson('/api/v1/tools/filesystem/root');
   224	      _filesystemRoot = out['allowed_root']?.toString() ?? _filesystemRoot;
   225	      await _prefs.saveFilesystemRoot(_filesystemRoot);
   226	      notifyListeners();
   227	    } catch (_) {}
   228	  }
   229	
   230	  Future<void> startOAuth(String provider) async {
   231	    await ensureBackendRunning();
   232	    final out = await _api.getJson('/api/v1/auth/$provider/connect');
   233	    final url = out['auth_url']?.toString();
   234	    if (url == null || url.isEmpty) {
   235	      throw Exception('Missing auth URL for provider $provider');
   236	    }
   237	    await openExternalUrl(url);
   238	  }
   239	
   240	  Future<Map<String, dynamic>> sendAgentPrompt({
   241	    required String prompt,
   242	    required List<String> enabledToolIds,
   243	    String? modelName,
   244	    String? systemPrompt,
   245	    String? discordChannelId,
   246	    String? llmApiKey,
   247	    String? llmBaseUrl,
   248	    List<Map<String, String>> history = const [],
   249	  }) async {
   250	    await ensureBackendRunning();
   251	    return _api.postJson('/api/v1/chat/agent', {
   252	      'prompt': prompt,
   253	      'enabled_tool_ids': enabledToolIds,
   254	      'model_name': modelName,
   255	      'system_prompt': systemPrompt,
   256	      'discord_channel_id': discordChannelId,
   257	      'llm_api_key': llmApiKey,
   258	      'llm_base_url': llmBaseUrl,
   259	      'history': history,
   260	    });
   261	  }
   262	
   263	  Future<void> _syncFilesystemRootIfNeeded() async {
   264	    if (_filesystemRoot.isEmpty) {
   265	      await refreshFilesystemRoot();
   266	      return;
   267	    }
   268	    try {
   269	      await _api.postJson(
   270	          '/api/v1/tools/filesystem/root', {'allowed_root': _filesystemRoot});
   271	    } catch (_) {
   272	      await refreshFilesystemRoot();
   273	    }
   274	  }
   275	
   276	  @override
   277	  void dispose() {
   278	    _runtime.stop();
   279	    super.dispose();
   280	  }
   281	}
   282	
   283	// ── Chat Provider ─────────────────────────────────────────────────────────────
   284	class ChatProvider extends ChangeNotifier {
   285	  final BackendPreferences _prefs = BackendPreferences();
   286	  final Uuid _uuid = const Uuid();
   287	
   288	  List<ChatSession> _sessions = [];
   289	  List<ChatSession> get sessions => _sessions;
   290	
   291	  String? _activeSessionId;
   292	  String? get activeSessionId => _activeSessionId;
   293	
   294	  ChatSession? get activeSession =>
   295	      _sessions.where((s) => s.id == _activeSessionId).firstOrNull;
   296	
   297	  // Open tabs (VSCode style)
   298	  final List<String> _openTabIds = [];
   299	  List<String> get openTabIds => List.unmodifiable(_openTabIds);
   300	
   301	  String? _activeTabId;
   302	  String? get activeTabId => _activeTabId;
   303	
   304	  BackendProvider? _backend;
   305	  ToolsProvider? _toolsProvider;
   306	  ModelProvider? _modelProvider;
   307	  bool _didHydrate = false;
   308	
   309	  final TextEditingController inputController = TextEditingController();
   310	  bool _isTyping = false;
   311	  bool get isTyping => _isTyping;
   312	  String? _typingSessionId;
   313	
   314	  bool isTypingFor(String sessionId) =>
   315	      _isTyping && _typingSessionId == sessionId;
   316	
   317	  void bind(BackendProvider backend, ToolsProvider toolsProvider,
   318	      ModelProvider modelProvider) {
   319	    _backend = backend;
   320	    _toolsProvider = toolsProvider;
   321	    _modelProvider = modelProvider;
   322	    _hydrateIfNeeded();
   323	    if (_sessions.isEmpty && !_didHydrate) {
   324	      final initial = _newSession();
   325	      _sessions = [initial];
   326	      openSession(initial.id);
   327	    }
   328	  }
   329	
   330	  void openSession(String sessionId) {
   331	    if (!_openTabIds.contains(sessionId)) {
   332	      _openTabIds.add(sessionId);
   333	    }
   334	    _activeSessionId = sessionId;
   335	    _activeTabId = sessionId;
   336	    _persistState();
   337	    notifyListeners();
   338	  }
   339	
   340	  void closeTab(String sessionId) {
   341	    _openTabIds.remove(sessionId);
   342	    if (_activeTabId == sessionId) {
   343	      _activeTabId = _openTabIds.isNotEmpty ? _openTabIds.last : null;
   344	      _activeSessionId = _activeTabId;
   345	    }
   346	    _persistState();
   347	    notifyListeners();
   348	  }
   349	
   350	  void setActiveTab(String sessionId) {
   351	    _activeTabId = sessionId;
   352	    _activeSessionId = sessionId;
   353	    _persistState();
   354	    notifyListeners();
   355	  }
   356	
   357	  Future<void> sendMessage(String content) async {
   358	    if (content.trim().isEmpty || _activeSessionId == null) return;
   359	    final sessionId = _activeSessionId!;
   360	    final idx = _sessionIndex(sessionId);
   361	    if (idx == -1) return;
   362	
   363	    final userMsg = ChatMessage(
   364	      id: _newMessageId('u'),
   365	      role: MessageRole.user,
   366	      content: content.trim(),
   367	      timestamp: DateTime.now(),
   368	    );
   369	
   370	    // Add user message
   371	    final updated = List<ChatMessage>.from(_sessions[idx].messages)
   372	      ..add(userMsg);
   373	    _sessions[idx] = ChatSession(
   374	      id: _sessions[idx].id,
   375	      title: _sessions[idx].title,
   376	      agentName: _sessions[idx].agentName,
   377	      updatedAt: DateTime.now(),
   378	      messages: updated,
   379	      enabledToolIds: _sessions[idx].enabledToolIds,
   380	      isPinned: _sessions[idx].isPinned,
   381	      workflowCount: _sessions[idx].workflowCount,
   382	    );
   383	    inputController.clear();
   384	    _isTyping = true;
   385	    _typingSessionId = sessionId;
   386	    notifyListeners();
   387	
   388	    try {
   389	      final backend = _backend;
   390	      final toolsProvider = _toolsProvider;
   391	      final modelProvider = _modelProvider;
   392	      if (backend == null || toolsProvider == null || modelProvider == null) {
   393	        throw Exception('Backend integration is not initialized.');
   394	      }
   395	
   396	      final activeTools = toolsProvider.tools
   397	          .where((t) => t.isEnabled)
   398	          .map((t) => t.id)
   399	          .toList(growable: false);
   400	
   401	      final out = await backend.sendAgentPrompt(
   402	        prompt: content.trim(),
   403	        enabledToolIds: activeTools,
   404	        modelName: modelProvider.modelName,
   405	        systemPrompt: modelProvider.systemPrompt,
   406	        discordChannelId:
   407	            backend.discordChannelId.isEmpty ? null : backend.discordChannelId,
   408	        llmApiKey: backend.llmApiKey.isEmpty ? null : backend.llmApiKey,
   409	        llmBaseUrl: backend.llmBaseUrl,
   410	        history: _historyForBackend(_messagesForSession(sessionId)),
   411	      );
   412	
   413	      final toolCalls = (out['tool_calls'] as List<dynamic>? ?? const [])
   414	          .cast<Map<String, dynamic>>();
   415	      for (final toolCall in toolCalls) {
   416	        final result =
   417	            (toolCall['result'] as Map<String, dynamic>? ?? const {});
   418	        final status = result['status']?.toString() ?? 'unknown';
   419	        final summary = result['result']?.toString() ?? status;
   420	
   421	        final toolMsg = ChatMessage(
   422	          id: _newMessageId('t'),
   423	          role: MessageRole.assistant,
   424	          content: '',
   425	          timestamp: DateTime.now(),
   426	          toolCall: ToolCallResult(
   427	            toolName: toolCall['tool_id']?.toString() ?? 'tool',
   428	            arguments: const {},
   429	            result: summary,
   430	            success: status == 'ok',
   431	          ),
   432	        );
   433	        _appendMessageBySession(sessionId, toolMsg);
   434	      }
   435	
   436	      final chat = (out['chat'] as Map<String, dynamic>? ?? const {});
   437	      final chatError = out['chat_error']?.toString();
   438	      final assistantContent =
   439	          (chat['content']?.toString().trim().isNotEmpty ?? false)
   440	              ? chat['content'].toString()
   441	              : (chatError != null && chatError.isNotEmpty
   442	                  ? 'Agent note: $chatError'
   443	                  : 'Request completed.');
   444	
   445	      final assistantMsg = ChatMessage(
   446	        id: _newMessageId('a'),
   447	        role: MessageRole.assistant,
   448	        content: assistantContent,
   449	        timestamp: DateTime.now(),
   450	      );
   451	      _appendMessageBySession(sessionId, assistantMsg);
   452	      _refreshSessionTitleById(sessionId);
   453	    } catch (exc) {
   454	      final assistantMsg = ChatMessage(
   455	        id: _newMessageId('a'),
   456	        role: MessageRole.assistant,
   457	        content: 'Failed to process request: $exc',
   458	        timestamp: DateTime.now(),
   459	      );
   460	      _appendMessageBySession(sessionId, assistantMsg);
   461	    } finally {
   462	      if (_typingSessionId == sessionId) {
   463	        _isTyping = false;
   464	        _typingSessionId = null;
   465	      }
   466	      _persistState();
   467	      notifyListeners();
   468	    }
   469	  }
   470	
   471	  void newChat() {
   472	    final session = _newSession();
   473	    _sessions.insert(0, session);
   474	    openSession(session.id);
   475	    _persistState();
   476	    notifyListeners();
   477	  }
   478	
   479	  @override
   480	  void dispose() {
   481	    inputController.dispose();
   482	    super.dispose();
   483	  }
   484	
   485	  void _appendMessageBySession(String sessionId, ChatMessage message) {
   486	    final idx = _sessionIndex(sessionId);
   487	    if (idx == -1) {
   488	      return;
   489	    }
   490	    final updated = List<ChatMessage>.from(_sessions[idx].messages)
   491	      ..add(message);
   492	    _sessions[idx] = ChatSession(
   493	      id: _sessions[idx].id,
   494	      title: _sessions[idx].title,
   495	      agentName: _sessions[idx].agentName,
   496	      updatedAt: DateTime.now(),
   497	      messages: updated,
   498	      enabledToolIds: _sessions[idx].enabledToolIds,
   499	      isPinned: _sessions[idx].isPinned,
   500	      workflowCount: _sessions[idx].workflowCount,
   501	    );
   502	    _persistState();
   503	  }
   504	
   505	  int _sessionIndex(String sessionId) {
   506	    return _sessions.indexWhere((s) => s.id == sessionId);
   507	  }
   508	
   509	  List<ChatMessage> _messagesForSession(String sessionId) {
   510	    final idx = _sessionIndex(sessionId);
   511	    if (idx == -1) {
   512	      return const [];
   513	    }
   514	    return _sessions[idx].messages;
   515	  }
   516	
   517	  List<Map<String, String>> _historyForBackend(List<ChatMessage> messages) {
   518	    final out = <Map<String, String>>[];
   519	    for (final msg in messages) {
   520	      if (msg.content.trim().isEmpty) {
   521	        continue;
   522	      }
   523	      final role = switch (msg.role) {
   524	        MessageRole.user => 'user',
   525	        MessageRole.assistant => 'assistant',
   526	        MessageRole.system => 'system',
   527	        MessageRole.tool => 'assistant',
   528	      };
   529	      out.add({'role': role, 'content': msg.content});
   530	    }
   531	    if (out.length > 20) {
   532	      return out.sublist(out.length - 20);
   533	    }
   534	    return out;
   535	  }
   536	
   537	  void _refreshSessionTitleById(String sessionId) {
   538	    final idx = _sessionIndex(sessionId);
   539	    if (idx == -1) {
   540	      return;
   541	    }
   542	    final session = _sessions[idx];
   543	    if (session.title != 'New conversation') {
   544	      return;
   545	    }
   546	    final firstUser =
   547	        session.messages.where((m) => m.role == MessageRole.user).firstOrNull;
   548	    if (firstUser == null) {
   549	      return;
   550	    }
   551	    final cleaned = firstUser.content.trim().replaceAll('\n', ' ');
   552	    if (cleaned.isEmpty) {
   553	      return;
   554	    }
   555	    final title =
   556	        cleaned.length > 48 ? '${cleaned.substring(0, 48)}...' : cleaned;
   557	    _sessions[idx] = ChatSession(
   558	      id: session.id,
   559	      title: title,
   560	      agentName: session.agentName,
   561	      updatedAt: session.updatedAt,
   562	      messages: session.messages,
   563	      enabledToolIds: session.enabledToolIds,
   564	      isPinned: session.isPinned,
   565	      workflowCount: session.workflowCount,
   566	    );
   567	  }
   568	
   569	  Future<void> _hydrateIfNeeded() async {
   570	    if (_didHydrate) {
   571	      return;
   572	    }
   573	    _didHydrate = true;
   574	    final raw = await _prefs.loadChatSessionsJson();
   575	    if (raw.isEmpty) {
   576	      if (_sessions.isEmpty) {
   577	        final initial = _newSession();
   578	        _sessions = [initial];
   579	        _activeSessionId = initial.id;
   580	        _activeTabId = initial.id;
   581	        _openTabIds
   582	          ..clear()
   583	          ..add(initial.id);
   584	        notifyListeners();
   585	      }
   586	      return;
   587	    }
   588	
   589	    try {
   590	      final parsed = jsonDecode(raw) as List<dynamic>;
   591	      _sessions = _normalizeSessions(
   592	        parsed
   593	          .map((e) => _sessionFromJson(e as Map<String, dynamic>))
   594	          .toList(),
   595	      );
   596	
   597	      if (_sessions.isEmpty) {
   598	        final initial = _newSession();
   599	        _sessions = [initial];
   600	      }
   601	
   602	      final savedActive = await _prefs.loadActiveChatSessionId();
   603	      final active = _sessions.any((s) => s.id == savedActive)
   604	          ? savedActive
   605	          : _sessions.first.id;
   606	      _activeSessionId = active;
   607	      _activeTabId = active;
   608	      _openTabIds
   609	        ..clear()
   610	        ..add(active!);
   611	
   612	      _persistState();
   613	      notifyListeners();
   614	    } catch (_) {
   615	      final initial = _newSession();
   616	      _sessions = [initial];
   617	      _activeSessionId = initial.id;
   618	      _activeTabId = initial.id;
   619	      _openTabIds
   620	        ..clear()
   621	        ..add(initial.id);
   622	      _persistState();
   623	      notifyListeners();
   624	    }
   625	  }
   626	
   627	  void _persistState() {
   628	    final jsonList =
   629	        jsonEncode(_sessions.map(_sessionToJson).toList(growable: false));
   630	    _prefs.saveChatSessionsJson(jsonList);
   631	    _prefs.saveActiveChatSessionId(_activeSessionId);
   632	  }
   633	
   634	  Map<String, dynamic> _sessionToJson(ChatSession session) {
   635	    return {
   636	      'id': session.id,
   637	      'title': session.title,
   638	      'agentName': session.agentName,
   639	      'updatedAt': session.updatedAt.toIso8601String(),
   640	      'enabledToolIds': session.enabledToolIds,
   641	      'isPinned': session.isPinned,
   642	      'workflowCount': session.workflowCount,
   643	      'messages': session.messages.map(_messageToJson).toList(growable: false),
   644	    };
   645	  }
   646	
   647	  ChatSession _sessionFromJson(Map<String, dynamic> data) {
   648	    return ChatSession(
   649	      id: data['id']?.toString() ?? _newSessionId(),
   650	      title: data['title']?.toString() ?? 'New conversation',
   651	      agentName: data['agentName']?.toString() ?? 'Weaver Agent',
   652	      updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? '') ??
   653	          DateTime.now(),
   654	      messages: ((data['messages'] as List<dynamic>? ?? const [])
   655	          .map((e) => _messageFromJson(e as Map<String, dynamic>))
   656	          .toList()),
   657	      enabledToolIds: ((data['enabledToolIds'] as List<dynamic>? ??
   658	              const ['gmail', 'google-drive', 'discord', 'filesystem'])
   659	          .map((e) => e.toString())
   660	          .toList()),
   661	      isPinned: data['isPinned'] == true,
   662	      workflowCount: (data['workflowCount'] as num?)?.toInt() ?? 0,
   663	    );
   664	  }
   665	
   666	  Map<String, dynamic> _messageToJson(ChatMessage msg) {
   667	    return {
   668	      'id': msg.id,
   669	      'role': msg.role.name,
   670	      'content': msg.content,
   671	      'timestamp': msg.timestamp.toIso8601String(),
   672	      'toolCall': msg.toolCall == null
   673	          ? null
   674	          : {
   675	              'toolName': msg.toolCall!.toolName,
   676	              'arguments': msg.toolCall!.arguments,
   677	              'result': msg.toolCall!.result,
   678	              'success': msg.toolCall!.success,
   679	            },
   680	    };
   681	  }
   682	
   683	  ChatMessage _messageFromJson(Map<String, dynamic> data) {
   684	    final toolCallRaw = data['toolCall'];
   685	    ToolCallResult? toolCall;
   686	    if (toolCallRaw is Map<String, dynamic>) {
   687	      toolCall = ToolCallResult(
   688	        toolName: toolCallRaw['toolName']?.toString() ?? 'tool',
   689	        arguments:
   690	            (toolCallRaw['arguments'] as Map<String, dynamic>? ?? const {}),
   691	        result: toolCallRaw['result']?.toString() ?? '',
   692	        success: toolCallRaw['success'] == true,
   693	      );
   694	    }
   695	    final roleName = data['role']?.toString() ?? 'assistant';
   696	    final role = MessageRole.values.firstWhere(
   697	      (e) => e.name == roleName,
   698	      orElse: () => MessageRole.assistant,
   699	    );
   700	    return ChatMessage(
   701	      id: data['id']?.toString() ?? _newMessageId('m'),
   702	      role: role,
   703	      content: data['content']?.toString() ?? '',
   704	      timestamp: DateTime.tryParse(data['timestamp']?.toString() ?? '') ??
   705	          DateTime.now(),
   706	      toolCall: toolCall,
   707	    );
   708	  }
   709	
   710	  ChatSession _newSession() {
   711	    return ChatSession(
   712	      id: _newSessionId(),
   713	      title: 'New conversation',
   714	      agentName: 'Weaver Agent',
   715	      updatedAt: DateTime.now(),
   716	      messages: const [],
   717	      enabledToolIds: const ['gmail', 'google-drive', 'discord', 'filesystem'],
   718	    );
   719	  }
   720	
   721	  String _newSessionId() => 'chat-${_uuid.v4()}';
   722	
   723	  String _newMessageId(String prefix) => '$prefix-${_uuid.v4()}';
   724	
   725	  List<ChatSession> _normalizeSessions(List<ChatSession> input) {
   726	    final seenIds = <String>{};
   727	    final normalized = <ChatSession>[];
   728	    for (final session in input) {
   729	      final needsNewId = session.id.trim().isEmpty || seenIds.contains(session.id);
   730	      final id = needsNewId ? _newSessionId() : session.id;
   731	      seenIds.add(id);
   732	      normalized.add(ChatSession(
   733	        id: id,
   734	        title: session.title,
   735	        agentName: session.agentName,
   736	        updatedAt: session.updatedAt,
   737	        messages: session.messages,
   738	        enabledToolIds: session.enabledToolIds,
   739	        isPinned: session.isPinned,
   740	        workflowCount: session.workflowCount,
   741	      ));
   742	    }
   743	    return normalized;
   744	  }
   745	}
   746	
   747	// ── Tools Provider ────────────────────────────────────────────────────────────
   748	class ToolsProvider extends ChangeNotifier {
   749	  List<ToolModel> _tools = [];
   750	  List<ToolModel> get tools => _tools;
   751	
   752	  String _searchQuery = '';
   753	  String get searchQuery => _searchQuery;
   754	
   755	  ToolCategory? _filterCategory;
   756	  ToolCategory? get filterCategory => _filterCategory;
   757	
   758	  String? _expandedToolId;
   759	  String? get expandedToolId => _expandedToolId;
   760	
   761	  BackendProvider? _backend;
   762	  bool _loading = false;
   763	  bool get isLoading => _loading;
   764	  String? _lastError;
   765	  String? get lastError => _lastError;
   766	  final Map<String, Map<String, dynamic>> _cardMetadataByProvider = {};
   767	
   768	  Map<String, dynamic> metadataForProvider(String provider) =>
   769	      _cardMetadataByProvider[provider] ?? const {};
   770	
   771	  void bindBackend(BackendProvider backend) {
   772	    _backend = backend;
   773	    if (_tools.isEmpty || (backend.isConnected && !_loading)) {
   774	      refreshFromBackend();
   775	    }
   776	  }
   777	
   778	  List<ToolModel> get filteredTools {
   779	    return _tools.where((t) {
   780	      final matchesSearch = _searchQuery.isEmpty ||
   781	          t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
   782	          t.description.toLowerCase().contains(_searchQuery.toLowerCase());
   783	      final matchesCategory =
   784	          _filterCategory == null || t.category == _filterCategory;
   785	      return matchesSearch && matchesCategory;
   786	    }).toList();
   787	  }
   788	
   789	  void setSearch(String q) {
   790	    _searchQuery = q;
   791	    notifyListeners();
   792	  }
   793	
   794	  void setCategory(ToolCategory? c) {
   795	    _filterCategory = c;
   796	    notifyListeners();
   797	  }
   798	
   799	  void toggleExpanded(String toolId) {
   800	    _expandedToolId = _expandedToolId == toolId ? null : toolId;
   801	    notifyListeners();
   802	  }
   803	
   804	  void toggleEnabled(String toolId) {
   805	    final idx = _tools.indexWhere((t) => t.id == toolId);
   806	    if (idx == -1) return;
   807	    _tools[idx].isEnabled = !_tools[idx].isEnabled;
   808	    notifyListeners();
   809	  }
   810	
   811	  Future<void> connectTool(String toolId) async {
   812	    final backend = _backend;
   813	    if (backend == null) return;
   814	
   815	    final provider = switch (toolId) {
   816	      'gmail' || 'google-drive' => 'google',
   817	      'discord' => 'discord',
   818	      _ => null,
   819	    };
   820	
   821	    if (provider == null) return;
   822	    _applyProviderAuth(provider, AuthStatus.pending);
   823	    notifyListeners();
   824	
   825	    try {
   826	      await backend.startOAuth(provider);
   827	      for (var i = 0; i < 120; i++) {
   828	        await Future<void>.delayed(const Duration(seconds: 1));
   829	        final status = await backend.fetchAuthStatus(provider);
   830	        if (status['authenticated'] == true) {
   831	          await backend.refreshUserInfo();
   832	          await refreshFromBackend();
   833	          _applyProviderAuth(provider, AuthStatus.connected);
   834	          notifyListeners();
   835	          return;
   836	        }
   837	      }
   838	      _applyProviderAuth(provider, AuthStatus.disconnected);
   839	      notifyListeners();
   840	    } catch (_) {
   841	      _applyProviderAuth(provider, AuthStatus.error);
   842	      notifyListeners();
   843	    }
   844	  }
   845	
   846	  int get connectedCount =>
   847	      _tools.where((t) => t.authStatus == AuthStatus.connected).length;
   848	  int get enabledCount => _tools.where((t) => t.isEnabled).length;
   849	
   850	  Future<void> refreshFromBackend() async {
   851	    final backend = _backend;
   852	    if (backend == null) return;
   853	    _loading = true;
   854	    _lastError = null;
   855	    notifyListeners();
   856	
   857	    try {
   858	      await backend.ensureBackendRunning();
   859	      final catalog = await backend.fetchToolCatalog();
   860	      final cards = await backend.fetchToolStates();
   861	      _cardMetadataByProvider
   862	        ..clear()
   863	        ..addEntries(cards.map((card) => MapEntry(
   864	              card['provider']?.toString() ?? '',
   865	              (card['metadata'] as Map<String, dynamic>? ?? const {}),
   866	            )));
   867	      await backend.refreshFilesystemRoot();
   868	      await backend.refreshUserInfo();
   869	      await backend.refreshDiscordBotStatus();
   870	      _tools = _buildTools(catalog, cards, previous: _tools);
   871	    } catch (exc) {
   872	      _lastError = '$exc';
   873	      if (_tools.isEmpty) {
   874	        _tools = _fallbackTools();
   875	      }
   876	    } finally {
   877	      _loading = false;
   878	      notifyListeners();
   879	    }
   880	  }
   881	
   882	  void _applyProviderAuth(String provider, AuthStatus status) {
   883	    for (final tool in _tools) {
   884	      final belongs = (provider == 'google' &&
   885	              (tool.id == 'gmail' || tool.id == 'google-drive')) ||
   886	          (provider == 'discord' && tool.id == 'discord');
   887	      if (!belongs) continue;
   888	      tool.authStatus = status;
   889	      if (status == AuthStatus.connected) {
   890	        tool.isEnabled = true;
   891	      }
   892	    }
   893	  }
   894	
   895	  List<ToolModel> _buildTools(
   896	    List<Map<String, dynamic>> catalog,
   897	    List<Map<String, dynamic>> cards, {
   898	    required List<ToolModel> previous,
   899	  }) {
   900	    final previousEnabled = {for (final t in previous) t.id: t.isEnabled};
   901	    final statusByProvider = <String, AuthStatus>{
   902	      for (final card in cards)
   903	        card['provider'].toString():
   904	            _mapAuthStatus(card['status']?.toString() ?? ''),
   905	    };
   906	
   907	    List<ToolCapability> capsForPrefix(String prefix) {
   908	      final matching = catalog
   909	          .where((e) => (e['tool_id']?.toString() ?? '').startsWith(prefix))
   910	          .toList();
   911	      return matching
   912	          .map((e) => ToolCapability(
   913	                name: e['display_name']?.toString() ??
   914	                    e['tool_id']?.toString() ??
   915	                    'Capability',
   916	                description: e['description']?.toString() ?? '',
   917	                icon: '•',
   918	              ))
   919	          .toList();
   920	    }
   921	
   922	    return [
   923	      ToolModel(
   924	        id: 'gmail',
   925	        name: 'Gmail',
   926	        description: 'Read latest emails and thread summaries via Google APIs.',
   927	        logoEmoji: '✉️',
   928	        category: ToolCategory.cloud,
   929	        authStatus: statusByProvider['google'] ?? AuthStatus.disconnected,
   930	        isEnabled: previousEnabled['gmail'] ?? true,
   931	        capabilities: capsForPrefix('google.gmail.'),
   932	        usageCount: 0,
   933	        lastUsed: null,
   934	        categoryColor: const Color(0xFF42A5F5),
   935	        metadata: _cardMetadataByProvider['google'] ?? const {},
   936	      ),
   937	      ToolModel(
   938	        id: 'google-drive',
   939	        name: 'Google Drive',
   940	        description:
   941	            'Browse Drive files and metadata from your connected account.',
   942	        logoEmoji: '🗂️',
   943	        category: ToolCategory.cloud,
   944	        authStatus: statusByProvider['google'] ?? AuthStatus.disconnected,
   945	        isEnabled: previousEnabled['google-drive'] ?? true,
   946	        capabilities: capsForPrefix('google.drive.'),
   947	        usageCount: 0,
   948	        lastUsed: null,
   949	        categoryColor: const Color(0xFF42A5F5),
   950	        metadata: _cardMetadataByProvider['google'] ?? const {},
   951	      ),
   952	      ToolModel(
   953	        id: 'discord',
   954	        name: 'Discord',
   955	        description:
   956	            'Send messages to configured channels using your bot token.',
   957	        logoEmoji: '🎮',
   958	        category: ToolCategory.messaging,
   959	        authStatus: statusByProvider['discord'] ?? AuthStatus.disconnected,
   960	        isEnabled: previousEnabled['discord'] ?? true,
   961	        capabilities: capsForPrefix('discord.'),
   962	        usageCount: 0,
   963	        lastUsed: null,
   964	        categoryColor: const Color(0xFF8B5CF6),
   965	        metadata: _cardMetadataByProvider['discord'] ?? const {},
   966	      ),
   967	      ToolModel(
   968	        id: 'filesystem',
   969	        name: 'Filesystem',
   970	        description: 'Read/write files in backend sandbox root.',
   971	        logoEmoji: '🗄️',
   972	        category: ToolCategory.files,
   973	        authStatus: statusByProvider['filesystem'] ?? AuthStatus.connected,
   974	        isEnabled: previousEnabled['filesystem'] ?? true,
   975	        capabilities: capsForPrefix('filesystem.'),
   976	        usageCount: 0,
   977	        lastUsed: null,
   978	        categoryColor: const Color(0xFF22C55E),
   979	        metadata: _cardMetadataByProvider['filesystem'] ?? const {},
   980	      ),
   981	    ];
   982	  }
   983	
   984	  Future<void> setFilesystemRoot(String rootPath) async {
   985	    final backend = _backend;
   986	    if (backend == null) return;
   987	    await backend.setFilesystemRoot(rootPath);
   988	    await refreshFromBackend();
   989	  }
   990	
   991	  AuthStatus _mapAuthStatus(String status) {
   992	    return switch (status) {
   993	      'connected' => AuthStatus.connected,
   994	      'pending' => AuthStatus.pending,
   995	      'auth_required' || 'disconnected' => AuthStatus.disconnected,
   996	      _ => AuthStatus.error,
   997	    };
   998	  }
   999	
  1000	  List<ToolModel> _fallbackTools() {
  1001	    return [
  1002	      ToolModel(
  1003	        id: 'gmail',
  1004	        name: 'Gmail',
  1005	        description: 'Connect Google OAuth to enable Gmail tools.',
  1006	        logoEmoji: '✉️',
  1007	        category: ToolCategory.cloud,
  1008	        authStatus: AuthStatus.disconnected,
  1009	        isEnabled: true,
  1010	        capabilities: const [],
  1011	        usageCount: 0,
  1012	        categoryColor: const Color(0xFF42A5F5),
  1013	      ),
  1014	      ToolModel(
  1015	        id: 'google-drive',
  1016	        name: 'Google Drive',
  1017	        description: 'Connect Google OAuth to enable Drive tools.',
  1018	        logoEmoji: '🗂️',
  1019	        category: ToolCategory.cloud,
  1020	        authStatus: AuthStatus.disconnected,
  1021	        isEnabled: true,
  1022	        capabilities: const [],
  1023	        usageCount: 0,
  1024	        categoryColor: const Color(0xFF42A5F5),
  1025	      ),
  1026	      ToolModel(
  1027	        id: 'discord',
  1028	        name: 'Discord',
  1029	        description: 'Use bot token and channel id to send messages.',
  1030	        logoEmoji: '🎮',
  1031	        category: ToolCategory.messaging,
  1032	        authStatus: AuthStatus.disconnected,
  1033	        isEnabled: true,
  1034	        capabilities: const [],
  1035	        usageCount: 0,
  1036	        categoryColor: const Color(0xFF8B5CF6),
  1037	      ),
  1038	      ToolModel(
  1039	        id: 'filesystem',
  1040	        name: 'Filesystem',
  1041	        description: 'Backend local sandbox filesystem tools.',
  1042	        logoEmoji: '🗄️',
  1043	        category: ToolCategory.files,
  1044	        authStatus: AuthStatus.connected,
  1045	        isEnabled: true,
  1046	        capabilities: const [],
  1047	        usageCount: 0,
  1048	        categoryColor: const Color(0xFF22C55E),
  1049	      ),
  1050	    ];
  1051	  }
  1052	}
  1053	
  1054	// ── Workflows Provider ────────────────────────────────────────────────────────
  1055	class WorkflowsProvider extends ChangeNotifier {
  1056	  List<WorkflowModel> _workflows = MockData.workflows;
  1057	  List<WorkflowModel> get workflows => _workflows;
  1058	
  1059	  String? _openWorkflowId;
  1060	  String? get openWorkflowId => _openWorkflowId;
  1061	
  1062	  WorkflowModel? get openWorkflow =>
  1063	      _workflows.where((w) => w.id == _openWorkflowId).firstOrNull;
  1064	
  1065	  bool _showCreateDialog = false;
  1066	  bool get showCreateDialog => _showCreateDialog;
  1067	
  1068	  // Node being dragged on canvas
  1069	  String? _draggingNodeId;
  1070	  Offset _dragOffset = Offset.zero;
  1071	
  1072	  void setOpenWorkflow(String id) {
  1073	    _openWorkflowId = id;
  1074	    notifyListeners();
  1075	  }
  1076	
  1077	  void closeWorkflow() {
  1078	    _openWorkflowId = null;
  1079	    notifyListeners();
  1080	  }
  1081	
  1082	  void toggleCreateDialog() {
  1083	    _showCreateDialog = !_showCreateDialog;
  1084	    notifyListeners();
  1085	  }
  1086	
  1087	  void runWorkflow(String id) {
  1088	    final idx = _workflows.indexWhere((w) => w.id == id);
  1089	    if (idx == -1) return;
  1090	    _workflows[idx].status = WorkflowStatus.running;
  1091	    notifyListeners();
  1092	    Future.delayed(const Duration(seconds: 3), () {
  1093	      _workflows[idx].status = WorkflowStatus.success;
  1094	      _workflows[idx].lastRun = DateTime.now();
  1095	      notifyListeners();
  1096	    });
  1097	  }
  1098	
  1099	  void updateNodePosition(String workflowId, String nodeId, Offset pos) {
  1100	    final wfIdx = _workflows.indexWhere((w) => w.id == workflowId);
  1101	    if (wfIdx == -1) return;
  1102	    final nodeIdx = _workflows[wfIdx].nodes.indexWhere((n) => n.id == nodeId);
  1103	    if (nodeIdx == -1) return;
  1104	    _workflows[wfIdx].nodes[nodeIdx].position = pos;
  1105	    notifyListeners();
  1106	  }
  1107	
  1108	  void createWorkflow(String name, String chatSessionId) {
  1109	    final id = 'wf-new-${DateTime.now().millisecondsSinceEpoch}';
  1110	    _workflows.insert(
  1111	        0,
  1112	        WorkflowModel(
  1113	          id: id,
  1114	          name: name,
  1115	          description: 'New workflow',
  1116	          chatSessionId: chatSessionId,
  1117	          status: WorkflowStatus.draft,
  1118	          createdAt: DateTime.now(),
  1119	          runCount: 0,
  1120	          nodes: [
  1121	            WorkflowNode(
  1122	              id: 'start-trigger',
  1123	              label: 'Start',
  1124	              type: NodeType.trigger,
  1125	              toolId: 'manual',
  1126	              toolName: 'Manual',
  1127	              icon: '▶️',
  1128	              position: const Offset(80, 160),
  1129	              config: {},
  1130	              color: const Color(0xFF7B61FF),
  1131	              ports: const [
  1132	                WorkflowPort(id: 'out-1', label: 'start', isInput: false)
  1133	              ],
  1134	            ),
  1135	          ],
  1136	          edges: const [],
  1137	          isActive: false,
  1138	        ));
  1139	    _openWorkflowId = id;
  1140	    _showCreateDialog = false;
  1141	    notifyListeners();
  1142	  }
  1143	
  1144	  List<WorkflowModel> workflowsForSession(String sessionId) =>
  1145	      _workflows.where((w) => w.chatSessionId == sessionId).toList();
  1146	
  1147	  int get activeWorkflowCount =>
  1148	      _workflows.where((w) => w.status == WorkflowStatus.running).length;
  1149	  int get totalWorkflowCount => _workflows.length;
  1150	}
  1151	
  1152	// ── Model Provider ────────────────────────────────────────────────────────────
  1153	class ModelProvider extends ChangeNotifier {
  1154	  final BackendPreferences _prefs = BackendPreferences();
  1155	  bool _didLoad = false;
  1156	
  1157	  String _modelName = 'gpt-4.1-mini';
  1158	  String get modelName => _modelName;
  1159	
  1160	  String _systemPrompt =
  1161	      'You are Weaver, an intelligent multi-agent assistant. You have access to a rich set of tools and can help with automation, file management, communication, and research. Be concise, precise, and proactive.';
  1162	  String get systemPrompt => _systemPrompt;
  1163	
  1164	  double _temperature = 0.7;
  1165	  double get temperature => _temperature;
  1166	
  1167	  int _maxTokens = 4096;
  1168	  int get maxTokens => _maxTokens;
  1169	
  1170	  Future<void> initialize() async {
  1171	    if (_didLoad) return;
  1172	    _didLoad = true;
  1173	    _modelName = await _prefs.loadModelName();
  1174	    _systemPrompt = await _prefs.loadSystemPrompt();
  1175	    _temperature = await _prefs.loadTemperature();
  1176	    _maxTokens = await _prefs.loadMaxTokens();
  1177	    notifyListeners();
  1178	  }
  1179	
  1180	  Future<void> setModelName(String value) async {
  1181	    final trimmed = value.trim();
  1182	    if (trimmed.isEmpty) return;
  1183	    _modelName = trimmed;
  1184	    await _prefs.saveModelName(_modelName);
  1185	    notifyListeners();
  1186	  }
  1187	
  1188	  Future<void> setSystemPrompt(String p) async {
  1189	    _systemPrompt = p;
  1190	    await _prefs.saveSystemPrompt(_systemPrompt);
  1191	    notifyListeners();
  1192	  }
  1193	
  1194	  Future<void> setTemperature(double t) async {
  1195	    _temperature = t;
  1196	    await _prefs.saveTemperature(_temperature);
  1197	    notifyListeners();
  1198	  }
  1199	
  1200	  Future<void> setMaxTokens(int t) async {
  1201	    _maxTokens = t;
  1202	    await _prefs.saveMaxTokens(_maxTokens);
  1203	    notifyListeners();
  1204	  }
  1205	}
```

## frontend/lib/screens/settings_screen.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:provider/provider.dart';
     3	
     4	import '../models/models.dart';
     5	import '../providers/providers.dart';
     6	import '../theme/colors.dart';
     7	
     8	class SettingsScreen extends StatefulWidget {
     9	  const SettingsScreen({super.key});
    10	
    11	  @override
    12	  State<SettingsScreen> createState() => _SettingsScreenState();
    13	}
    14	
    15	class _SettingsScreenState extends State<SettingsScreen> {
    16	  final TextEditingController _baseUrlController = TextEditingController();
    17	  final TextEditingController _discordChannelController =
    18	      TextEditingController();
    19	  final TextEditingController _llmApiKeyController = TextEditingController();
    20	  final TextEditingController _llmBaseUrlController = TextEditingController();
    21	  bool _obscureApiKey = true;
    22	
    23	  @override
    24	  void didChangeDependencies() {
    25	    super.didChangeDependencies();
    26	    final backend = context.read<BackendProvider>();
    27	    _baseUrlController.text = backend.baseUrl;
    28	    _discordChannelController.text = backend.discordChannelId;
    29	    _llmApiKeyController.text = backend.llmApiKey;
    30	    _llmBaseUrlController.text = backend.llmBaseUrl;
    31	  }
    32	
    33	  @override
    34	  void dispose() {
    35	    _baseUrlController.dispose();
    36	    _discordChannelController.dispose();
    37	    _llmApiKeyController.dispose();
    38	    _llmBaseUrlController.dispose();
    39	    super.dispose();
    40	  }
    41	
    42	  @override
    43	  Widget build(BuildContext context) {
    44	    return Consumer2<BackendProvider, ToolsProvider>(
    45	      builder: (context, backend, tools, _) {
    46	        return SingleChildScrollView(
    47	          padding: const EdgeInsets.all(24),
    48	          child: Column(
    49	            crossAxisAlignment: CrossAxisAlignment.start,
    50	            children: [
    51	              const Text(
    52	                'Settings',
    53	                style: TextStyle(
    54	                    fontSize: 22,
    55	                    fontWeight: FontWeight.w700,
    56	                    color: WeaverColors.textPrimary),
    57	              ),
    58	              const SizedBox(height: 6),
    59	              const Text(
    60	                'Configure backend, auth flows, and tool defaults.',
    61	                style: TextStyle(fontSize: 13, color: WeaverColors.textMuted),
    62	              ),
    63	              const SizedBox(height: 28),
    64	              _Section(
    65	                title: 'Backend Runtime',
    66	                icon: Icons.dns_rounded,
    67	                child: Column(
    68	                  crossAxisAlignment: CrossAxisAlignment.start,
    69	                  children: [
    70	                    _LabeledField(
    71	                      label: 'API Base URL',
    72	                      controller: _baseUrlController,
    73	                      hint: 'http://127.0.0.1:8000',
    74	                    ),
    75	                    const SizedBox(height: 8),
    76	                    Row(
    77	                      children: [
    78	                        ElevatedButton.icon(
    79	                          onPressed: () async {
    80	                            await backend.setBaseUrl(_baseUrlController.text);
    81	                            await tools.refreshFromBackend();
    82	                          },
    83	                          icon: const Icon(Icons.save_rounded, size: 14),
    84	                          label: const Text('Save URL'),
    85	                        ),
    86	                        const SizedBox(width: 8),
    87	                        OutlinedButton.icon(
    88	                          onPressed: () async {
    89	                            await backend.ensureBackendRunning();
    90	                            await tools.refreshFromBackend();
    91	                          },
    92	                          icon: const Icon(Icons.play_arrow_rounded, size: 14),
    93	                          label: const Text('Start Backend'),
    94	                        ),
    95	                        const Spacer(),
    96	                        _ConnectionPill(
    97	                          connected: backend.isConnected,
    98	                          starting: backend.isStarting,
    99	                        ),
   100	                      ],
   101	                    ),
   102	                    const SizedBox(height: 10),
   103	                    Row(
   104	                      children: [
   105	                        const Text('Auto-start backend with app',
   106	                            style: TextStyle(
   107	                                color: WeaverColors.textSecondary,
   108	                                fontSize: 13)),
   109	                        const Spacer(),
   110	                        Switch(
   111	                          value: backend.autoStartBackend,
   112	                          onChanged: (v) => backend.setAutoStartBackend(v),
   113	                        ),
   114	                      ],
   115	                    ),
   116	                    if (backend.lastError != null &&
   117	                        backend.lastError!.isNotEmpty)
   118	                      Padding(
   119	                        padding: const EdgeInsets.only(top: 8),
   120	                        child: Text(
   121	                          backend.lastError!,
   122	                          style: const TextStyle(
   123	                              fontSize: 12, color: WeaverColors.error),
   124	                        ),
   125	                      ),
   126	                  ],
   127	                ),
   128	              ),
   129	              const SizedBox(height: 20),
   130	              _Section(
   131	                title: 'LLM Credentials',
   132	                icon: Icons.key_rounded,
   133	                child: Column(
   134	                  crossAxisAlignment: CrossAxisAlignment.start,
   135	                  children: [
   136	                    _LabeledField(
   137	                      label: 'LLM Base URL',
   138	                      controller: _llmBaseUrlController,
   139	                      hint: 'https://api.openai.com/v1',
   140	                    ),
   141	                    const SizedBox(height: 8),
   142	                    _LabeledField(
   143	                      label: 'LLM API Key',
   144	                      controller: _llmApiKeyController,
   145	                      hint: 'sk-...',
   146	                      obscureText: _obscureApiKey,
   147	                      trailing: IconButton(
   148	                        icon: Icon(_obscureApiKey
   149	                            ? Icons.visibility_rounded
   150	                            : Icons.visibility_off_rounded),
   151	                        onPressed: () =>
   152	                            setState(() => _obscureApiKey = !_obscureApiKey),
   153	                      ),
   154	                    ),
   155	                    const SizedBox(height: 8),
   156	                    ElevatedButton.icon(
   157	                      onPressed: () async {
   158	                        await backend.setLlmBaseUrl(_llmBaseUrlController.text);
   159	                        await backend.setLlmApiKey(_llmApiKeyController.text);
   160	                      },
   161	                      icon: const Icon(Icons.save_rounded, size: 14),
   162	                      label: const Text('Save LLM Credentials'),
   163	                    ),
   164	                    const SizedBox(height: 10),
   165	                    const Text(
   166	                      'Model name is configured from the right sidebar model panel.',
   167	                      style: TextStyle(
   168	                          fontSize: 12, color: WeaverColors.textMuted),
   169	                    ),
   170	                  ],
   171	                ),
   172	              ),
   173	              const SizedBox(height: 20),
   174	              _Section(
   175	                title: 'Auth & Tools',
   176	                icon: Icons.verified_user_rounded,
   177	                child: Column(
   178	                  children: [
   179	                    _AuthRow(
   180	                      title: 'Google OAuth (Gmail + Drive)',
   181	                      status: _googleStatus(tools),
   182	                      onConnect: () => tools.connectTool('gmail'),
   183	                    ),
   184	                    const SizedBox(height: 10),
   185	                    _AuthRow(
   186	                      title: 'Discord Bot / OAuth',
   187	                      status: _findTool(tools, 'discord')?.authStatus,
   188	                      onConnect: () => tools.connectTool('discord'),
   189	                    ),
   190	                    const SizedBox(height: 10),
   191	                    _UserInfoTile(
   192	                      title: 'Google account',
   193	                      info: backend.googleUserInfo,
   194	                      primary: (backend.googleUserInfo['profile']
   195	                                  as Map<String, dynamic>? ??
   196	                              const {})['email']
   197	                          ?.toString(),
   198	                      secondary: (backend.googleUserInfo['profile']
   199	                                  as Map<String, dynamic>? ??
   200	                              const {})['name']
   201	                          ?.toString(),
   202	                    ),
   203	                    const SizedBox(height: 8),
   204	                    _UserInfoTile(
   205	                      title: 'Discord account',
   206	                      info: backend.discordUserInfo,
   207	                      primary: (backend.discordUserInfo['profile']
   208	                                  as Map<String, dynamic>? ??
   209	                              const {})['display_name']
   210	                          ?.toString(),
   211	                      secondary: (backend.discordUserInfo['profile']
   212	                                  as Map<String, dynamic>? ??
   213	                              const {})['email']
   214	                          ?.toString(),
   215	                    ),
   216	                    const SizedBox(height: 8),
   217	                    _BotInfoTile(status: backend.discordBotStatus),
   218	                    const SizedBox(height: 10),
   219	                    Row(
   220	                      children: [
   221	                        OutlinedButton.icon(
   222	                          onPressed: () async {
   223	                            await tools.refreshFromBackend();
   224	                            await backend.refreshUserInfo();
   225	                            await backend.refreshDiscordBotStatus();
   226	                          },
   227	                          icon: const Icon(Icons.refresh_rounded, size: 14),
   228	                          label: const Text('Refresh Tool Status'),
   229	                        ),
   230	                        const SizedBox(width: 8),
   231	                        Text(
   232	                          tools.lastError ?? '',
   233	                          style: const TextStyle(
   234	                              fontSize: 12, color: WeaverColors.error),
   235	                        ),
   236	                      ],
   237	                    ),
   238	                  ],
   239	                ),
   240	              ),
   241	              const SizedBox(height: 20),
   242	              _Section(
   243	                title: 'Agent Defaults',
   244	                icon: Icons.smart_toy_rounded,
   245	                child: Column(
   246	                  crossAxisAlignment: CrossAxisAlignment.start,
   247	                  children: [
   248	                    _LabeledField(
   249	                      label: 'Default Discord Channel ID',
   250	                      controller: _discordChannelController,
   251	                      hint: '1494502217703620731',
   252	                    ),
   253	                    const SizedBox(height: 8),
   254	                    ElevatedButton.icon(
   255	                      onPressed: () => backend
   256	                          .setDiscordChannelId(_discordChannelController.text),
   257	                      icon: const Icon(Icons.save_rounded, size: 14),
   258	                      label: const Text('Save Channel ID'),
   259	                    ),
   260	                    const SizedBox(height: 12),
   261	                    const Text(
   262	                      'This channel is used when prompt includes Discord send intent.',
   263	                      style: TextStyle(
   264	                          fontSize: 12, color: WeaverColors.textMuted),
   265	                    ),
   266	                  ],
   267	                ),
   268	              ),
   269	            ],
   270	          ),
   271	        );
   272	      },
   273	    );
   274	  }
   275	
   276	  ToolModel? _findTool(ToolsProvider tools, String id) {
   277	    for (final t in tools.tools) {
   278	      if (t.id == id) return t;
   279	    }
   280	    return null;
   281	  }
   282	
   283	  AuthStatus _googleStatus(ToolsProvider tools) {
   284	    final gmail = _findTool(tools, 'gmail')?.authStatus;
   285	    final drive = _findTool(tools, 'google-drive')?.authStatus;
   286	    if (gmail == AuthStatus.connected && drive == AuthStatus.connected) {
   287	      return AuthStatus.connected;
   288	    }
   289	    if (gmail == AuthStatus.pending || drive == AuthStatus.pending) {
   290	      return AuthStatus.pending;
   291	    }
   292	    if (gmail == AuthStatus.error || drive == AuthStatus.error) {
   293	      return AuthStatus.error;
   294	    }
   295	    return AuthStatus.disconnected;
   296	  }
   297	}
   298	
   299	class _Section extends StatelessWidget {
   300	  final String title;
   301	  final IconData icon;
   302	  final Widget child;
   303	
   304	  const _Section(
   305	      {required this.title, required this.icon, required this.child});
   306	
   307	  @override
   308	  Widget build(BuildContext context) {
   309	    return Container(
   310	      padding: const EdgeInsets.all(20),
   311	      decoration: BoxDecoration(
   312	        color: WeaverColors.card,
   313	        borderRadius: BorderRadius.circular(14),
   314	        border: Border.all(color: WeaverColors.cardBorder),
   315	      ),
   316	      child: Column(
   317	        crossAxisAlignment: CrossAxisAlignment.start,
   318	        children: [
   319	          Row(
   320	            children: [
   321	              Icon(icon, size: 18, color: WeaverColors.accent),
   322	              const SizedBox(width: 8),
   323	              Text(title,
   324	                  style: const TextStyle(
   325	                      fontSize: 14,
   326	                      fontWeight: FontWeight.w600,
   327	                      color: WeaverColors.textPrimary)),
   328	            ],
   329	          ),
   330	          const SizedBox(height: 16),
   331	          child,
   332	        ],
   333	      ),
   334	    );
   335	  }
   336	}
   337	
   338	class _LabeledField extends StatelessWidget {
   339	  final String label;
   340	  final TextEditingController controller;
   341	  final String hint;
   342	  final bool obscureText;
   343	  final Widget? trailing;
   344	
   345	  const _LabeledField({
   346	    required this.label,
   347	    required this.controller,
   348	    required this.hint,
   349	    this.obscureText = false,
   350	    this.trailing,
   351	  });
   352	
   353	  @override
   354	  Widget build(BuildContext context) {
   355	    return Column(
   356	      crossAxisAlignment: CrossAxisAlignment.start,
   357	      children: [
   358	        Text(label,
   359	            style: const TextStyle(
   360	                fontSize: 12,
   361	                color: WeaverColors.textMuted,
   362	                fontWeight: FontWeight.w500)),
   363	        const SizedBox(height: 5),
   364	        TextField(
   365	          controller: controller,
   366	          obscureText: obscureText,
   367	          style: const TextStyle(fontSize: 12, color: WeaverColors.textPrimary),
   368	          decoration: InputDecoration(
   369	              hintText: hint, isDense: true, suffixIcon: trailing),
   370	        ),
   371	      ],
   372	    );
   373	  }
   374	}
   375	
   376	class _UserInfoTile extends StatelessWidget {
   377	  final String title;
   378	  final Map<String, dynamic> info;
   379	  final String? primary;
   380	  final String? secondary;
   381	
   382	  const _UserInfoTile({
   383	    required this.title,
   384	    required this.info,
   385	    required this.primary,
   386	    required this.secondary,
   387	  });
   388	
   389	  @override
   390	  Widget build(BuildContext context) {
   391	    final authenticated = info['authenticated'] == true;
   392	    return Container(
   393	      width: double.infinity,
   394	      padding: const EdgeInsets.all(10),
   395	      decoration: BoxDecoration(
   396	        color: WeaverColors.surface,
   397	        borderRadius: BorderRadius.circular(8),
   398	        border: Border.all(color: WeaverColors.cardBorder),
   399	      ),
   400	      child: Column(
   401	        crossAxisAlignment: CrossAxisAlignment.start,
   402	        children: [
   403	          Text(title,
   404	              style: const TextStyle(
   405	                  fontSize: 12,
   406	                  color: WeaverColors.textPrimary,
   407	                  fontWeight: FontWeight.w600)),
   408	          const SizedBox(height: 2),
   409	          Text(
   410	            authenticated
   411	                ? (primary == null || primary!.isEmpty
   412	                    ? 'Authenticated'
   413	                    : primary!)
   414	                : 'Not authenticated',
   415	            style: TextStyle(
   416	                fontSize: 12,
   417	                color: authenticated
   418	                    ? WeaverColors.success
   419	                    : WeaverColors.textMuted),
   420	          ),
   421	          if (secondary != null && secondary!.isNotEmpty)
   422	            Text(secondary!,
   423	                style: const TextStyle(
   424	                    fontSize: 11, color: WeaverColors.textMuted)),
   425	        ],
   426	      ),
   427	    );
   428	  }
   429	}
   430	
   431	class _BotInfoTile extends StatelessWidget {
   432	  final Map<String, dynamic> status;
   433	
   434	  const _BotInfoTile({required this.status});
   435	
   436	  @override
   437	  Widget build(BuildContext context) {
   438	    final configured = status['configured'] == true;
   439	    final username = status['username']?.toString() ?? '';
   440	    final error = status['error']?.toString() ?? '';
   441	    return Container(
   442	      width: double.infinity,
   443	      padding: const EdgeInsets.all(10),
   444	      decoration: BoxDecoration(
   445	        color: WeaverColors.surface,
   446	        borderRadius: BorderRadius.circular(8),
   447	        border: Border.all(color: WeaverColors.cardBorder),
   448	      ),
   449	      child: Column(
   450	        crossAxisAlignment: CrossAxisAlignment.start,
   451	        children: [
   452	          const Text('Discord bot token status',
   453	              style: TextStyle(
   454	                  fontSize: 12,
   455	                  color: WeaverColors.textPrimary,
   456	                  fontWeight: FontWeight.w600)),
   457	          const SizedBox(height: 2),
   458	          Text(
   459	            configured
   460	                ? 'Configured${username.isNotEmpty ? ': $username' : ''}'
   461	                : 'Not configured',
   462	            style: TextStyle(
   463	                fontSize: 12,
   464	                color:
   465	                    configured ? WeaverColors.success : WeaverColors.warning),
   466	          ),
   467	          if (error.isNotEmpty)
   468	            Text(error,
   469	                style:
   470	                    const TextStyle(fontSize: 11, color: WeaverColors.error)),
   471	        ],
   472	      ),
   473	    );
   474	  }
   475	}
   476	
   477	class _ConnectionPill extends StatelessWidget {
   478	  final bool connected;
   479	  final bool starting;
   480	
   481	  const _ConnectionPill({required this.connected, required this.starting});
   482	
   483	  @override
   484	  Widget build(BuildContext context) {
   485	    if (starting) {
   486	      return Container(
   487	        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
   488	        decoration: BoxDecoration(
   489	          color: WeaverColors.warningDim,
   490	          borderRadius: BorderRadius.circular(20),
   491	          border: Border.all(color: WeaverColors.warning.withOpacity(0.4)),
   492	        ),
   493	        child: const Text('Starting...',
   494	            style: TextStyle(
   495	                fontSize: 11,
   496	                color: WeaverColors.warning,
   497	                fontWeight: FontWeight.w600)),
   498	      );
   499	    }
   500	
   501	    return Container(
   502	      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
   503	      decoration: BoxDecoration(
   504	        color: connected ? WeaverColors.successDim : WeaverColors.errorDim,
   505	        borderRadius: BorderRadius.circular(20),
   506	        border: Border.all(
   507	            color: (connected ? WeaverColors.success : WeaverColors.error)
   508	                .withOpacity(0.4)),
   509	      ),
   510	      child: Text(
   511	        connected ? 'Connected' : 'Disconnected',
   512	        style: TextStyle(
   513	            fontSize: 11,
   514	            color: connected ? WeaverColors.success : WeaverColors.error,
   515	            fontWeight: FontWeight.w600),
   516	      ),
   517	    );
   518	  }
   519	}
   520	
   521	class _AuthRow extends StatelessWidget {
   522	  final String title;
   523	  final AuthStatus? status;
   524	  final Future<void> Function() onConnect;
   525	
   526	  const _AuthRow(
   527	      {required this.title, required this.status, required this.onConnect});
   528	
   529	  @override
   530	  Widget build(BuildContext context) {
   531	    final effectiveStatus = status ?? AuthStatus.disconnected;
   532	    final (label, color) = switch (effectiveStatus) {
   533	      AuthStatus.connected => ('Connected', WeaverColors.success),
   534	      AuthStatus.pending => ('Pending', WeaverColors.warning),
   535	      AuthStatus.error => ('Error', WeaverColors.error),
   536	      AuthStatus.disconnected => ('Disconnected', WeaverColors.textMuted),
   537	    };
   538	
   539	    return Row(
   540	      children: [
   541	        Expanded(
   542	          child: Column(
   543	            crossAxisAlignment: CrossAxisAlignment.start,
   544	            children: [
   545	              Text(title,
   546	                  style: const TextStyle(
   547	                      fontSize: 13,
   548	                      color: WeaverColors.textPrimary,
   549	                      fontWeight: FontWeight.w500)),
   550	              const SizedBox(height: 2),
   551	              Text(label, style: TextStyle(fontSize: 11, color: color)),
   552	            ],
   553	          ),
   554	        ),
   555	        if (effectiveStatus == AuthStatus.connected)
   556	          OutlinedButton(
   557	            onPressed: onConnect,
   558	            child: const Text('Reconnect'),
   559	          )
   560	        else
   561	          ElevatedButton(
   562	            onPressed: onConnect,
   563	            child: const Text('Connect'),
   564	          ),
   565	      ],
   566	    );
   567	  }
   568	}
```

## frontend/lib/screens/workflows_screen.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:flutter_animate/flutter_animate.dart';
     3	import 'package:provider/provider.dart';
     4	import '../../providers/providers.dart';
     5	import '../../theme/colors.dart';
     6	import '../../models/models.dart';
     7	import '../widgets/common/common_widgets.dart';
     8	import '../widgets/workflow/workflow_canvas.dart';
     9	
    10	class WorkflowsScreen extends StatelessWidget {
    11	  const WorkflowsScreen({super.key});
    12	
    13	  @override
    14	  Widget build(BuildContext context) {
    15	    return Consumer<WorkflowsProvider>(
    16	      builder: (context, wfProv, _) {
    17	        // If a workflow is open, show the canvas
    18	        if (wfProv.openWorkflow != null) {
    19	          return WorkflowCanvas(workflow: wfProv.openWorkflow!);
    20	        }
    21	        // Otherwise show the workflows dashboard
    22	        return _WorkflowsDashboard();
    23	      },
    24	    );
    25	  }
    26	}
    27	
    28	class _WorkflowsDashboard extends StatelessWidget {
    29	  @override
    30	  Widget build(BuildContext context) {
    31	    return Consumer2<WorkflowsProvider, ChatProvider>(
    32	      builder: (context, wfProv, chatProv, _) {
    33	        // Group workflows by chat session
    34	        final Map<String, List<WorkflowModel>> bySession = {};
    35	        for (final wf in wfProv.workflows) {
    36	          bySession.putIfAbsent(wf.chatSessionId, () => []).add(wf);
    37	        }
    38	
    39	        return Column(
    40	          crossAxisAlignment: CrossAxisAlignment.start,
    41	          children: [
    42	            _WorkflowsHeader(wfProv: wfProv, chatProv: chatProv),
    43	            Expanded(
    44	              child: wfProv.workflows.isEmpty
    45	                  ? const _EmptyWorkflowsState()
    46	                  : ListView(
    47	                      padding: const EdgeInsets.all(24),
    48	                      children: bySession.entries.map((entry) {
    49	                        final session = chatProv.sessions.where((s) => s.id == entry.key).firstOrNull;
    50	                        return _WorkflowGroup(
    51	                          sessionTitle: session?.title ?? 'Unknown Chat',
    52	                          workflows: entry.value,
    53	                          wfProv: wfProv,
    54	                        ).animate().fadeIn(duration: 300.ms);
    55	                      }).toList(),
    56	                    ),
    57	            ),
    58	          ],
    59	        );
    60	      },
    61	    );
    62	  }
    63	}
    64	
    65	class _WorkflowsHeader extends StatelessWidget {
    66	  final WorkflowsProvider wfProv;
    67	  final ChatProvider chatProv;
    68	
    69	  const _WorkflowsHeader({required this.wfProv, required this.chatProv});
    70	
    71	  @override
    72	  Widget build(BuildContext context) {
    73	    return Container(
    74	      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
    75	      decoration: const BoxDecoration(
    76	        border: Border(bottom: BorderSide(color: WeaverColors.cardBorder)),
    77	      ),
    78	      child: Row(
    79	        children: [
    80	          Column(
    81	            crossAxisAlignment: CrossAxisAlignment.start,
    82	            children: [
    83	              const Text('Workflows', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: WeaverColors.textPrimary)),
    84	              Text('${wfProv.totalWorkflowCount} total · ${wfProv.activeWorkflowCount} running', style: const TextStyle(fontSize: 13, color: WeaverColors.textMuted)),
    85	            ],
    86	          ),
    87	          const Spacer(),
    88	          // Status filter chips
    89	          _FilterChip(label: 'All', count: wfProv.workflows.length),
    90	          const SizedBox(width: 6),
    91	          _FilterChip(label: 'Active', count: wfProv.workflows.where((w) => w.isActive).length, color: WeaverColors.success),
    92	          const SizedBox(width: 6),
    93	          _FilterChip(label: 'Draft', count: wfProv.workflows.where((w) => w.status == WorkflowStatus.draft).length, color: WeaverColors.warning),
    94	          const SizedBox(width: 16),
    95	          ElevatedButton.icon(
    96	            onPressed: () {
    97	              wfProv.toggleCreateDialog();
    98	              // Show create dialog as overlay
    99	              showDialog(
   100	                context: context,
   101	                builder: (ctx) => _CreateWorkflowOverlay(chatProv: chatProv, wfProv: wfProv),
   102	              );
   103	            },
   104	            icon: const Icon(Icons.add_rounded, size: 15),
   105	            label: const Text('New Workflow'),
   106	          ),
   107	        ],
   108	      ),
   109	    );
   110	  }
   111	}
   112	
   113	class _FilterChip extends StatefulWidget {
   114	  final String label;
   115	  final int count;
   116	  final Color? color;
   117	  const _FilterChip({required this.label, required this.count, this.color});
   118	
   119	  @override
   120	  State<_FilterChip> createState() => _FilterChipState();
   121	}
   122	
   123	class _FilterChipState extends State<_FilterChip> {
   124	  bool _hovered = false;
   125	
   126	  @override
   127	  Widget build(BuildContext context) {
   128	    final c = widget.color ?? WeaverColors.textMuted;
   129	    return MouseRegion(
   130	      onEnter: (_) => setState(() => _hovered = true),
   131	      onExit: (_) => setState(() => _hovered = false),
   132	      cursor: SystemMouseCursors.click,
   133	      child: AnimatedContainer(
   134	        duration: const Duration(milliseconds: 120),
   135	        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
   136	        decoration: BoxDecoration(
   137	          color: _hovered ? c.withOpacity(0.12) : c.withOpacity(0.06),
   138	          borderRadius: BorderRadius.circular(20),
   139	          border: Border.all(color: c.withOpacity(_hovered ? 0.4 : 0.2)),
   140	        ),
   141	        child: Row(
   142	          mainAxisSize: MainAxisSize.min,
   143	          children: [
   144	            Text(widget.label, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w500)),
   145	            const SizedBox(width: 5),
   146	            Container(
   147	              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
   148	              decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
   149	              child: Text('${widget.count}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c)),
   150	            ),
   151	          ],
   152	        ),
   153	      ),
   154	    );
   155	  }
   156	}
   157	
   158	class _WorkflowGroup extends StatelessWidget {
   159	  final String sessionTitle;
   160	  final List<WorkflowModel> workflows;
   161	  final WorkflowsProvider wfProv;
   162	
   163	  const _WorkflowGroup({required this.sessionTitle, required this.workflows, required this.wfProv});
   164	
   165	  @override
   166	  Widget build(BuildContext context) {
   167	    return Column(
   168	      crossAxisAlignment: CrossAxisAlignment.start,
   169	      children: [
   170	        Row(
   171	          children: [
   172	            const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: WeaverColors.textMuted),
   173	            const SizedBox(width: 6),
   174	            Text(sessionTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WeaverColors.textSecondary)),
   175	            const SizedBox(width: 8),
   176	            Container(
   177	              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
   178	              decoration: BoxDecoration(color: WeaverColors.surface, borderRadius: BorderRadius.circular(8)),
   179	              child: Text('${workflows.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: WeaverColors.textMuted)),
   180	            ),
   181	          ],
   182	        ),
   183	        const SizedBox(height: 10),
   184	        GridView.builder(
   185	          shrinkWrap: true,
   186	          physics: const NeverScrollableScrollPhysics(),
   187	          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
   188	            crossAxisCount: 3,
   189	            mainAxisExtent: 165,
   190	            mainAxisSpacing: 12,
   191	            crossAxisSpacing: 12,
   192	          ),
   193	          itemCount: workflows.length,
   194	          itemBuilder: (context, i) => _WorkflowCard(workflow: workflows[i], wfProv: wfProv),
   195	        ),
   196	        const SizedBox(height: 28),
   197	      ],
   198	    );
   199	  }
   200	}
   201	
   202	class _WorkflowCard extends StatefulWidget {
   203	  final WorkflowModel workflow;
   204	  final WorkflowsProvider wfProv;
   205	  const _WorkflowCard({required this.workflow, required this.wfProv});
   206	
   207	  @override
   208	  State<_WorkflowCard> createState() => _WorkflowCardState();
   209	}
   210	
   211	class _WorkflowCardState extends State<_WorkflowCard> {
   212	  bool _hovered = false;
   213	
   214	  @override
   215	  Widget build(BuildContext context) {
   216	    final wf = widget.workflow;
   217	    final statusColor = switch (wf.status) {
   218	      WorkflowStatus.running => WeaverColors.info,
   219	      WorkflowStatus.success => WeaverColors.success,
   220	      WorkflowStatus.error => WeaverColors.error,
   221	      WorkflowStatus.draft => WeaverColors.warning,
   222	      _ => WeaverColors.textMuted,
   223	    };
   224	
   225	    return MouseRegion(
   226	      onEnter: (_) => setState(() => _hovered = true),
   227	      onExit: (_) => setState(() => _hovered = false),
   228	      cursor: SystemMouseCursors.click,
   229	      child: GestureDetector(
   230	        onTap: () => widget.wfProv.setOpenWorkflow(wf.id),
   231	        child: AnimatedContainer(
   232	          duration: const Duration(milliseconds: 150),
   233	          padding: const EdgeInsets.all(16),
   234	          decoration: BoxDecoration(
   235	            color: _hovered ? WeaverColors.cardHover : WeaverColors.card,
   236	            borderRadius: BorderRadius.circular(14),
   237	            border: Border.all(
   238	              color: _hovered ? statusColor.withOpacity(0.5) : WeaverColors.cardBorder,
   239	              width: _hovered ? 1.5 : 1,
   240	            ),
   241	            boxShadow: _hovered ? [BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 12, spreadRadius: 1)] : null,
   242	          ),
   243	          child: Column(
   244	            crossAxisAlignment: CrossAxisAlignment.start,
   245	            children: [
   246	              // Header row
   247	              Row(
   248	                crossAxisAlignment: CrossAxisAlignment.start,
   249	                children: [
   250	                  // Mini node preview
   251	                  _MiniNodePreview(nodes: wf.nodes),
   252	                  const Spacer(),
   253	                  // Active toggle
   254	                  Transform.scale(
   255	                    scale: 0.7,
   256	                    child: Switch(
   257	                      value: wf.isActive,
   258	                      onChanged: (_) {},
   259	                    ),
   260	                  ),
   261	                ],
   262	              ),
   263	              const SizedBox(height: 10),
   264	              // Name
   265	              Text(wf.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
   266	              const SizedBox(height: 4),
   267	              Text(wf.description, style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
   268	              const Spacer(),
   269	              // Footer
   270	              Row(
   271	                children: [
   272	                  WorkflowStatusBadge(status: wf.status),
   273	                  const Spacer(),
   274	                  Text('${wf.runCount} runs', style: const TextStyle(fontSize: 10, color: WeaverColors.textMuted)),
   275	                ],
   276	              ),
   277	              if (wf.lastRun != null) ...[
   278	                const SizedBox(height: 4),
   279	                Text(
   280	                  'Last: ${_formatTime(wf.lastRun!)}',
   281	                  style: const TextStyle(fontSize: 10, color: WeaverColors.textDisabled),
   282	                ),
   283	              ],
   284	            ],
   285	          ),
   286	        ),
   287	      ),
   288	    );
   289	  }
   290	
   291	  String _formatTime(DateTime dt) {
   292	    final diff = DateTime.now().difference(dt);
   293	    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
   294	    if (diff.inHours < 24) return '${diff.inHours}h ago';
   295	    return '${diff.inDays}d ago';
   296	  }
   297	}
   298	
   299	class _MiniNodePreview extends StatelessWidget {
   300	  final List<WorkflowNode> nodes;
   301	  const _MiniNodePreview({required this.nodes});
   302	
   303	  @override
   304	  Widget build(BuildContext context) {
   305	    final displayNodes = nodes.take(4).toList();
   306	    return Row(
   307	      children: displayNodes.map((n) => Container(
   308	        margin: const EdgeInsets.only(right: 4),
   309	        width: 24, height: 24,
   310	        decoration: BoxDecoration(
   311	          color: n.color.withOpacity(0.15),
   312	          borderRadius: BorderRadius.circular(6),
   313	          border: Border.all(color: n.color.withOpacity(0.4)),
   314	        ),
   315	        child: Center(child: Text(n.icon, style: const TextStyle(fontSize: 11))),
   316	      )).toList(),
   317	    );
   318	  }
   319	}
   320	
   321	class _EmptyWorkflowsState extends StatelessWidget {
   322	  const _EmptyWorkflowsState();
   323	
   324	  @override
   325	  Widget build(BuildContext context) {
   326	    return Center(
   327	      child: Column(
   328	        mainAxisAlignment: MainAxisAlignment.center,
   329	        children: [
   330	          const Text('🕸️', style: TextStyle(fontSize: 56)),
   331	          const SizedBox(height: 20),
   332	          const Text('No workflows yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
   333	          const SizedBox(height: 8),
   334	          const Text('Create a workflow to automate tasks across your tools', style: TextStyle(fontSize: 14, color: WeaverColors.textMuted)),
   335	          const SizedBox(height: 24),
   336	          ElevatedButton.icon(
   337	            onPressed: () => Provider.of<WorkflowsProvider>(context, listen: false).toggleCreateDialog(),
   338	            icon: const Icon(Icons.add_rounded),
   339	            label: const Text('Create Workflow'),
   340	          ),
   341	        ],
   342	      ),
   343	    );
   344	  }
   345	}
   346	
   347	class _CreateWorkflowOverlay extends StatefulWidget {
   348	  final ChatProvider chatProv;
   349	  final WorkflowsProvider wfProv;
   350	  const _CreateWorkflowOverlay({required this.chatProv, required this.wfProv});
   351	
   352	  @override
   353	  State<_CreateWorkflowOverlay> createState() => _CreateWorkflowOverlayState();
   354	}
   355	
   356	class _CreateWorkflowOverlayState extends State<_CreateWorkflowOverlay> {
   357	  final _nameController = TextEditingController();
   358	  String? _selectedChatId;
   359	
   360	  @override
   361	  void initState() {
   362	    super.initState();
   363	    _selectedChatId = widget.chatProv.activeSessionId ?? widget.chatProv.sessions.firstOrNull?.id;
   364	  }
   365	
   366	  @override
   367	  void dispose() {
   368	    _nameController.dispose();
   369	    super.dispose();
   370	  }
   371	
   372	  @override
   373	  Widget build(BuildContext context) {
   374	    return Dialog(
   375	      backgroundColor: WeaverColors.card,
   376	      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: WeaverColors.cardBorder)),
   377	      child: SizedBox(
   378	        width: 460,
   379	        child: Padding(
   380	          padding: const EdgeInsets.all(24),
   381	          child: Column(
   382	            mainAxisSize: MainAxisSize.min,
   383	            crossAxisAlignment: CrossAxisAlignment.start,
   384	            children: [
   385	              const Text('New Workflow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: WeaverColors.textPrimary)),
   386	              const SizedBox(height: 4),
   387	              const Text('Workflows are linked to a chat session', style: TextStyle(fontSize: 12, color: WeaverColors.textMuted)),
   388	              const SizedBox(height: 20),
   389	              const Text('NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WeaverColors.textMuted, letterSpacing: 0.8)),
   390	              const SizedBox(height: 6),
   391	              TextField(
   392	                controller: _nameController,
   393	                autofocus: true,
   394	                style: const TextStyle(fontSize: 14),
   395	                decoration: const InputDecoration(hintText: 'e.g. Morning Email Digest'),
   396	              ),
   397	              const SizedBox(height: 16),
   398	              const Text('LINKED CHAT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: WeaverColors.textMuted, letterSpacing: 0.8)),
   399	              const SizedBox(height: 6),
   400	              DropdownButtonFormField<String>(
   401	                value: _selectedChatId,
   402	                dropdownColor: WeaverColors.card,
   403	                decoration: const InputDecoration(isDense: true),
   404	                style: const TextStyle(fontSize: 13, color: WeaverColors.textPrimary),
   405	                items: widget.chatProv.sessions.map((s) => DropdownMenuItem(
   406	                  value: s.id,
   407	                  child: Text(s.title, overflow: TextOverflow.ellipsis),
   408	                )).toList(),
   409	                onChanged: (v) => setState(() => _selectedChatId = v),
   410	              ),
   411	              const SizedBox(height: 24),
   412	              Row(
   413	                mainAxisAlignment: MainAxisAlignment.end,
   414	                children: [
   415	                  OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
   416	                  const SizedBox(width: 12),
   417	                  ElevatedButton(
   418	                    onPressed: () {
   419	                      if (_nameController.text.trim().isNotEmpty && _selectedChatId != null) {
   420	                        widget.wfProv.createWorkflow(_nameController.text.trim(), _selectedChatId!);
   421	                        Navigator.pop(context);
   422	                      }
   423	                    },
   424	                    child: const Text('Create & Open Canvas'),
   425	                  ),
   426	                ],
   427	              ),
   428	            ],
   429	          ),
   430	        ),
   431	      ),
   432	    );
   433	  }
   434	}
```

## frontend/lib/services/backend_api.dart

```dart
     1	import 'dart:async';
     2	import 'dart:convert';
     3	import 'dart:io';
     4	
     5	import 'package:flutter/foundation.dart';
     6	import 'package:http/http.dart' as http;
     7	import 'package:shared_preferences/shared_preferences.dart';
     8	import 'package:url_launcher/url_launcher.dart';
     9	
    10	class BackendApi {
    11	  BackendApi(this.baseUrl);
    12	
    13	  String baseUrl;
    14	
    15	  Uri _uri(String path) {
    16	    final normalized = baseUrl.endsWith('/')
    17	        ? baseUrl.substring(0, baseUrl.length - 1)
    18	        : baseUrl;
    19	    return Uri.parse('$normalized$path');
    20	  }
    21	
    22	  Future<Map<String, dynamic>> getJson(String path) async {
    23	    final res = await http.get(_uri(path));
    24	    if (res.statusCode >= 400) {
    25	      throw Exception('HTTP ${res.statusCode} from $path: ${res.body}');
    26	    }
    27	    return jsonDecode(res.body) as Map<String, dynamic>;
    28	  }
    29	
    30	  Future<List<dynamic>> getJsonList(String path) async {
    31	    final res = await http.get(_uri(path));
    32	    if (res.statusCode >= 400) {
    33	      throw Exception('HTTP ${res.statusCode} from $path: ${res.body}');
    34	    }
    35	    return jsonDecode(res.body) as List<dynamic>;
    36	  }
    37	
    38	  Future<Map<String, dynamic>> postJson(
    39	      String path, Map<String, dynamic> payload) async {
    40	    final res = await http.post(
    41	      _uri(path),
    42	      headers: {'Content-Type': 'application/json'},
    43	      body: jsonEncode(payload),
    44	    );
    45	    if (res.statusCode >= 400) {
    46	      throw Exception('HTTP ${res.statusCode} from $path: ${res.body}');
    47	    }
    48	    return jsonDecode(res.body) as Map<String, dynamic>;
    49	  }
    50	}
    51	
    52	class BackendRuntime {
    53	  Process? _process;
    54	  bool _startedByApp = false;
    55	
    56	  bool get startedByApp => _startedByApp;
    57	
    58	  Future<bool> isHealthy(String baseUrl) async {
    59	    try {
    60	      final res = await http
    61	          .get(Uri.parse('$baseUrl/health'))
    62	          .timeout(const Duration(seconds: 2));
    63	      return res.statusCode == 200;
    64	    } catch (_) {
    65	      return false;
    66	    }
    67	  }
    68	
    69	  Future<void> ensureRunning(String baseUrl) async {
    70	    if (kIsWeb) return;
    71	    if (await isHealthy(baseUrl)) return;
    72	
    73	    final parsed = Uri.parse(baseUrl);
    74	    final host = parsed.host;
    75	    final port = parsed.port == 0 ? 8000 : parsed.port;
    76	
    77	    final backendDir = _resolveBackendDir();
    78	    if (backendDir == null) {
    79	      throw Exception('Could not locate backend directory for auto-start.');
    80	    }
    81	
    82	    final args = [
    83	      '--project',
    84	      backendDir.path,
    85	      'run',
    86	      'uvicorn',
    87	      'app.main:app',
    88	      '--app-dir',
    89	      backendDir.path,
    90	      '--host',
    91	      host,
    92	      '--port',
    93	      '$port',
    94	    ];
    95	
    96	    _process =
    97	        await Process.start('uv', args, workingDirectory: backendDir.path);
    98	    _startedByApp = true;
    99	
   100	    unawaited(_process!.stdout.transform(utf8.decoder).forEach((_) {}));
   101	    unawaited(_process!.stderr.transform(utf8.decoder).forEach((_) {}));
   102	
   103	    for (var i = 0; i < 80; i++) {
   104	      if (await isHealthy(baseUrl)) return;
   105	      await Future<void>.delayed(const Duration(milliseconds: 250));
   106	    }
   107	
   108	    throw Exception('Backend auto-start timed out for $baseUrl');
   109	  }
   110	
   111	  Future<void> stop() async {
   112	    final p = _process;
   113	    if (p == null) return;
   114	    p.kill(ProcessSignal.sigterm);
   115	    _process = null;
   116	    _startedByApp = false;
   117	  }
   118	
   119	  Directory? _resolveBackendDir() {
   120	    final cwd = Directory.current;
   121	    final candidates = <Directory>[
   122	      Directory('${cwd.path}/../backend'),
   123	      Directory('${cwd.path}/backend'),
   124	      Directory('/home/mayank/repos/weaver/backend'),
   125	    ];
   126	
   127	    for (final dir in candidates) {
   128	      if (File('${dir.path}/pyproject.toml').existsSync()) {
   129	        return dir;
   130	      }
   131	    }
   132	    return null;
   133	  }
   134	}
   135	
   136	class BackendPreferences {
   137	  static const _keyBaseUrl = 'backend.baseUrl';
   138	  static const _keyAutoStart = 'backend.autoStart';
   139	  static const _keyDiscordChannelId = 'backend.discordChannelId';
   140	  static const _keyLlmApiKey = 'backend.llmApiKey';
   141	  static const _keyLlmBaseUrl = 'backend.llmBaseUrl';
   142	  static const _keyFilesystemRoot = 'backend.filesystemRoot';
   143	  static const _keyChatSessions = 'chat.sessions.v2';
   144	  static const _keyChatActiveSession = 'chat.activeSession.v2';
   145	  static const _keyModelName = 'model.name';
   146	  static const _keySystemPrompt = 'model.systemPrompt';
   147	  static const _keyTemperature = 'model.temperature';
   148	  static const _keyMaxTokens = 'model.maxTokens';
   149	
   150	  Future<String> loadBaseUrl() async {
   151	    final prefs = await SharedPreferences.getInstance();
   152	    return prefs.getString(_keyBaseUrl) ?? 'http://127.0.0.1:8000';
   153	  }
   154	
   155	  Future<void> saveBaseUrl(String value) async {
   156	    final prefs = await SharedPreferences.getInstance();
   157	    await prefs.setString(_keyBaseUrl, value);
   158	  }
   159	
   160	  Future<bool> loadAutoStart() async {
   161	    final prefs = await SharedPreferences.getInstance();
   162	    return prefs.getBool(_keyAutoStart) ?? true;
   163	  }
   164	
   165	  Future<void> saveAutoStart(bool value) async {
   166	    final prefs = await SharedPreferences.getInstance();
   167	    await prefs.setBool(_keyAutoStart, value);
   168	  }
   169	
   170	  Future<String> loadDiscordChannelId() async {
   171	    final prefs = await SharedPreferences.getInstance();
   172	    return prefs.getString(_keyDiscordChannelId) ?? '';
   173	  }
   174	
   175	  Future<void> saveDiscordChannelId(String value) async {
   176	    final prefs = await SharedPreferences.getInstance();
   177	    await prefs.setString(_keyDiscordChannelId, value);
   178	  }
   179	
   180	  Future<String> loadLlmApiKey() async {
   181	    final prefs = await SharedPreferences.getInstance();
   182	    return prefs.getString(_keyLlmApiKey) ?? '';
   183	  }
   184	
   185	  Future<void> saveLlmApiKey(String value) async {
   186	    final prefs = await SharedPreferences.getInstance();
   187	    await prefs.setString(_keyLlmApiKey, value);
   188	  }
   189	
   190	  Future<String> loadLlmBaseUrl() async {
   191	    final prefs = await SharedPreferences.getInstance();
   192	    return prefs.getString(_keyLlmBaseUrl) ?? 'https://api.openai.com/v1';
   193	  }
   194	
   195	  Future<void> saveLlmBaseUrl(String value) async {
   196	    final prefs = await SharedPreferences.getInstance();
   197	    await prefs.setString(_keyLlmBaseUrl, value);
   198	  }
   199	
   200	  Future<String> loadFilesystemRoot() async {
   201	    final prefs = await SharedPreferences.getInstance();
   202	    return prefs.getString(_keyFilesystemRoot) ?? '';
   203	  }
   204	
   205	  Future<void> saveFilesystemRoot(String value) async {
   206	    final prefs = await SharedPreferences.getInstance();
   207	    await prefs.setString(_keyFilesystemRoot, value);
   208	  }
   209	
   210	  Future<String> loadChatSessionsJson() async {
   211	    final prefs = await SharedPreferences.getInstance();
   212	    return prefs.getString(_keyChatSessions) ?? '';
   213	  }
   214	
   215	  Future<void> saveChatSessionsJson(String value) async {
   216	    final prefs = await SharedPreferences.getInstance();
   217	    await prefs.setString(_keyChatSessions, value);
   218	  }
   219	
   220	  Future<String?> loadActiveChatSessionId() async {
   221	    final prefs = await SharedPreferences.getInstance();
   222	    return prefs.getString(_keyChatActiveSession);
   223	  }
   224	
   225	  Future<void> saveActiveChatSessionId(String? value) async {
   226	    final prefs = await SharedPreferences.getInstance();
   227	    if (value == null || value.isEmpty) {
   228	      await prefs.remove(_keyChatActiveSession);
   229	      return;
   230	    }
   231	    await prefs.setString(_keyChatActiveSession, value);
   232	  }
   233	
   234	  Future<String> loadModelName() async {
   235	    final prefs = await SharedPreferences.getInstance();
   236	    return prefs.getString(_keyModelName) ?? 'gpt-4.1-mini';
   237	  }
   238	
   239	  Future<void> saveModelName(String value) async {
   240	    final prefs = await SharedPreferences.getInstance();
   241	    await prefs.setString(_keyModelName, value);
   242	  }
   243	
   244	  Future<String> loadSystemPrompt() async {
   245	    final prefs = await SharedPreferences.getInstance();
   246	    return prefs.getString(_keySystemPrompt) ??
   247	        'You are Weaver, an intelligent multi-agent assistant. You have access to a rich set of tools and can help with automation, file management, communication, and research. Be concise, precise, and proactive.';
   248	  }
   249	
   250	  Future<void> saveSystemPrompt(String value) async {
   251	    final prefs = await SharedPreferences.getInstance();
   252	    await prefs.setString(_keySystemPrompt, value);
   253	  }
   254	
   255	  Future<double> loadTemperature() async {
   256	    final prefs = await SharedPreferences.getInstance();
   257	    return prefs.getDouble(_keyTemperature) ?? 0.7;
   258	  }
   259	
   260	  Future<void> saveTemperature(double value) async {
   261	    final prefs = await SharedPreferences.getInstance();
   262	    await prefs.setDouble(_keyTemperature, value);
   263	  }
   264	
   265	  Future<int> loadMaxTokens() async {
   266	    final prefs = await SharedPreferences.getInstance();
   267	    return prefs.getInt(_keyMaxTokens) ?? 4096;
   268	  }
   269	
   270	  Future<void> saveMaxTokens(int value) async {
   271	    final prefs = await SharedPreferences.getInstance();
   272	    await prefs.setInt(_keyMaxTokens, value);
   273	  }
   274	}
   275	
   276	Future<void> openExternalUrl(String url) async {
   277	  final uri = Uri.parse(url);
   278	  await launchUrl(uri, mode: LaunchMode.externalApplication);
   279	}
```

## frontend/lib/theme/app_theme.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:google_fonts/google_fonts.dart';
     3	import 'colors.dart';
     4	
     5	class WeaverTheme {
     6	  WeaverTheme._();
     7	
     8	  static ThemeData get dark {
     9	    return ThemeData(
    10	      useMaterial3: true,
    11	      brightness: Brightness.dark,
    12	      scaffoldBackgroundColor: WeaverColors.background,
    13	      colorScheme: const ColorScheme.dark(
    14	        primary: WeaverColors.accent,
    15	        secondary: WeaverColors.success,
    16	        surface: WeaverColors.surface,
    17	        error: WeaverColors.error,
    18	        onPrimary: WeaverColors.background,
    19	        onSecondary: WeaverColors.background,
    20	        onSurface: WeaverColors.textPrimary,
    21	      ),
    22	      textTheme: GoogleFonts.interTextTheme(
    23	        const TextTheme(
    24	          displayLarge: TextStyle(color: WeaverColors.textPrimary),
    25	          displayMedium: TextStyle(color: WeaverColors.textPrimary),
    26	          displaySmall: TextStyle(color: WeaverColors.textPrimary),
    27	          headlineLarge: TextStyle(color: WeaverColors.textPrimary),
    28	          headlineMedium: TextStyle(color: WeaverColors.textPrimary),
    29	          headlineSmall: TextStyle(color: WeaverColors.textPrimary),
    30	          titleLarge: TextStyle(color: WeaverColors.textPrimary, fontWeight: FontWeight.w600),
    31	          titleMedium: TextStyle(color: WeaverColors.textPrimary, fontWeight: FontWeight.w500),
    32	          titleSmall: TextStyle(color: WeaverColors.textSecondary, fontWeight: FontWeight.w500),
    33	          bodyLarge: TextStyle(color: WeaverColors.textPrimary),
    34	          bodyMedium: TextStyle(color: WeaverColors.textSecondary),
    35	          bodySmall: TextStyle(color: WeaverColors.textMuted),
    36	          labelLarge: TextStyle(color: WeaverColors.textPrimary, fontWeight: FontWeight.w600),
    37	          labelMedium: TextStyle(color: WeaverColors.textSecondary, fontWeight: FontWeight.w500),
    38	          labelSmall: TextStyle(color: WeaverColors.textMuted),
    39	        ),
    40	      ),
    41	      cardTheme: const CardThemeData(
    42	        color: WeaverColors.card,
    43	        surfaceTintColor: Colors.transparent,
    44	        elevation: 0,
    45	        shape: RoundedRectangleBorder(
    46	          borderRadius: BorderRadius.all(Radius.circular(12)),
    47	          side: BorderSide(color: WeaverColors.cardBorder, width: 1),
    48	        ),
    49	      ),
    50	      dividerTheme: const DividerThemeData(
    51	        color: WeaverColors.cardBorder,
    52	        thickness: 1,
    53	      ),
    54	      inputDecorationTheme: InputDecorationTheme(
    55	        filled: true,
    56	        fillColor: WeaverColors.surface,
    57	        border: OutlineInputBorder(
    58	          borderRadius: BorderRadius.circular(10),
    59	          borderSide: const BorderSide(color: WeaverColors.cardBorder),
    60	        ),
    61	        enabledBorder: OutlineInputBorder(
    62	          borderRadius: BorderRadius.circular(10),
    63	          borderSide: const BorderSide(color: WeaverColors.cardBorder),
    64	        ),
    65	        focusedBorder: OutlineInputBorder(
    66	          borderRadius: BorderRadius.circular(10),
    67	          borderSide: const BorderSide(color: WeaverColors.accent, width: 1.5),
    68	        ),
    69	        hintStyle: const TextStyle(color: WeaverColors.textMuted),
    70	        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    71	      ),
    72	      elevatedButtonTheme: ElevatedButtonThemeData(
    73	        style: ElevatedButton.styleFrom(
    74	          backgroundColor: WeaverColors.accent,
    75	          foregroundColor: WeaverColors.background,
    76	          elevation: 0,
    77	          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    78	          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    79	          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    80	        ),
    81	      ),
    82	      outlinedButtonTheme: OutlinedButtonThemeData(
    83	        style: OutlinedButton.styleFrom(
    84	          foregroundColor: WeaverColors.textPrimary,
    85	          side: const BorderSide(color: WeaverColors.cardBorder),
    86	          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    87	          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    88	        ),
    89	      ),
    90	      iconButtonTheme: IconButtonThemeData(
    91	        style: IconButton.styleFrom(
    92	          foregroundColor: WeaverColors.textMuted,
    93	          hoverColor: WeaverColors.cardHover,
    94	        ),
    95	      ),
    96	      switchTheme: SwitchThemeData(
    97	        thumbColor: WidgetStateProperty.resolveWith((states) {
    98	          if (states.contains(WidgetState.selected)) return WeaverColors.background;
    99	          return WeaverColors.textMuted;
   100	        }),
   101	        trackColor: WidgetStateProperty.resolveWith((states) {
   102	          if (states.contains(WidgetState.selected)) return WeaverColors.accent;
   103	          return WeaverColors.cardBorder;
   104	        }),
   105	      ),
   106	      sliderTheme: const SliderThemeData(
   107	        activeTrackColor: WeaverColors.accent,
   108	        thumbColor: WeaverColors.accent,
   109	        overlayColor: WeaverColors.accentGlow,
   110	        inactiveTrackColor: WeaverColors.cardBorder,
   111	      ),
   112	      tooltipTheme: TooltipThemeData(
   113	        decoration: BoxDecoration(
   114	          color: WeaverColors.cardHover,
   115	          borderRadius: BorderRadius.circular(6),
   116	          border: Border.all(color: WeaverColors.cardBorder),
   117	        ),
   118	        textStyle: const TextStyle(color: WeaverColors.textPrimary, fontSize: 12),
   119	      ),
   120	      scrollbarTheme: ScrollbarThemeData(
   121	        thumbColor: WidgetStateProperty.all(WeaverColors.cardBorder),
   122	        radius: const Radius.circular(4),
   123	        thickness: WidgetStateProperty.all(4),
   124	      ),
   125	    );
   126	  }
   127	}
```

## frontend/lib/theme/colors.dart

```dart
     1	import 'package:flutter/material.dart';
     2	
     3	class WeaverColors {
     4	  WeaverColors._();
     5	
     6	  // Backgrounds
     7	  static const background = Color(0xFF0A0B0F);
     8	  static const surface = Color(0xFF12141A);
     9	  static const card = Color(0xFF1A1D26);
    10	  static const cardHover = Color(0xFF1F2330);
    11	  static const cardBorder = Color(0xFF2A2F3D);
    12	
    13	  // Accent — silk/amber gold
    14	  static const accent = Color(0xFFC8973A);
    15	  static const accentDim = Color(0xFF8A6520);
    16	  static const accentGlow = Color(0x33C8973A);
    17	  static const accentBright = Color(0xFFE8B445);
    18	
    19	  // Semantic
    20	  static const success = Color(0xFF3ABFA8);
    21	  static const successDim = Color(0xFF1E6B5E);
    22	  static const error = Color(0xFFE05252);
    23	  static const errorDim = Color(0xFF7A2929);
    24	  static const warning = Color(0xFFE09520);
    25	  static const warningDim = Color(0xFF7A5210);
    26	  static const info = Color(0xFF5B8DEF);
    27	  static const infoDim = Color(0xFF2A4A8A);
    28	
    29	  // Text
    30	  static const textPrimary = Color(0xFFEEF0F7);
    31	  static const textSecondary = Color(0xFFB0B8CC);
    32	  static const textMuted = Color(0xFF6B7280);
    33	  static const textDisabled = Color(0xFF3A3F50);
    34	
    35	  // Tool category colors
    36	  static const cloudColor = Color(0xFF5B8DEF);
    37	  static const messagingColor = Color(0xFF7B61FF);
    38	  static const filesColor = Color(0xFF3ABFA8);
    39	  static const devColor = Color(0xFFE09520);
    40	  static const productivityColor = Color(0xFFE05252);
    41	
    42	  // Node colors for workflow
    43	  static const triggerNode = Color(0xFF7B61FF);
    44	  static const actionNode = Color(0xFF3ABFA8);
    45	  static const conditionNode = Color(0xFFE09520);
    46	  static const outputNode = Color(0xFFC8973A);
    47	}
```

## frontend/lib/widgets/chat/chat_view.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:flutter_animate/flutter_animate.dart';
     3	import 'package:flutter_markdown/flutter_markdown.dart';
     4	import 'package:provider/provider.dart';
     5	import '../../providers/providers.dart';
     6	import '../../theme/colors.dart';
     7	import '../../models/models.dart';
     8	import '../common/animated_widgets.dart';
     9	
    10	class ChatView extends StatelessWidget {
    11	  const ChatView({super.key});
    12	
    13	  @override
    14	  Widget build(BuildContext context) {
    15	    return Consumer<ChatProvider>(
    16	      builder: (context, chatProvider, _) {
    17	        final session = chatProvider.activeSession;
    18	        if (session == null) {
    19	          return const _EmptyChatState();
    20	        }
    21	        return Column(
    22	          children: [
    23	            _ChatHeader(session: session),
    24	            const _ToolChipStrip(),
    25	            const Divider(height: 1),
    26	            Expanded(child: _MessageList(session: session)),
    27	            if (chatProvider.isTypingFor(session.id))
    28	              Padding(
    29	                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    30	                child: Align(
    31	                  alignment: Alignment.centerLeft,
    32	                  child: TypingIndicator(agentName: session.agentName),
    33	                ),
    34	              ),
    35	            _ChatInput(session: session),
    36	          ],
    37	        );
    38	      },
    39	    );
    40	  }
    41	}
    42	
    43	class _EmptyChatState extends StatelessWidget {
    44	  const _EmptyChatState();
    45	
    46	  @override
    47	  Widget build(BuildContext context) {
    48	    return Center(
    49	      child: Column(
    50	        mainAxisAlignment: MainAxisAlignment.center,
    51	        children: [
    52	          Container(
    53	            width: 80,
    54	            height: 80,
    55	            decoration: BoxDecoration(
    56	              color: WeaverColors.accentGlow,
    57	              shape: BoxShape.circle,
    58	              border: Border.all(color: WeaverColors.accent.withOpacity(0.3)),
    59	            ),
    60	            child: const Center(
    61	              child: Text('⟆',
    62	                  style: TextStyle(fontSize: 36, color: WeaverColors.accent)),
    63	            ),
    64	          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
    65	          const SizedBox(height: 24),
    66	          Text(
    67	            'Start a conversation',
    68	            style: Theme.of(context)
    69	                .textTheme
    70	                .headlineSmall
    71	                ?.copyWith(color: WeaverColors.textPrimary),
    72	          ).animate().fadeIn(delay: 200.ms),
    73	          const SizedBox(height: 8),
    74	          const Text(
    75	            'Select a chat from the sidebar or create a new one',
    76	            style: TextStyle(color: WeaverColors.textMuted, fontSize: 14),
    77	          ).animate().fadeIn(delay: 300.ms),
    78	          const SizedBox(height: 28),
    79	          Consumer<ChatProvider>(
    80	            builder: (ctx, chatProv, _) => ElevatedButton.icon(
    81	              onPressed: () {
    82	                chatProv.newChat();
    83	                Provider.of<AppState>(ctx, listen: false).setNavIndex(0);
    84	              },
    85	              icon: const Icon(Icons.add_rounded),
    86	              label: const Text('New Chat'),
    87	            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
    88	          ),
    89	        ],
    90	      ),
    91	    );
    92	  }
    93	}
    94	
    95	class _ChatHeader extends StatelessWidget {
    96	  final ChatSession session;
    97	  const _ChatHeader({required this.session});
    98	
    99	  @override
   100	  Widget build(BuildContext context) {
   101	    return Container(
   102	      height: 50,
   103	      padding: const EdgeInsets.symmetric(horizontal: 20),
   104	      decoration: const BoxDecoration(
   105	        border: Border(bottom: BorderSide(color: WeaverColors.cardBorder)),
   106	      ),
   107	      child: Row(
   108	        children: [
   109	          Column(
   110	            mainAxisAlignment: MainAxisAlignment.center,
   111	            crossAxisAlignment: CrossAxisAlignment.start,
   112	            children: [
   113	              Text(session.title,
   114	                  style: const TextStyle(
   115	                      fontSize: 14,
   116	                      fontWeight: FontWeight.w600,
   117	                      color: WeaverColors.textPrimary)),
   118	              Consumer<ModelProvider>(
   119	                builder: (_, modelProv, __) => Text(
   120	                  '${session.agentName} • ${modelProv.modelName}',
   121	                  style: const TextStyle(
   122	                      fontSize: 11, color: WeaverColors.textMuted),
   123	                ),
   124	              ),
   125	            ],
   126	          ),
   127	          const Spacer(),
   128	          Consumer<WorkflowsProvider>(
   129	            builder: (ctx, wfProv, _) {
   130	              final count = wfProv.workflowsForSession(session.id).length;
   131	              return TextButton.icon(
   132	                onPressed: () {
   133	                  Provider.of<AppState>(ctx, listen: false).setRightPanelTab(1);
   134	                  wfProv.toggleCreateDialog();
   135	                },
   136	                icon: const Icon(Icons.account_tree_rounded, size: 14),
   137	                label: Text(count > 0 ? '$count workflows' : 'Add workflow'),
   138	                style: TextButton.styleFrom(
   139	                    foregroundColor: WeaverColors.accent,
   140	                    textStyle: const TextStyle(fontSize: 12)),
   141	              );
   142	            },
   143	          ),
   144	          const SizedBox(width: 4),
   145	          Consumer<AppState>(
   146	            builder: (ctx, appState, _) => IconButton(
   147	              tooltip: 'Right panel',
   148	              onPressed: appState.toggleRightSidebar,
   149	              icon: const Icon(Icons.view_sidebar_outlined, size: 18),
   150	            ),
   151	          ),
   152	        ],
   153	      ),
   154	    );
   155	  }
   156	}
   157	
   158	class _ToolChipStrip extends StatelessWidget {
   159	  const _ToolChipStrip();
   160	
   161	  @override
   162	  Widget build(BuildContext context) {
   163	    return Consumer2<ChatProvider, ToolsProvider>(
   164	      builder: (context, chatProv, toolsProv, _) {
   165	        final session = chatProv.activeSession;
   166	        if (session == null) return const SizedBox.shrink();
   167	        final enabledTools = toolsProv.tools
   168	            .where((t) => session.enabledToolIds.contains(t.id))
   169	            .toList();
   170	
   171	        return Container(
   172	          height: 42,
   173	          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
   174	          child: Row(
   175	            children: [
   176	              const Text('Tools:',
   177	                  style: TextStyle(
   178	                      fontSize: 12,
   179	                      color: WeaverColors.textMuted,
   180	                      fontWeight: FontWeight.w500)),
   181	              const SizedBox(width: 8),
   182	              Expanded(
   183	                child: ListView(
   184	                  scrollDirection: Axis.horizontal,
   185	                  children: [
   186	                    ...enabledTools
   187	                        .map((t) => _ToolChip(tool: t, enabled: true)),
   188	                    _AddToolChip(),
   189	                  ],
   190	                ),
   191	              ),
   192	            ],
   193	          ),
   194	        );
   195	      },
   196	    );
   197	  }
   198	}
   199	
   200	class _ToolChip extends StatefulWidget {
   201	  final ToolModel tool;
   202	  final bool enabled;
   203	  const _ToolChip({required this.tool, required this.enabled});
   204	
   205	  @override
   206	  State<_ToolChip> createState() => _ToolChipState();
   207	}
   208	
   209	class _ToolChipState extends State<_ToolChip> {
   210	  bool _hovered = false;
   211	
   212	  @override
   213	  Widget build(BuildContext context) {
   214	    return MouseRegion(
   215	      onEnter: (_) => setState(() => _hovered = true),
   216	      onExit: (_) => setState(() => _hovered = false),
   217	      cursor: SystemMouseCursors.click,
   218	      child: GestureDetector(
   219	        onTap: () {
   220	          Provider.of<AppState>(context, listen: false).setRightPanelTab(0);
   221	          Provider.of<ToolsProvider>(context, listen: false)
   222	              .toggleExpanded(widget.tool.id);
   223	        },
   224	        child: AnimatedContainer(
   225	          duration: const Duration(milliseconds: 120),
   226	          margin: const EdgeInsets.only(right: 6),
   227	          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
   228	          decoration: BoxDecoration(
   229	            color: _hovered
   230	                ? widget.tool.categoryColor.withOpacity(0.15)
   231	                : widget.tool.categoryColor.withOpacity(0.08),
   232	            borderRadius: BorderRadius.circular(20),
   233	            border: Border.all(
   234	                color: widget.tool.categoryColor
   235	                    .withOpacity(_hovered ? 0.5 : 0.25)),
   236	          ),
   237	          child: Row(
   238	            mainAxisSize: MainAxisSize.min,
   239	            children: [
   240	              Text(widget.tool.logoEmoji, style: const TextStyle(fontSize: 11)),
   241	              const SizedBox(width: 5),
   242	              Text(widget.tool.name,
   243	                  style: TextStyle(
   244	                      fontSize: 11,
   245	                      color: widget.tool.categoryColor,
   246	                      fontWeight: FontWeight.w500)),
   247	            ],
   248	          ),
   249	        ),
   250	      ),
   251	    );
   252	  }
   253	}
   254	
   255	class _AddToolChip extends StatefulWidget {
   256	  @override
   257	  State<_AddToolChip> createState() => _AddToolChipState();
   258	}
   259	
   260	class _AddToolChipState extends State<_AddToolChip> {
   261	  bool _hovered = false;
   262	
   263	  @override
   264	  Widget build(BuildContext context) {
   265	    return MouseRegion(
   266	      onEnter: (_) => setState(() => _hovered = true),
   267	      onExit: (_) => setState(() => _hovered = false),
   268	      cursor: SystemMouseCursors.click,
   269	      child: GestureDetector(
   270	        onTap: () =>
   271	            Provider.of<AppState>(context, listen: false).setRightPanelTab(0),
   272	        child: AnimatedContainer(
   273	          duration: const Duration(milliseconds: 120),
   274	          margin: const EdgeInsets.only(right: 6),
   275	          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
   276	          decoration: BoxDecoration(
   277	            color: _hovered ? WeaverColors.cardHover : Colors.transparent,
   278	            borderRadius: BorderRadius.circular(20),
   279	            border: Border.all(
   280	                color: WeaverColors.cardBorder, style: BorderStyle.solid),
   281	          ),
   282	          child: const Row(
   283	            mainAxisSize: MainAxisSize.min,
   284	            children: [
   285	              Icon(Icons.add_rounded, size: 12, color: WeaverColors.textMuted),
   286	              SizedBox(width: 4),
   287	              Text('Add tool',
   288	                  style:
   289	                      TextStyle(fontSize: 11, color: WeaverColors.textMuted)),
   290	            ],
   291	          ),
   292	        ),
   293	      ),
   294	    );
   295	  }
   296	}
   297	
   298	class _MessageList extends StatefulWidget {
   299	  final ChatSession session;
   300	  const _MessageList({required this.session});
   301	
   302	  @override
   303	  State<_MessageList> createState() => _MessageListState();
   304	}
   305	
   306	class _MessageListState extends State<_MessageList> {
   307	  final _scrollController = ScrollController();
   308	
   309	  @override
   310	  void didUpdateWidget(_MessageList old) {
   311	    super.didUpdateWidget(old);
   312	    WidgetsBinding.instance.addPostFrameCallback((_) {
   313	      if (_scrollController.hasClients) {
   314	        _scrollController.animateTo(
   315	          _scrollController.position.maxScrollExtent,
   316	          duration: const Duration(milliseconds: 300),
   317	          curve: Curves.easeOut,
   318	        );
   319	      }
   320	    });
   321	  }
   322	
   323	  @override
   324	  Widget build(BuildContext context) {
   325	    final messages = widget.session.messages;
   326	    if (messages.isEmpty) {
   327	      return const _WelcomePanel();
   328	    }
   329	    return ListView.builder(
   330	      controller: _scrollController,
   331	      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
   332	      itemCount: messages.length,
   333	      itemBuilder: (context, i) => MessageBubble(message: messages[i])
   334	          .animate()
   335	          .fadeIn(duration: 250.ms)
   336	          .slideY(begin: 0.05, end: 0, duration: 250.ms),
   337	    );
   338	  }
   339	}
   340	
   341	class _WelcomePanel extends StatelessWidget {
   342	  const _WelcomePanel();
   343	
   344	  @override
   345	  Widget build(BuildContext context) {
   346	    final suggestions = [
   347	      '📧 Fetch my latest emails and summarize them',
   348	      '📁 List files in my Google Drive /Projects folder',
   349	      '🎮 Fetch latest Gmail and send it to Discord',
   350	      '🗄️ List files in backend sandbox root',
   351	    ];
   352	    return Center(
   353	      child: SizedBox(
   354	        width: 560,
   355	        child: Column(
   356	          mainAxisAlignment: MainAxisAlignment.center,
   357	          children: [
   358	            const Text('What can I help you with?',
   359	                style: TextStyle(
   360	                    fontSize: 22,
   361	                    fontWeight: FontWeight.w600,
   362	                    color: WeaverColors.textPrimary)),
   363	            const SizedBox(height: 8),
   364	            const Text('Use the tools in the right panel or ask me anything.',
   365	                style: TextStyle(fontSize: 14, color: WeaverColors.textMuted)),
   366	            const SizedBox(height: 28),
   367	            ...suggestions.asMap().entries.map((e) => _SuggestionCard(
   368	                  label: e.value,
   369	                  delay: e.key * 60,
   370	                )),
   371	          ],
   372	        ),
   373	      ),
   374	    );
   375	  }
   376	}
   377	
   378	class _SuggestionCard extends StatefulWidget {
   379	  final String label;
   380	  final int delay;
   381	  const _SuggestionCard({required this.label, required this.delay});
   382	
   383	  @override
   384	  State<_SuggestionCard> createState() => _SuggestionCardState();
   385	}
   386	
   387	class _SuggestionCardState extends State<_SuggestionCard> {
   388	  bool _hovered = false;
   389	
   390	  @override
   391	  Widget build(BuildContext context) {
   392	    return MouseRegion(
   393	      onEnter: (_) => setState(() => _hovered = true),
   394	      onExit: (_) => setState(() => _hovered = false),
   395	      cursor: SystemMouseCursors.click,
   396	      child: GestureDetector(
   397	        onTap: () {
   398	          Provider.of<ChatProvider>(context, listen: false)
   399	              .inputController
   400	              .text = widget.label.substring(2).trim();
   401	        },
   402	        child: AnimatedContainer(
   403	          duration: const Duration(milliseconds: 150),
   404	          margin: const EdgeInsets.only(bottom: 8),
   405	          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
   406	          decoration: BoxDecoration(
   407	            color: _hovered ? WeaverColors.cardHover : WeaverColors.card,
   408	            borderRadius: BorderRadius.circular(10),
   409	            border: Border.all(
   410	              color: _hovered
   411	                  ? WeaverColors.accent.withOpacity(0.4)
   412	                  : WeaverColors.cardBorder,
   413	            ),
   414	          ),
   415	          child: Row(
   416	            children: [
   417	              Expanded(
   418	                  child: Text(widget.label,
   419	                      style: const TextStyle(
   420	                          fontSize: 13, color: WeaverColors.textSecondary))),
   421	              Icon(Icons.arrow_forward_rounded,
   422	                  size: 15,
   423	                  color: _hovered
   424	                      ? WeaverColors.accent
   425	                      : WeaverColors.textDisabled),
   426	            ],
   427	          ),
   428	        ),
   429	      ),
   430	    ).animate().fadeIn(delay: Duration(milliseconds: widget.delay)).slideY(
   431	        begin: 0.1, end: 0, delay: Duration(milliseconds: widget.delay));
   432	  }
   433	}
   434	
   435	class MessageBubble extends StatelessWidget {
   436	  final ChatMessage message;
   437	  const MessageBubble({super.key, required this.message});
   438	
   439	  @override
   440	  Widget build(BuildContext context) {
   441	    final isUser = message.role == MessageRole.user;
   442	    return Padding(
   443	      padding: const EdgeInsets.only(bottom: 16),
   444	      child: isUser
   445	          ? _UserBubble(message: message)
   446	          : _AssistantBubble(message: message),
   447	    );
   448	  }
   449	}
   450	
   451	class _UserBubble extends StatelessWidget {
   452	  final ChatMessage message;
   453	  const _UserBubble({required this.message});
   454	
   455	  @override
   456	  Widget build(BuildContext context) {
   457	    return Row(
   458	      mainAxisAlignment: MainAxisAlignment.end,
   459	      crossAxisAlignment: CrossAxisAlignment.end,
   460	      children: [
   461	        ConstrainedBox(
   462	          constraints: const BoxConstraints(maxWidth: 520),
   463	          child: Container(
   464	            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
   465	            decoration: BoxDecoration(
   466	              color: WeaverColors.accentGlow,
   467	              borderRadius: const BorderRadius.only(
   468	                topLeft: Radius.circular(16),
   469	                topRight: Radius.circular(16),
   470	                bottomLeft: Radius.circular(16),
   471	                bottomRight: Radius.circular(4),
   472	              ),
   473	              border: Border.all(color: WeaverColors.accent.withOpacity(0.3)),
   474	            ),
   475	            child: Text(message.content,
   476	                style: const TextStyle(
   477	                    fontSize: 14,
   478	                    color: WeaverColors.textPrimary,
   479	                    height: 1.5)),
   480	          ),
   481	        ),
   482	        const SizedBox(width: 10),
   483	        Container(
   484	          width: 32,
   485	          height: 32,
   486	          decoration: BoxDecoration(
   487	            color: WeaverColors.accent,
   488	            shape: BoxShape.circle,
   489	          ),
   490	          child: const Center(
   491	              child: Text('M',
   492	                  style: TextStyle(
   493	                      color: WeaverColors.background,
   494	                      fontWeight: FontWeight.bold,
   495	                      fontSize: 14))),
   496	        ),
   497	      ],
   498	    );
   499	  }
   500	}
   501	
   502	class _AssistantBubble extends StatelessWidget {
   503	  final ChatMessage message;
   504	  const _AssistantBubble({required this.message});
   505	
   506	  @override
   507	  Widget build(BuildContext context) {
   508	    return Row(
   509	      crossAxisAlignment: CrossAxisAlignment.start,
   510	      children: [
   511	        Container(
   512	          width: 32,
   513	          height: 32,
   514	          decoration: BoxDecoration(
   515	            color: WeaverColors.accentGlow,
   516	            shape: BoxShape.circle,
   517	            border: Border.all(color: WeaverColors.accent.withOpacity(0.4)),
   518	          ),
   519	          child: const Center(
   520	              child: Text('W',
   521	                  style: TextStyle(
   522	                      color: WeaverColors.accent,
   523	                      fontWeight: FontWeight.bold,
   524	                      fontSize: 14))),
   525	        ),
   526	        const SizedBox(width: 10),
   527	        Expanded(
   528	          child: Column(
   529	            crossAxisAlignment: CrossAxisAlignment.start,
   530	            children: [
   531	              if (message.toolCall != null)
   532	                _ToolCallCard(toolCall: message.toolCall!),
   533	              if (message.toolCall != null) const SizedBox(height: 8),
   534	              Container(
   535	                padding:
   536	                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
   537	                decoration: BoxDecoration(
   538	                  color: WeaverColors.card,
   539	                  borderRadius: const BorderRadius.only(
   540	                    topLeft: Radius.circular(4),
   541	                    topRight: Radius.circular(16),
   542	                    bottomLeft: Radius.circular(16),
   543	                    bottomRight: Radius.circular(16),
   544	                  ),
   545	                  border: Border.all(color: WeaverColors.cardBorder),
   546	                ),
   547	                child: _AssistantMessageContent(text: message.content),
   548	              ),
   549	              const SizedBox(height: 4),
   550	              Text(
   551	                _formatTime(message.timestamp),
   552	                style: const TextStyle(
   553	                    fontSize: 10, color: WeaverColors.textMuted),
   554	              ),
   555	            ],
   556	          ),
   557	        ),
   558	      ],
   559	    );
   560	  }
   561	
   562	  String _formatTime(DateTime dt) {
   563	    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
   564	  }
   565	}
   566	
   567	class _ToolCallCard extends StatelessWidget {
   568	  final ToolCallResult toolCall;
   569	  const _ToolCallCard({required this.toolCall});
   570	
   571	  @override
   572	  Widget build(BuildContext context) {
   573	    return Container(
   574	      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
   575	      margin: const EdgeInsets.only(bottom: 4),
   576	      decoration: BoxDecoration(
   577	        color: WeaverColors.surface,
   578	        borderRadius: BorderRadius.circular(8),
   579	        border: Border.all(
   580	          color: toolCall.success
   581	              ? WeaverColors.success.withOpacity(0.4)
   582	              : WeaverColors.error.withOpacity(0.4),
   583	        ),
   584	      ),
   585	      child: Row(
   586	        children: [
   587	          Icon(
   588	            toolCall.success ? Icons.bolt_rounded : Icons.error_outline_rounded,
   589	            size: 14,
   590	            color: toolCall.success ? WeaverColors.success : WeaverColors.error,
   591	          ),
   592	          const SizedBox(width: 8),
   593	          Text(
   594	            toolCall.toolName,
   595	            style: const TextStyle(
   596	                fontSize: 12,
   597	                fontWeight: FontWeight.w600,
   598	                color: WeaverColors.textSecondary,
   599	                fontFamily: 'JetBrainsMono'),
   600	          ),
   601	          const SizedBox(width: 8),
   602	          Expanded(
   603	            child: Text(
   604	              toolCall.result,
   605	              style:
   606	                  const TextStyle(fontSize: 11, color: WeaverColors.textMuted),
   607	              overflow: TextOverflow.ellipsis,
   608	            ),
   609	          ),
   610	          Container(
   611	            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
   612	            decoration: BoxDecoration(
   613	              color: toolCall.success
   614	                  ? WeaverColors.successDim
   615	                  : WeaverColors.errorDim,
   616	              borderRadius: BorderRadius.circular(4),
   617	            ),
   618	            child: Text(
   619	              toolCall.success ? 'OK' : 'ERR',
   620	              style: TextStyle(
   621	                fontSize: 9,
   622	                fontWeight: FontWeight.w700,
   623	                color: toolCall.success
   624	                    ? WeaverColors.success
   625	                    : WeaverColors.error,
   626	              ),
   627	            ),
   628	          ),
   629	        ],
   630	      ),
   631	    );
   632	  }
   633	}
   634	
   635	class _AssistantMessageContent extends StatelessWidget {
   636	  final String text;
   637	  const _AssistantMessageContent({required this.text});
   638	
   639	  @override
   640	  Widget build(BuildContext context) {
   641	    final parsed = _ParsedAssistantBody.parse(text);
   642	    return Column(
   643	      crossAxisAlignment: CrossAxisAlignment.start,
   644	      children: [
   645	        for (final think in parsed.thinkBlocks) ...[
   646	          _ThinkBlock(content: think),
   647	          const SizedBox(height: 10),
   648	        ],
   649	        for (final tool in parsed.toolBlocks) ...[
   650	          _InlineToolBlock(content: tool),
   651	          const SizedBox(height: 10),
   652	        ],
   653	        _MarkdownText(text: parsed.visibleMarkdown),
   654	      ],
   655	    );
   656	  }
   657	}
   658	
   659	class _ThinkBlock extends StatefulWidget {
   660	  final String content;
   661	  const _ThinkBlock({required this.content});
   662	
   663	  @override
   664	  State<_ThinkBlock> createState() => _ThinkBlockState();
   665	}
   666	
   667	class _ThinkBlockState extends State<_ThinkBlock> {
   668	  bool _expanded = false;
   669	
   670	  @override
   671	  Widget build(BuildContext context) {
   672	    return Container(
   673	      width: double.infinity,
   674	      decoration: BoxDecoration(
   675	        color: WeaverColors.surface,
   676	        borderRadius: BorderRadius.circular(10),
   677	        border: Border.all(color: WeaverColors.cardBorder),
   678	      ),
   679	      child: Column(
   680	        crossAxisAlignment: CrossAxisAlignment.start,
   681	        children: [
   682	          InkWell(
   683	            onTap: () => setState(() => _expanded = !_expanded),
   684	            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
   685	            child: Padding(
   686	              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
   687	              child: Row(
   688	                children: [
   689	                  Icon(
   690	                    _expanded
   691	                        ? Icons.expand_less_rounded
   692	                        : Icons.expand_more_rounded,
   693	                    size: 16,
   694	                    color: WeaverColors.warning,
   695	                  ),
   696	                  const SizedBox(width: 6),
   697	                  const Text(
   698	                    'Thinking',
   699	                    style: TextStyle(
   700	                      fontSize: 12,
   701	                      fontWeight: FontWeight.w600,
   702	                      color: WeaverColors.warning,
   703	                    ),
   704	                  ),
   705	                ],
   706	              ),
   707	            ),
   708	          ),
   709	          if (_expanded)
   710	            Padding(
   711	              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
   712	              child: _MarkdownText(text: widget.content),
   713	            ),
   714	        ],
   715	      ),
   716	    );
   717	  }
   718	}
   719	
   720	class _InlineToolBlock extends StatelessWidget {
   721	  final String content;
   722	  const _InlineToolBlock({required this.content});
   723	
   724	  @override
   725	  Widget build(BuildContext context) {
   726	    return Container(
   727	      width: double.infinity,
   728	      padding: const EdgeInsets.all(10),
   729	      decoration: BoxDecoration(
   730	        color: WeaverColors.surface,
   731	        borderRadius: BorderRadius.circular(10),
   732	        border: Border.all(color: WeaverColors.accent.withOpacity(0.35)),
   733	      ),
   734	      child: Column(
   735	        crossAxisAlignment: CrossAxisAlignment.start,
   736	        children: [
   737	          const Text(
   738	            'Tool Output',
   739	            style: TextStyle(
   740	              fontSize: 11,
   741	              color: WeaverColors.accent,
   742	              fontWeight: FontWeight.w700,
   743	              letterSpacing: 0.4,
   744	            ),
   745	          ),
   746	          const SizedBox(height: 6),
   747	          _MarkdownText(text: content),
   748	        ],
   749	      ),
   750	    );
   751	  }
   752	}
   753	
   754	class _MarkdownText extends StatelessWidget {
   755	  final String text;
   756	  const _MarkdownText({required this.text});
   757	
   758	  @override
   759	  Widget build(BuildContext context) {
   760	    final cleaned = text.trim();
   761	    if (cleaned.isEmpty) {
   762	      return const SizedBox.shrink();
   763	    }
   764	    return MarkdownBody(
   765	      data: cleaned,
   766	      selectable: true,
   767	      styleSheet: MarkdownStyleSheet(
   768	        p: const TextStyle(
   769	          fontSize: 14,
   770	          color: WeaverColors.textPrimary,
   771	          height: 1.55,
   772	        ),
   773	        code: const TextStyle(
   774	          fontSize: 12,
   775	          color: WeaverColors.textPrimary,
   776	          fontFamily: 'JetBrainsMono',
   777	        ),
   778	        codeblockPadding: const EdgeInsets.all(10),
   779	        codeblockDecoration: BoxDecoration(
   780	          color: WeaverColors.surface,
   781	          borderRadius: BorderRadius.circular(8),
   782	          border: Border.all(color: WeaverColors.cardBorder),
   783	        ),
   784	        blockquote: const TextStyle(
   785	          color: WeaverColors.textSecondary,
   786	          fontStyle: FontStyle.italic,
   787	        ),
   788	      ),
   789	    );
   790	  }
   791	}
   792	
   793	class _ParsedAssistantBody {
   794	  final String visibleMarkdown;
   795	  final List<String> thinkBlocks;
   796	  final List<String> toolBlocks;
   797	
   798	  const _ParsedAssistantBody({
   799	    required this.visibleMarkdown,
   800	    required this.thinkBlocks,
   801	    required this.toolBlocks,
   802	  });
   803	
   804	  static _ParsedAssistantBody parse(String raw) {
   805	    var remaining = raw;
   806	    final thinkBlocks = <String>[];
   807	    final toolBlocks = <String>[];
   808	
   809	    final thinkRegex = RegExp(r'<think>([\s\S]*?)</think>', caseSensitive: false);
   810	    remaining = remaining.replaceAllMapped(thinkRegex, (m) {
   811	      final content = (m.group(1) ?? '').trim();
   812	      if (content.isNotEmpty) {
   813	        thinkBlocks.add(content);
   814	      }
   815	      return '';
   816	    });
   817	
   818	    final toolFenceRegex = RegExp(
   819	      r'```(?:tool|tools|tool_call|tool-result|tool_result)\s*\n([\s\S]*?)```',
   820	      caseSensitive: false,
   821	    );
   822	    remaining = remaining.replaceAllMapped(toolFenceRegex, (m) {
   823	      final content = (m.group(1) ?? '').trim();
   824	      if (content.isNotEmpty) {
   825	        toolBlocks.add(content);
   826	      }
   827	      return '';
   828	    });
   829	
   830	    return _ParsedAssistantBody(
   831	      visibleMarkdown: remaining.trim(),
   832	      thinkBlocks: thinkBlocks,
   833	      toolBlocks: toolBlocks,
   834	    );
   835	  }
   836	}
   837	
   838	class _ChatInput extends StatefulWidget {
   839	  final ChatSession session;
   840	  const _ChatInput({required this.session});
   841	
   842	  @override
   843	  State<_ChatInput> createState() => _ChatInputState();
   844	}
   845	
   846	class _ChatInputState extends State<_ChatInput> {
   847	  final _focusNode = FocusNode();
   848	
   849	  @override
   850	  void dispose() {
   851	    _focusNode.dispose();
   852	    super.dispose();
   853	  }
   854	
   855	  @override
   856	  Widget build(BuildContext context) {
   857	    return Consumer<ChatProvider>(
   858	      builder: (context, chatProv, _) {
   859	        return Container(
   860	          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
   861	          decoration: const BoxDecoration(
   862	            border: Border(top: BorderSide(color: WeaverColors.cardBorder)),
   863	          ),
   864	          child: Container(
   865	            decoration: BoxDecoration(
   866	              color: WeaverColors.card,
   867	              borderRadius: BorderRadius.circular(14),
   868	              border: Border.all(color: WeaverColors.cardBorder),
   869	            ),
   870	            child: Column(
   871	              children: [
   872	                TextField(
   873	                  controller: chatProv.inputController,
   874	                  focusNode: _focusNode,
   875	                  maxLines: null,
   876	                  keyboardType: TextInputType.multiline,
   877	                  textInputAction: TextInputAction.newline,
   878	                  style: const TextStyle(
   879	                      fontSize: 14,
   880	                      color: WeaverColors.textPrimary,
   881	                      height: 1.5),
   882	                  decoration: const InputDecoration(
   883	                    hintText: 'Message Weaver... (Shift+Enter for new line)',
   884	                    border: InputBorder.none,
   885	                    enabledBorder: InputBorder.none,
   886	                    focusedBorder: InputBorder.none,
   887	                    contentPadding: EdgeInsets.fromLTRB(16, 14, 16, 8),
   888	                    fillColor: Colors.transparent,
   889	                    filled: false,
   890	                  ),
   891	                  onSubmitted: (val) {
   892	                    chatProv.sendMessage(val);
   893	                    _focusNode.requestFocus();
   894	                  },
   895	                ),
   896	                Padding(
   897	                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
   898	                  child: Row(
   899	                    children: [
   900	                      // Quick action buttons
   901	                      _InputAction(
   902	                          icon: Icons.attach_file_rounded,
   903	                          tooltip: 'Attach file'),
   904	                      _InputAction(
   905	                          icon: Icons.account_tree_rounded,
   906	                          tooltip: 'Create workflow',
   907	                          onTap: () {
   908	                            Provider.of<AppState>(context, listen: false)
   909	                                .setRightPanelTab(1);
   910	                            Provider.of<WorkflowsProvider>(context,
   911	                                    listen: false)
   912	                                .toggleCreateDialog();
   913	                          }),
   914	                      _InputAction(
   915	                          icon: Icons.code_rounded, tooltip: 'Code mode'),
   916	                      const Spacer(),
   917	                      // Model indicator
   918	                      Consumer<ModelProvider>(
   919	                        builder: (ctx, modelProv, _) => Container(
   920	                          padding: const EdgeInsets.symmetric(
   921	                              horizontal: 8, vertical: 4),
   922	                          decoration: BoxDecoration(
   923	                            color: WeaverColors.surface,
   924	                            borderRadius: BorderRadius.circular(6),
   925	                          ),
   926	                          child: Text(
   927	                            modelProv.modelName,
   928	                            style: const TextStyle(
   929	                                fontSize: 11,
   930	                                color: WeaverColors.textMuted,
   931	                                fontWeight: FontWeight.w500),
   932	                          ),
   933	                        ),
   934	                      ),
   935	                      const SizedBox(width: 8),
   936	                      // Send button
   937	                      GestureDetector(
   938	                        onTap: () =>
   939	                            chatProv.sendMessage(chatProv.inputController.text),
   940	                        child: Container(
   941	                          width: 32,
   942	                          height: 32,
   943	                          decoration: BoxDecoration(
   944	                            color: WeaverColors.accent,
   945	                            borderRadius: BorderRadius.circular(8),
   946	                          ),
   947	                          child: const Center(
   948	                            child: Icon(Icons.arrow_upward_rounded,
   949	                                color: WeaverColors.background, size: 16),
   950	                          ),
   951	                        ),
   952	                      ),
   953	                    ],
   954	                  ),
   955	                ),
   956	              ],
   957	            ),
   958	          ),
   959	        );
   960	      },
   961	    );
   962	  }
   963	}
   964	
   965	class _InputAction extends StatefulWidget {
   966	  final IconData icon;
   967	  final String tooltip;
   968	  final VoidCallback? onTap;
   969	  const _InputAction({required this.icon, required this.tooltip, this.onTap});
   970	
   971	  @override
   972	  State<_InputAction> createState() => _InputActionState();
   973	}
   974	
   975	class _InputActionState extends State<_InputAction> {
   976	  bool _hovered = false;
   977	
   978	  @override
   979	  Widget build(BuildContext context) {
   980	    return Tooltip(
   981	      message: widget.tooltip,
   982	      child: MouseRegion(
   983	        onEnter: (_) => setState(() => _hovered = true),
   984	        onExit: (_) => setState(() => _hovered = false),
   985	        cursor: SystemMouseCursors.click,
   986	        child: GestureDetector(
   987	          onTap: widget.onTap,
   988	          child: AnimatedContainer(
   989	            duration: const Duration(milliseconds: 100),
   990	            margin: const EdgeInsets.only(right: 2),
   991	            padding: const EdgeInsets.all(6),
   992	            decoration: BoxDecoration(
   993	              color: _hovered ? WeaverColors.cardHover : Colors.transparent,
   994	              borderRadius: BorderRadius.circular(6),
   995	            ),
   996	            child: Icon(widget.icon,
   997	                size: 15,
   998	                color: _hovered
   999	                    ? WeaverColors.textSecondary
  1000	                    : WeaverColors.textMuted),
  1001	          ),
  1002	        ),
  1003	      ),
  1004	    );
  1005	  }
  1006	}
```

## frontend/lib/widgets/chat/model_panel.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:provider/provider.dart';
     3	
     4	import '../../providers/providers.dart';
     5	import '../../theme/colors.dart';
     6	
     7	class ModelPanel extends StatefulWidget {
     8	  const ModelPanel({super.key});
     9	
    10	  @override
    11	  State<ModelPanel> createState() => _ModelPanelState();
    12	}
    13	
    14	class _ModelPanelState extends State<ModelPanel> {
    15	  late final TextEditingController _modelNameController;
    16	  late final TextEditingController _systemPromptController;
    17	
    18	  @override
    19	  void initState() {
    20	    super.initState();
    21	    _modelNameController = TextEditingController();
    22	    _systemPromptController = TextEditingController();
    23	  }
    24	
    25	  @override
    26	  void dispose() {
    27	    _modelNameController.dispose();
    28	    _systemPromptController.dispose();
    29	    super.dispose();
    30	  }
    31	
    32	  @override
    33	  Widget build(BuildContext context) {
    34	    return Consumer<ModelProvider>(
    35	      builder: (context, modelProv, _) {
    36	        if (_modelNameController.text != modelProv.modelName) {
    37	          _modelNameController.text = modelProv.modelName;
    38	        }
    39	        if (_systemPromptController.text != modelProv.systemPrompt) {
    40	          _systemPromptController.text = modelProv.systemPrompt;
    41	        }
    42	
    43	        return ListView(
    44	          padding: const EdgeInsets.all(14),
    45	          children: [
    46	            _SectionLabel('Model'),
    47	            const SizedBox(height: 8),
    48	            TextField(
    49	              controller: _modelNameController,
    50	              decoration: const InputDecoration(
    51	                hintText:
    52	                    'Enter model name (e.g. gpt-4.1-mini, openrouter/model)',
    53	                isDense: true,
    54	              ),
    55	              onSubmitted: modelProv.setModelName,
    56	            ),
    57	            const SizedBox(height: 8),
    58	            SizedBox(
    59	              height: 30,
    60	              child: ElevatedButton(
    61	                onPressed: () =>
    62	                    modelProv.setModelName(_modelNameController.text),
    63	                child: const Text('Save Model Name'),
    64	              ),
    65	            ),
    66	            const SizedBox(height: 18),
    67	            _SectionLabel('System Prompt'),
    68	            const SizedBox(height: 8),
    69	            TextField(
    70	              maxLines: 6,
    71	              controller: _systemPromptController,
    72	              style: const TextStyle(
    73	                  fontSize: 12, color: WeaverColors.textSecondary, height: 1.5),
    74	              decoration: const InputDecoration(
    75	                hintText: 'Enter system prompt...',
    76	                isDense: true,
    77	              ),
    78	              onChanged: modelProv.setSystemPrompt,
    79	            ),
    80	            const SizedBox(height: 16),
    81	            _SliderRow(
    82	              label: 'Temperature',
    83	              value: modelProv.temperature,
    84	              min: 0,
    85	              max: 2,
    86	              displayValue: modelProv.temperature.toStringAsFixed(2),
    87	              onChanged: modelProv.setTemperature,
    88	            ),
    89	            const SizedBox(height: 12),
    90	            _SliderRow(
    91	              label: 'Max Tokens',
    92	              value: modelProv.maxTokens.toDouble(),
    93	              min: 256,
    94	              max: 32768,
    95	              displayValue: '${modelProv.maxTokens}',
    96	              onChanged: (v) => modelProv.setMaxTokens(v.round()),
    97	            ),
    98	          ],
    99	        );
   100	      },
   101	    );
   102	  }
   103	}
   104	
   105	class _SectionLabel extends StatelessWidget {
   106	  final String label;
   107	  const _SectionLabel(this.label);
   108	
   109	  @override
   110	  Widget build(BuildContext context) {
   111	    return Text(
   112	      label.toUpperCase(),
   113	      style: const TextStyle(
   114	        fontSize: 10,
   115	        fontWeight: FontWeight.w600,
   116	        color: WeaverColors.textMuted,
   117	        letterSpacing: 0.8,
   118	      ),
   119	    );
   120	  }
   121	}
   122	
   123	class _SliderRow extends StatelessWidget {
   124	  final String label;
   125	  final double value;
   126	  final double min;
   127	  final double max;
   128	  final String displayValue;
   129	  final ValueChanged<double> onChanged;
   130	
   131	  const _SliderRow({
   132	    required this.label,
   133	    required this.value,
   134	    required this.min,
   135	    required this.max,
   136	    required this.displayValue,
   137	    required this.onChanged,
   138	  });
   139	
   140	  @override
   141	  Widget build(BuildContext context) {
   142	    return Column(
   143	      crossAxisAlignment: CrossAxisAlignment.start,
   144	      children: [
   145	        Row(
   146	          children: [
   147	            Text(
   148	              label,
   149	              style: const TextStyle(
   150	                fontSize: 12,
   151	                color: WeaverColors.textSecondary,
   152	                fontWeight: FontWeight.w500,
   153	              ),
   154	            ),
   155	            const Spacer(),
   156	            Container(
   157	              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
   158	              decoration: BoxDecoration(
   159	                color: WeaverColors.surface,
   160	                borderRadius: BorderRadius.circular(6),
   161	                border: Border.all(color: WeaverColors.cardBorder),
   162	              ),
   163	              child: Text(
   164	                displayValue,
   165	                style: const TextStyle(
   166	                  fontSize: 11,
   167	                  color: WeaverColors.accent,
   168	                  fontWeight: FontWeight.w600,
   169	                  fontFamily: 'JetBrainsMono',
   170	                ),
   171	              ),
   172	            ),
   173	          ],
   174	        ),
   175	        Slider(
   176	            value: value.clamp(min, max),
   177	            min: min,
   178	            max: max,
   179	            onChanged: onChanged),
   180	      ],
   181	    );
   182	  }
   183	}
```

## frontend/lib/widgets/common/animated_widgets.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:flutter_animate/flutter_animate.dart';
     3	import '../../theme/colors.dart';
     4	
     5	class SilkSpinner extends StatelessWidget {
     6	  final double size;
     7	
     8	  const SilkSpinner({super.key, this.size = 20});
     9	
    10	  @override
    11	  Widget build(BuildContext context) {
    12	    return SizedBox(
    13	      width: size,
    14	      height: size,
    15	      child: CircularProgressIndicator(
    16	        strokeWidth: 1.5,
    17	        color: WeaverColors.accent,
    18	        backgroundColor: WeaverColors.cardBorder,
    19	      ),
    20	    );
    21	  }
    22	}
    23	
    24	class TypingIndicator extends StatelessWidget {
    25	  final String agentName;
    26	
    27	  const TypingIndicator({super.key, required this.agentName});
    28	
    29	  @override
    30	  Widget build(BuildContext context) {
    31	    return Row(
    32	      children: [
    33	        Container(
    34	          width: 32,
    35	          height: 32,
    36	          decoration: BoxDecoration(
    37	            color: WeaverColors.accentGlow,
    38	            shape: BoxShape.circle,
    39	            border: Border.all(color: WeaverColors.accent.withOpacity(0.4)),
    40	          ),
    41	          child: const Center(
    42	            child: Text('W', style: TextStyle(color: WeaverColors.accent, fontWeight: FontWeight.bold, fontSize: 14)),
    43	          ),
    44	        ),
    45	        const SizedBox(width: 10),
    46	        Container(
    47	          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    48	          decoration: BoxDecoration(
    49	            color: WeaverColors.card,
    50	            borderRadius: BorderRadius.circular(12),
    51	            border: Border.all(color: WeaverColors.cardBorder),
    52	          ),
    53	          child: Row(
    54	            children: [
    55	              Text('$agentName is thinking', style: const TextStyle(color: WeaverColors.textMuted, fontSize: 13)),
    56	              const SizedBox(width: 8),
    57	              Row(
    58	                children: List.generate(3, (i) => Container(
    59	                  margin: const EdgeInsets.only(right: 3),
    60	                  width: 5,
    61	                  height: 5,
    62	                  decoration: const BoxDecoration(
    63	                    color: WeaverColors.accent,
    64	                    shape: BoxShape.circle,
    65	                  ),
    66	                ).animate(onPlay: (c) => c.repeat()).fadeIn(
    67	                  duration: 400.ms,
    68	                  delay: (i * 150).ms,
    69	                ).then().fadeOut(duration: 400.ms)),
    70	              ),
    71	            ],
    72	          ),
    73	        ),
    74	      ],
    75	    );
    76	  }
    77	}
    78	
    79	class AnimatedGradientBorder extends StatefulWidget {
    80	  final Widget child;
    81	  final double borderRadius;
    82	
    83	  const AnimatedGradientBorder({super.key, required this.child, this.borderRadius = 12});
    84	
    85	  @override
    86	  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
    87	}
    88	
    89	class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    90	    with SingleTickerProviderStateMixin {
    91	  late AnimationController _controller;
    92	
    93	  @override
    94	  void initState() {
    95	    super.initState();
    96	    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
    97	      ..repeat();
    98	  }
    99	
   100	  @override
   101	  void dispose() {
   102	    _controller.dispose();
   103	    super.dispose();
   104	  }
   105	
   106	  @override
   107	  Widget build(BuildContext context) {
   108	    return AnimatedBuilder(
   109	      animation: _controller,
   110	      builder: (_, child) => Container(
   111	        decoration: BoxDecoration(
   112	          borderRadius: BorderRadius.circular(widget.borderRadius),
   113	          gradient: SweepGradient(
   114	            colors: const [
   115	              WeaverColors.accent,
   116	              WeaverColors.accentDim,
   117	              WeaverColors.accent,
   118	            ],
   119	            startAngle: _controller.value * 6.28,
   120	            endAngle: _controller.value * 6.28 + 6.28,
   121	          ),
   122	        ),
   123	        padding: const EdgeInsets.all(1.5),
   124	        child: ClipRRect(
   125	          borderRadius: BorderRadius.circular(widget.borderRadius - 1.5),
   126	          child: child,
   127	        ),
   128	      ),
   129	      child: widget.child,
   130	    );
   131	  }
   132	}
   133	
   134	// Weaver spider logo
   135	class WeaverLogo extends StatelessWidget {
   136	  final double size;
   137	  final bool showLabel;
   138	
   139	  const WeaverLogo({super.key, this.size = 36, this.showLabel = true});
   140	
   141	  @override
   142	  Widget build(BuildContext context) {
   143	    return Row(
   144	      mainAxisSize: MainAxisSize.min,
   145	      children: [
   146	        Container(
   147	          width: size,
   148	          height: size,
   149	          decoration: BoxDecoration(
   150	            gradient: const RadialGradient(
   151	              colors: [WeaverColors.accentDim, Color(0xFF0A0B0F)],
   152	              center: Alignment.center,
   153	              radius: 0.8,
   154	            ),
   155	            borderRadius: BorderRadius.circular(10),
   156	            border: Border.all(color: WeaverColors.accent.withOpacity(0.5)),
   157	          ),
   158	          child: Center(
   159	            child: Text('⟆', style: TextStyle(fontSize: size * 0.55, color: WeaverColors.accent)),
   160	          ),
   161	        ),
   162	        if (showLabel) ...[
   163	          const SizedBox(width: 10),
   164	          Text(
   165	            'Weaver',
   166	            style: TextStyle(
   167	              fontSize: size * 0.5,
   168	              fontWeight: FontWeight.w700,
   169	              color: WeaverColors.textPrimary,
   170	              letterSpacing: -0.5,
   171	            ),
   172	          ),
   173	        ],
   174	      ],
   175	    );
   176	  }
   177	}
```

## frontend/lib/widgets/common/common_widgets.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import '../../theme/colors.dart';
     3	import '../../models/models.dart';
     4	
     5	class StatusBadge extends StatelessWidget {
     6	  final AuthStatus status;
     7	  final bool compact;
     8	
     9	  const StatusBadge({super.key, required this.status, this.compact = false});
    10	
    11	  @override
    12	  Widget build(BuildContext context) {
    13	    final (color, label, icon) = switch (status) {
    14	      AuthStatus.connected => (WeaverColors.success, 'Connected', Icons.check_circle_rounded),
    15	      AuthStatus.disconnected => (WeaverColors.textMuted, 'Not Connected', Icons.circle_outlined),
    16	      AuthStatus.pending => (WeaverColors.warning, 'Connecting...', Icons.sync_rounded),
    17	      AuthStatus.error => (WeaverColors.error, 'Error', Icons.error_rounded),
    18	    };
    19	
    20	    if (compact) {
    21	      return Container(
    22	        width: 8,
    23	        height: 8,
    24	        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    25	      );
    26	    }
    27	
    28	    return Container(
    29	      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    30	      decoration: BoxDecoration(
    31	        color: color.withOpacity(0.12),
    32	        borderRadius: BorderRadius.circular(20),
    33	        border: Border.all(color: color.withOpacity(0.4), width: 1),
    34	      ),
    35	      child: Row(
    36	        mainAxisSize: MainAxisSize.min,
    37	        children: [
    38	          Icon(icon, size: 10, color: color),
    39	          const SizedBox(width: 4),
    40	          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    41	        ],
    42	      ),
    43	    );
    44	  }
    45	}
    46	
    47	class WorkflowStatusBadge extends StatelessWidget {
    48	  final WorkflowStatus status;
    49	
    50	  const WorkflowStatusBadge({super.key, required this.status});
    51	
    52	  @override
    53	  Widget build(BuildContext context) {
    54	    final (color, label) = switch (status) {
    55	      WorkflowStatus.idle => (WeaverColors.textMuted, 'Idle'),
    56	      WorkflowStatus.running => (WeaverColors.info, 'Running'),
    57	      WorkflowStatus.success => (WeaverColors.success, 'Success'),
    58	      WorkflowStatus.error => (WeaverColors.error, 'Error'),
    59	      WorkflowStatus.draft => (WeaverColors.warning, 'Draft'),
    60	    };
    61	
    62	    return Container(
    63	      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    64	      decoration: BoxDecoration(
    65	        color: color.withOpacity(0.12),
    66	        borderRadius: BorderRadius.circular(20),
    67	        border: Border.all(color: color.withOpacity(0.4), width: 1),
    68	      ),
    69	      child: Row(
    70	        mainAxisSize: MainAxisSize.min,
    71	        children: [
    72	          if (status == WorkflowStatus.running)
    73	            SizedBox(
    74	              width: 8, height: 8,
    75	              child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
    76	            )
    77	          else
    78	            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    79	          const SizedBox(width: 5),
    80	          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    81	        ],
    82	      ),
    83	    );
    84	  }
    85	}
    86	
    87	class WeaverCard extends StatefulWidget {
    88	  final Widget child;
    89	  final EdgeInsets? padding;
    90	  final VoidCallback? onTap;
    91	  final Color? borderColor;
    92	  final bool isSelected;
    93	
    94	  const WeaverCard({
    95	    super.key,
    96	    required this.child,
    97	    this.padding,
    98	    this.onTap,
    99	    this.borderColor,
   100	    this.isSelected = false,
   101	  });
   102	
   103	  @override
   104	  State<WeaverCard> createState() => _WeaverCardState();
   105	}
   106	
   107	class _WeaverCardState extends State<WeaverCard> {
   108	  bool _hovered = false;
   109	
   110	  @override
   111	  Widget build(BuildContext context) {
   112	    return MouseRegion(
   113	      onEnter: (_) => setState(() => _hovered = true),
   114	      onExit: (_) => setState(() => _hovered = false),
   115	      child: GestureDetector(
   116	        onTap: widget.onTap,
   117	        child: AnimatedContainer(
   118	          duration: const Duration(milliseconds: 150),
   119	          padding: widget.padding ?? const EdgeInsets.all(16),
   120	          decoration: BoxDecoration(
   121	            color: widget.isSelected
   122	                ? WeaverColors.accentGlow
   123	                : _hovered
   124	                    ? WeaverColors.cardHover
   125	                    : WeaverColors.card,
   126	            borderRadius: BorderRadius.circular(12),
   127	            border: Border.all(
   128	              color: widget.isSelected
   129	                  ? WeaverColors.accent
   130	                  : widget.borderColor ?? (_hovered ? WeaverColors.accent.withOpacity(0.3) : WeaverColors.cardBorder),
   131	              width: widget.isSelected ? 1.5 : 1,
   132	            ),
   133	          ),
   134	          child: widget.child,
   135	        ),
   136	      ),
   137	    );
   138	  }
   139	}
   140	
   141	class CategoryChip extends StatefulWidget {
   142	  final String label;
   143	  final bool isSelected;
   144	  final VoidCallback onTap;
   145	  final Color color;
   146	
   147	  const CategoryChip({super.key, required this.label, required this.isSelected, required this.onTap, required this.color});
   148	
   149	  @override
   150	  State<CategoryChip> createState() => _CategoryChipState();
   151	}
   152	
   153	class _CategoryChipState extends State<CategoryChip> {
   154	  bool _hovered = false;
   155	
   156	  @override
   157	  Widget build(BuildContext context) {
   158	    return MouseRegion(
   159	      onEnter: (_) => setState(() => _hovered = true),
   160	      onExit: (_) => setState(() => _hovered = false),
   161	      cursor: SystemMouseCursors.click,
   162	      child: GestureDetector(
   163	        onTap: widget.onTap,
   164	        child: AnimatedContainer(
   165	          duration: const Duration(milliseconds: 150),
   166	          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
   167	          decoration: BoxDecoration(
   168	            color: widget.isSelected ? widget.color.withOpacity(0.18) : (_hovered ? WeaverColors.cardHover : Colors.transparent),
   169	            borderRadius: BorderRadius.circular(20),
   170	            border: Border.all(
   171	              color: widget.isSelected ? widget.color : (_hovered ? WeaverColors.cardBorder : Colors.transparent),
   172	            ),
   173	          ),
   174	          child: Text(
   175	            widget.label,
   176	            style: TextStyle(
   177	              fontSize: 12,
   178	              fontWeight: FontWeight.w500,
   179	              color: widget.isSelected ? widget.color : WeaverColors.textMuted,
   180	            ),
   181	          ),
   182	        ),
   183	      ),
   184	    );
   185	  }
   186	}
   187	
   188	class SilkDivider extends StatelessWidget {
   189	  const SilkDivider({super.key});
   190	
   191	  @override
   192	  Widget build(BuildContext context) {
   193	    return Container(height: 1, color: WeaverColors.cardBorder.withOpacity(0.5));
   194	  }
   195	}
```

## frontend/lib/widgets/dashboard/dashboard_view.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:flutter_animate/flutter_animate.dart';
     3	import 'package:provider/provider.dart';
     4	import 'package:fl_chart/fl_chart.dart';
     5	import '../../providers/providers.dart';
     6	import '../../theme/colors.dart';
     7	import '../../models/models.dart';
     8	import '../common/common_widgets.dart';
     9	
    10	class DashboardView extends StatelessWidget {
    11	  const DashboardView({super.key});
    12	
    13	  @override
    14	  Widget build(BuildContext context) {
    15	    return SingleChildScrollView(
    16	      padding: const EdgeInsets.all(24),
    17	      child: Column(
    18	        crossAxisAlignment: CrossAxisAlignment.start,
    19	        children: [
    20	          _DashboardHeader(),
    21	          const SizedBox(height: 24),
    22	          // Stats row
    23	          const _StatsRow(),
    24	          const SizedBox(height: 24),
    25	          // Main grid
    26	          Row(
    27	            crossAxisAlignment: CrossAxisAlignment.start,
    28	            children: [
    29	              // Left column
    30	              Expanded(
    31	                flex: 3,
    32	                child: Column(
    33	                  children: const [
    34	                    _ToolStatusCard(),
    35	                    SizedBox(height: 20),
    36	                    _RecentActivityCard(),
    37	                  ],
    38	                ),
    39	              ),
    40	              const SizedBox(width: 20),
    41	              // Right column
    42	              Expanded(
    43	                flex: 2,
    44	                child: Column(
    45	                  children: const [
    46	                    _WorkflowsCard(),
    47	                    SizedBox(height: 20),
    48	                    _AgentCard(),
    49	                  ],
    50	                ),
    51	              ),
    52	            ],
    53	          ),
    54	        ],
    55	      ),
    56	    );
    57	  }
    58	}
    59	
    60	class _DashboardHeader extends StatelessWidget {
    61	  @override
    62	  Widget build(BuildContext context) {
    63	    final hour = DateTime.now().hour;
    64	    final greeting = hour < 12
    65	        ? 'Good morning'
    66	        : hour < 17
    67	            ? 'Good afternoon'
    68	            : 'Good evening';
    69	    return Row(
    70	      children: [
    71	        Column(
    72	          crossAxisAlignment: CrossAxisAlignment.start,
    73	          children: [
    74	            Text(greeting,
    75	                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    76	                    color: WeaverColors.textPrimary,
    77	                    fontWeight: FontWeight.w700)),
    78	            const Text('Your agentic workspace is ready',
    79	                style: TextStyle(color: WeaverColors.textMuted, fontSize: 14)),
    80	          ],
    81	        ),
    82	        const Spacer(),
    83	        ElevatedButton.icon(
    84	          onPressed: () {
    85	            Provider.of<ChatProvider>(context, listen: false).newChat();
    86	            Provider.of<AppState>(context, listen: false).setNavIndex(0);
    87	          },
    88	          icon: const Icon(Icons.add_rounded, size: 16),
    89	          label: const Text('New Chat'),
    90	        ),
    91	        const SizedBox(width: 8),
    92	        OutlinedButton.icon(
    93	          onPressed: () =>
    94	              Provider.of<AppState>(context, listen: false).setNavIndex(2),
    95	          icon: const Icon(Icons.account_tree_rounded, size: 14),
    96	          label: const Text('Workflows'),
    97	        ),
    98	      ],
    99	    );
   100	  }
   101	}
   102	
   103	class _StatsRow extends StatelessWidget {
   104	  const _StatsRow();
   105	
   106	  @override
   107	  Widget build(BuildContext context) {
   108	    return Consumer3<ChatProvider, ToolsProvider, WorkflowsProvider>(
   109	      builder: (context, chatProv, toolsProv, wfProv, _) {
   110	        final stats = [
   111	          _StatData(
   112	              value: '${chatProv.sessions.length}',
   113	              label: 'Active Chats',
   114	              icon: Icons.chat_bubble_rounded,
   115	              color: WeaverColors.accent),
   116	          _StatData(
   117	              value: '${toolsProv.connectedCount}',
   118	              label: 'Connected Tools',
   119	              icon: Icons.extension_rounded,
   120	              color: WeaverColors.success),
   121	          _StatData(
   122	              value: '${wfProv.totalWorkflowCount}',
   123	              label: 'Workflows',
   124	              icon: Icons.account_tree_rounded,
   125	              color: WeaverColors.info),
   126	          _StatData(
   127	              value: '${wfProv.activeWorkflowCount}',
   128	              label: 'Running Now',
   129	              icon: Icons.bolt_rounded,
   130	              color: WeaverColors.warning),
   131	        ];
   132	        return Row(
   133	          children: stats
   134	              .asMap()
   135	              .entries
   136	              .map((e) => Expanded(
   137	                    child: _StatCard(data: e.value)
   138	                        .animate()
   139	                        .fadeIn(delay: Duration(milliseconds: e.key * 80))
   140	                        .slideY(
   141	                            begin: 0.1,
   142	                            end: 0,
   143	                            delay: Duration(milliseconds: e.key * 80)),
   144	                  ))
   145	              .toList()
   146	              .expand((w) => [w, const SizedBox(width: 16)])
   147	              .toList()
   148	            ..removeLast(),
   149	        );
   150	      },
   151	    );
   152	  }
   153	}
   154	
   155	class _StatData {
   156	  final String value;
   157	  final String label;
   158	  final IconData icon;
   159	  final Color color;
   160	  const _StatData(
   161	      {required this.value,
   162	      required this.label,
   163	      required this.icon,
   164	      required this.color});
   165	}
   166	
   167	class _StatCard extends StatelessWidget {
   168	  final _StatData data;
   169	  const _StatCard({required this.data});
   170	
   171	  @override
   172	  Widget build(BuildContext context) {
   173	    return Container(
   174	      padding: const EdgeInsets.all(18),
   175	      decoration: BoxDecoration(
   176	        color: WeaverColors.card,
   177	        borderRadius: BorderRadius.circular(14),
   178	        border: Border.all(color: WeaverColors.cardBorder),
   179	        gradient: LinearGradient(
   180	          begin: Alignment.topLeft,
   181	          end: Alignment.bottomRight,
   182	          colors: [WeaverColors.card, data.color.withOpacity(0.04)],
   183	        ),
   184	      ),
   185	      child: Row(
   186	        children: [
   187	          Container(
   188	            width: 44,
   189	            height: 44,
   190	            decoration: BoxDecoration(
   191	              color: data.color.withOpacity(0.12),
   192	              borderRadius: BorderRadius.circular(10),
   193	            ),
   194	            child: Center(child: Icon(data.icon, color: data.color, size: 22)),
   195	          ),
   196	          const SizedBox(width: 14),
   197	          Column(
   198	            crossAxisAlignment: CrossAxisAlignment.start,
   199	            children: [
   200	              Text(data.value,
   201	                  style: TextStyle(
   202	                      fontSize: 26,
   203	                      fontWeight: FontWeight.w700,
   204	                      color: data.color,
   205	                      height: 1)),
   206	              const SizedBox(height: 3),
   207	              Text(data.label,
   208	                  style: const TextStyle(
   209	                      fontSize: 12, color: WeaverColors.textMuted)),
   210	            ],
   211	          ),
   212	        ],
   213	      ),
   214	    );
   215	  }
   216	}
   217	
   218	class _ToolStatusCard extends StatelessWidget {
   219	  const _ToolStatusCard();
   220	
   221	  @override
   222	  Widget build(BuildContext context) {
   223	    return Consumer<ToolsProvider>(
   224	      builder: (context, provider, _) {
   225	        return Container(
   226	          padding: const EdgeInsets.all(20),
   227	          decoration: BoxDecoration(
   228	            color: WeaverColors.card,
   229	            borderRadius: BorderRadius.circular(14),
   230	            border: Border.all(color: WeaverColors.cardBorder),
   231	          ),
   232	          child: Column(
   233	            crossAxisAlignment: CrossAxisAlignment.start,
   234	            children: [
   235	              Row(
   236	                children: [
   237	                  const Icon(Icons.extension_rounded,
   238	                      size: 18, color: WeaverColors.accent),
   239	                  const SizedBox(width: 8),
   240	                  const Text('Tool Status',
   241	                      style: TextStyle(
   242	                          fontSize: 15,
   243	                          fontWeight: FontWeight.w600,
   244	                          color: WeaverColors.textPrimary)),
   245	                  const Spacer(),
   246	                  TextButton(
   247	                    onPressed: () =>
   248	                        Provider.of<AppState>(context, listen: false)
   249	                            .setRightPanelTab(0),
   250	                    child: const Text('Manage', style: TextStyle(fontSize: 12)),
   251	                  ),
   252	                ],
   253	              ),
   254	              const SizedBox(height: 16),
   255	              ...provider.tools.map((t) => _ToolStatusRow(tool: t)),
   256	            ],
   257	          ),
   258	        );
   259	      },
   260	    );
   261	  }
   262	}
   263	
   264	class _ToolStatusRow extends StatelessWidget {
   265	  final ToolModel tool;
   266	  const _ToolStatusRow({required this.tool});
   267	
   268	  @override
   269	  Widget build(BuildContext context) {
   270	    return Padding(
   271	      padding: const EdgeInsets.only(bottom: 10),
   272	      child: Row(
   273	        children: [
   274	          Text(tool.logoEmoji, style: const TextStyle(fontSize: 16)),
   275	          const SizedBox(width: 10),
   276	          Expanded(
   277	              child: Text(tool.name,
   278	                  style: const TextStyle(
   279	                      fontSize: 13, color: WeaverColors.textSecondary))),
   280	          StatusBadge(status: tool.authStatus),
   281	          const SizedBox(width: 8),
   282	          Container(
   283	            width: 80,
   284	            height: 4,
   285	            decoration: BoxDecoration(
   286	              color: WeaverColors.surface,
   287	              borderRadius: BorderRadius.circular(2),
   288	            ),
   289	            child: FractionallySizedBox(
   290	              alignment: Alignment.centerLeft,
   291	              widthFactor: tool.usageCount / 400,
   292	              child: Container(
   293	                decoration: BoxDecoration(
   294	                  color: tool.categoryColor.withOpacity(0.7),
   295	                  borderRadius: BorderRadius.circular(2),
   296	                ),
   297	              ),
   298	            ),
   299	          ),
   300	          const SizedBox(width: 6),
   301	          SizedBox(
   302	            width: 32,
   303	            child: Text('${tool.usageCount}',
   304	                style: const TextStyle(
   305	                    fontSize: 10, color: WeaverColors.textMuted),
   306	                textAlign: TextAlign.right),
   307	          ),
   308	        ],
   309	      ),
   310	    );
   311	  }
   312	}
   313	
   314	class _RecentActivityCard extends StatelessWidget {
   315	  const _RecentActivityCard();
   316	
   317	  static const _activities = [
   318	    (
   319	      icon: '✉️',
   320	      text: 'Gmail: Fetched 8 emails',
   321	      time: '10m ago',
   322	      color: WeaverColors.cloudColor
   323	    ),
   324	    (
   325	      icon: '🔍',
   326	      text: 'Web Search: Queried "AI frameworks 2025"',
   327	      time: '25m ago',
   328	      color: WeaverColors.accentBright
   329	    ),
   330	    (
   331	      icon: '⏰',
   332	      text: 'Workflow "Morning Digest" ran successfully',
   333	      time: '4h ago',
   334	      color: WeaverColors.success
   335	    ),
   336	    (
   337	      icon: '🗂️',
   338	      text: 'Drive Backup: Copied 3 files to /Backups',
   339	      time: '4h 5m ago',
   340	      color: WeaverColors.cloudColor
   341	    ),
   342	    (
   343	      icon: '🗄️',
   344	      text: 'Filesystem: Listed /Projects directory',
   345	      time: '5h ago',
   346	      color: WeaverColors.filesColor
   347	    ),
   348	  ];
   349	
   350	  @override
   351	  Widget build(BuildContext context) {
   352	    return Container(
   353	      padding: const EdgeInsets.all(20),
   354	      decoration: BoxDecoration(
   355	        color: WeaverColors.card,
   356	        borderRadius: BorderRadius.circular(14),
   357	        border: Border.all(color: WeaverColors.cardBorder),
   358	      ),
   359	      child: Column(
   360	        crossAxisAlignment: CrossAxisAlignment.start,
   361	        children: [
   362	          const Row(
   363	            children: [
   364	              Icon(Icons.timeline_rounded,
   365	                  size: 18, color: WeaverColors.accent),
   366	              SizedBox(width: 8),
   367	              Text('Recent Activity',
   368	                  style: TextStyle(
   369	                      fontSize: 15,
   370	                      fontWeight: FontWeight.w600,
   371	                      color: WeaverColors.textPrimary)),
   372	            ],
   373	          ),
   374	          const SizedBox(height: 16),
   375	          ..._activities.asMap().entries.map((e) => _ActivityRow(
   376	                icon: e.value.icon,
   377	                text: e.value.text,
   378	                time: e.value.time,
   379	                color: e.value.color,
   380	                isLast: e.key == _activities.length - 1,
   381	              )),
   382	        ],
   383	      ),
   384	    );
   385	  }
   386	}
   387	
   388	class _ActivityRow extends StatelessWidget {
   389	  final String icon;
   390	  final String text;
   391	  final String time;
   392	  final Color color;
   393	  final bool isLast;
   394	
   395	  const _ActivityRow(
   396	      {required this.icon,
   397	      required this.text,
   398	      required this.time,
   399	      required this.color,
   400	      required this.isLast});
   401	
   402	  @override
   403	  Widget build(BuildContext context) {
   404	    return Row(
   405	      crossAxisAlignment: CrossAxisAlignment.start,
   406	      children: [
   407	        Column(
   408	          children: [
   409	            Container(
   410	              width: 30,
   411	              height: 30,
   412	              decoration: BoxDecoration(
   413	                  color: color.withOpacity(0.1), shape: BoxShape.circle),
   414	              child: Center(
   415	                  child: Text(icon, style: const TextStyle(fontSize: 13))),
   416	            ),
   417	            if (!isLast)
   418	              Container(width: 1, height: 18, color: WeaverColors.cardBorder),
   419	          ],
   420	        ),
   421	        const SizedBox(width: 12),
   422	        Expanded(
   423	          child: Padding(
   424	            padding: const EdgeInsets.only(top: 6, bottom: 10),
   425	            child: Row(
   426	              children: [
   427	                Expanded(
   428	                    child: Text(text,
   429	                        style: const TextStyle(
   430	                            fontSize: 12, color: WeaverColors.textSecondary))),
   431	                const SizedBox(width: 8),
   432	                Text(time,
   433	                    style: const TextStyle(
   434	                        fontSize: 11, color: WeaverColors.textMuted)),
   435	              ],
   436	            ),
   437	          ),
   438	        ),
   439	      ],
   440	    );
   441	  }
   442	}
   443	
   444	class _WorkflowsCard extends StatelessWidget {
   445	  const _WorkflowsCard();
   446	
   447	  @override
   448	  Widget build(BuildContext context) {
   449	    return Consumer<WorkflowsProvider>(
   450	      builder: (context, wfProv, _) {
   451	        return Container(
   452	          padding: const EdgeInsets.all(20),
   453	          decoration: BoxDecoration(
   454	            color: WeaverColors.card,
   455	            borderRadius: BorderRadius.circular(14),
   456	            border: Border.all(color: WeaverColors.cardBorder),
   457	          ),
   458	          child: Column(
   459	            crossAxisAlignment: CrossAxisAlignment.start,
   460	            children: [
   461	              Row(
   462	                children: [
   463	                  const Icon(Icons.account_tree_rounded,
   464	                      size: 18, color: WeaverColors.accent),
   465	                  const SizedBox(width: 8),
   466	                  const Text('Workflows',
   467	                      style: TextStyle(
   468	                          fontSize: 15,
   469	                          fontWeight: FontWeight.w600,
   470	                          color: WeaverColors.textPrimary)),
   471	                  const Spacer(),
   472	                  TextButton(
   473	                    onPressed: () =>
   474	                        Provider.of<AppState>(context, listen: false)
   475	                            .setNavIndex(2),
   476	                    child:
   477	                        const Text('View All', style: TextStyle(fontSize: 12)),
   478	                  ),
   479	                ],
   480	              ),
   481	              const SizedBox(height: 14),
   482	              ...wfProv.workflows
   483	                  .take(4)
   484	                  .map((wf) => _WorkflowRow(workflow: wf, wfProv: wfProv)),
   485	            ],
   486	          ),
   487	        );
   488	      },
   489	    );
   490	  }
   491	}
   492	
   493	class _WorkflowRow extends StatelessWidget {
   494	  final WorkflowModel workflow;
   495	  final WorkflowsProvider wfProv;
   496	  const _WorkflowRow({required this.workflow, required this.wfProv});
   497	
   498	  @override
   499	  Widget build(BuildContext context) {
   500	    return GestureDetector(
   501	      onTap: () {
   502	        wfProv.setOpenWorkflow(workflow.id);
   503	        Provider.of<AppState>(context, listen: false).setNavIndex(2);
   504	      },
   505	      child: Container(
   506	        margin: const EdgeInsets.only(bottom: 8),
   507	        padding: const EdgeInsets.all(12),
   508	        decoration: BoxDecoration(
   509	          color: WeaverColors.surface,
   510	          borderRadius: BorderRadius.circular(10),
   511	          border: Border.all(color: WeaverColors.cardBorder),
   512	        ),
   513	        child: Row(
   514	          children: [
   515	            Expanded(
   516	              child: Column(
   517	                crossAxisAlignment: CrossAxisAlignment.start,
   518	                children: [
   519	                  Text(workflow.name,
   520	                      style: const TextStyle(
   521	                          fontSize: 12,
   522	                          fontWeight: FontWeight.w500,
   523	                          color: WeaverColors.textPrimary),
   524	                      maxLines: 1,
   525	                      overflow: TextOverflow.ellipsis),
   526	                  const SizedBox(height: 2),
   527	                  Text(
   528	                      '${workflow.nodes.length} nodes · ${workflow.runCount} runs',
   529	                      style: const TextStyle(
   530	                          fontSize: 11, color: WeaverColors.textMuted)),
   531	                ],
   532	              ),
   533	            ),
   534	            WorkflowStatusBadge(status: workflow.status),
   535	          ],
   536	        ),
   537	      ),
   538	    );
   539	  }
   540	}
   541	
   542	class _AgentCard extends StatelessWidget {
   543	  const _AgentCard();
   544	
   545	  @override
   546	  Widget build(BuildContext context) {
   547	    return Consumer<ModelProvider>(
   548	      builder: (context, modelProv, _) => Container(
   549	        padding: const EdgeInsets.all(20),
   550	        decoration: BoxDecoration(
   551	          color: WeaverColors.card,
   552	          borderRadius: BorderRadius.circular(14),
   553	          border: Border.all(color: WeaverColors.cardBorder),
   554	          gradient: const LinearGradient(
   555	            begin: Alignment.topLeft,
   556	            end: Alignment.bottomRight,
   557	            colors: [WeaverColors.card, Color(0xFF1E1A2E)],
   558	          ),
   559	        ),
   560	        child: Column(
   561	          crossAxisAlignment: CrossAxisAlignment.start,
   562	          children: [
   563	            const Row(
   564	              children: [
   565	                Icon(Icons.psychology_rounded,
   566	                    size: 18, color: WeaverColors.accent),
   567	                SizedBox(width: 8),
   568	                Text('Active Agent',
   569	                    style: TextStyle(
   570	                        fontSize: 15,
   571	                        fontWeight: FontWeight.w600,
   572	                        color: WeaverColors.textPrimary)),
   573	              ],
   574	            ),
   575	            const SizedBox(height: 16),
   576	            Container(
   577	              padding: const EdgeInsets.all(14),
   578	              decoration: BoxDecoration(
   579	                color: WeaverColors.surface,
   580	                borderRadius: BorderRadius.circular(10),
   581	                border: Border.all(color: WeaverColors.accent.withOpacity(0.2)),
   582	              ),
   583	              child: Column(
   584	                crossAxisAlignment: CrossAxisAlignment.start,
   585	                children: [
   586	                  Row(
   587	                    children: [
   588	                      Container(
   589	                        width: 8,
   590	                        height: 8,
   591	                        decoration: const BoxDecoration(
   592	                            color: WeaverColors.success,
   593	                            shape: BoxShape.circle),
   594	                      ),
   595	                      const SizedBox(width: 8),
   596	                      const Text('Weaver Agent',
   597	                          style: TextStyle(
   598	                              fontSize: 13,
   599	                              fontWeight: FontWeight.w600,
   600	                              color: WeaverColors.textPrimary)),
   601	                    ],
   602	                  ),
   603	                  const SizedBox(height: 8),
   604	                  Text(modelProv.modelName,
   605	                      style: const TextStyle(
   606	                          fontSize: 12,
   607	                          color: WeaverColors.accent,
   608	                          fontWeight: FontWeight.w500)),
   609	                  const SizedBox(height: 4),
   610	                  const Text(
   611	                      'Custom model configured in the right sidebar model panel.',
   612	                      style: TextStyle(
   613	                          fontSize: 11, color: WeaverColors.textMuted),
   614	                      maxLines: 2),
   615	                  const SizedBox(height: 8),
   616	                  Row(
   617	                    children: [
   618	                      const Icon(Icons.memory_rounded,
   619	                          size: 12, color: WeaverColors.textMuted),
   620	                      const SizedBox(width: 4),
   621	                      Text('${modelProv.maxTokens} max tokens',
   622	                          style: const TextStyle(
   623	                              fontSize: 11, color: WeaverColors.textMuted)),
   624	                      const SizedBox(width: 10),
   625	                      const Icon(Icons.thermostat_rounded,
   626	                          size: 12, color: WeaverColors.textMuted),
   627	                      const SizedBox(width: 4),
   628	                      Text('T: ${modelProv.temperature.toStringAsFixed(1)}',
   629	                          style: const TextStyle(
   630	                              fontSize: 11, color: WeaverColors.textMuted)),
   631	                    ],
   632	                  ),
   633	                ],
   634	              ),
   635	            ),
   636	            const SizedBox(height: 12),
   637	            SizedBox(
   638	              width: double.infinity,
   639	              child: OutlinedButton.icon(
   640	                onPressed: () => Provider.of<AppState>(context, listen: false)
   641	                    .setRightPanelTab(2),
   642	                icon: const Icon(Icons.tune_rounded, size: 13),
   643	                label: const Text('Configure', style: TextStyle(fontSize: 12)),
   644	              ),
   645	            ),
   646	          ],
   647	        ),
   648	      ),
   649	    );
   650	  }
   651	}
```

## frontend/lib/widgets/shell/app_shell.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:provider/provider.dart';
     3	import '../../providers/providers.dart';
     4	import '../../theme/colors.dart';
     5	import 'left_sidebar.dart';
     6	import 'right_sidebar.dart';
     7	import 'weaver_tab_bar.dart';
     8	import '../chat/chat_view.dart';
     9	import '../dashboard/dashboard_view.dart';
    10	import '../../screens/workflows_screen.dart';
    11	import '../../screens/settings_screen.dart';
    12	
    13	class AppShell extends StatelessWidget {
    14	  const AppShell({super.key});
    15	
    16	  @override
    17	  Widget build(BuildContext context) {
    18	    return Scaffold(
    19	      backgroundColor: WeaverColors.background,
    20	      body: Row(
    21	        children: [
    22	          const LeftSidebar(),
    23	          Expanded(
    24	            child: Column(
    25	              children: [
    26	                const WeaverTabBar(),
    27	                Expanded(
    28	                  child: Consumer<AppState>(
    29	                    builder: (context, appState, _) {
    30	                      return IndexedStack(
    31	                        index: appState.navIndex,
    32	                        children: const [
    33	                          ChatView(),
    34	                          DashboardView(),
    35	                          WorkflowsScreen(),
    36	                          SettingsScreen(),
    37	                        ],
    38	                      );
    39	                    },
    40	                  ),
    41	                ),
    42	              ],
    43	            ),
    44	          ),
    45	          const RightSidebar(),
    46	        ],
    47	      ),
    48	    );
    49	  }
    50	}
```

## frontend/lib/widgets/shell/left_sidebar.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:provider/provider.dart';
     3	import '../../providers/providers.dart';
     4	import '../../theme/colors.dart';
     5	import '../../models/models.dart';
     6	import '../common/animated_widgets.dart';
     7	
     8	class LeftSidebar extends StatelessWidget {
     9	  const LeftSidebar({super.key});
    10	
    11	  @override
    12	  Widget build(BuildContext context) {
    13	    return Consumer<AppState>(
    14	      builder: (context, appState, _) {
    15	        return Container(
    16	          width: appState.leftSidebarOpen ? 260 : 64,
    17	          decoration: const BoxDecoration(
    18	            color: WeaverColors.surface,
    19	            border: Border(right: BorderSide(color: WeaverColors.cardBorder)),
    20	          ),
    21	          child: Column(
    22	            children: [
    23	              // Logo
    24	              _LogoSection(collapsed: !appState.leftSidebarOpen, onToggle: appState.toggleLeftSidebar),
    25	              // Nav rail items
    26	              _NavSection(collapsed: !appState.leftSidebarOpen, appState: appState),
    27	              const SizedBox(height: 8),
    28	              Container(height: 1, color: WeaverColors.cardBorder),
    29	              // Chat list (only when expanded)
    30	              if (appState.leftSidebarOpen)
    31	                const Expanded(child: _ChatListSection()),
    32	            ],
    33	          ),
    34	        );
    35	      },
    36	    );
    37	  }
    38	}
    39	
    40	class _LogoSection extends StatelessWidget {
    41	  final bool collapsed;
    42	  final VoidCallback onToggle;
    43	
    44	  const _LogoSection({required this.collapsed, required this.onToggle});
    45	
    46	  @override
    47	  Widget build(BuildContext context) {
    48	    return GestureDetector(
    49	      onTap: onToggle,
    50	      child: Container(
    51	        height: 56,
    52	        padding: collapsed ? const EdgeInsets.symmetric(horizontal: 14) : const EdgeInsets.symmetric(horizontal: 16),
    53	        alignment: collapsed ? Alignment.center : Alignment.centerLeft,
    54	        child: Row(
    55	          children: [
    56	            WeaverLogo(size: 32, showLabel: !collapsed),
    57	          ],
    58	        ),
    59	      ),
    60	    );
    61	  }
    62	}
    63	
    64	class _NavSection extends StatelessWidget {
    65	  final bool collapsed;
    66	  final AppState appState;
    67	
    68	  const _NavSection({required this.collapsed, required this.appState});
    69	
    70	  @override
    71	  Widget build(BuildContext context) {
    72	    final items = [
    73	      (icon: Icons.chat_bubble_rounded, label: 'Chats', index: 0),
    74	      (icon: Icons.dashboard_rounded, label: 'Dashboard', index: 1),
    75	      (icon: Icons.account_tree_rounded, label: 'Workflows', index: 2),
    76	      (icon: Icons.settings_rounded, label: 'Settings', index: 3),
    77	    ];
    78	
    79	    return Column(
    80	      children: items.map((item) => _NavItem(
    81	        icon: item.icon,
    82	        label: item.label,
    83	        index: item.index,
    84	        collapsed: collapsed,
    85	        appState: appState,
    86	      )).toList(),
    87	    );
    88	  }
    89	}
    90	
    91	class _NavItem extends StatefulWidget {
    92	  final IconData icon;
    93	  final String label;
    94	  final int index;
    95	  final bool collapsed;
    96	  final AppState appState;
    97	
    98	  const _NavItem({required this.icon, required this.label, required this.index, required this.collapsed, required this.appState});
    99	
   100	  @override
   101	  State<_NavItem> createState() => _NavItemState();
   102	}
   103	
   104	class _NavItemState extends State<_NavItem> {
   105	  bool _hovered = false;
   106	
   107	  @override
   108	  Widget build(BuildContext context) {
   109	    final selected = widget.appState.navIndex == widget.index;
   110	    return MouseRegion(
   111	      onEnter: (_) => setState(() => _hovered = true),
   112	      onExit: (_) => setState(() => _hovered = false),
   113	      cursor: SystemMouseCursors.click,
   114	      child: Tooltip(
   115	        message: widget.collapsed ? widget.label : '',
   116	        child: GestureDetector(
   117	          onTap: () => widget.appState.setNavIndex(widget.index),
   118	          child: AnimatedContainer(
   119	            duration: const Duration(milliseconds: 150),
   120	            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
   121	            padding: EdgeInsets.symmetric(
   122	              horizontal: widget.collapsed ? 0 : 12,
   123	              vertical: 10,
   124	            ),
   125	            decoration: BoxDecoration(
   126	              color: selected
   127	                  ? WeaverColors.accentGlow
   128	                  : _hovered
   129	                      ? WeaverColors.cardHover
   130	                      : Colors.transparent,
   131	              borderRadius: BorderRadius.circular(8),
   132	              border: selected ? Border.all(color: WeaverColors.accent.withOpacity(0.3)) : null,
   133	            ),
   134	            child: widget.collapsed
   135	                ? Center(child: Icon(widget.icon, color: selected ? WeaverColors.accent : WeaverColors.textMuted, size: 20))
   136	                : Row(
   137	                    children: [
   138	                      Icon(widget.icon, color: selected ? WeaverColors.accent : WeaverColors.textMuted, size: 18),
   139	                      const SizedBox(width: 10),
   140	                      Text(
   141	                        widget.label,
   142	                        style: TextStyle(
   143	                          fontSize: 14,
   144	                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
   145	                          color: selected ? WeaverColors.accent : WeaverColors.textSecondary,
   146	                        ),
   147	                      ),
   148	                    ],
   149	                  ),
   150	          ),
   151	        ),
   152	      ),
   153	    );
   154	  }
   155	}
   156	
   157	// ── Chat List Section ──────────────────────────────────────────────────────────
   158	class _ChatListSection extends StatelessWidget {
   159	  const _ChatListSection();
   160	
   161	  @override
   162	  Widget build(BuildContext context) {
   163	    return Consumer2<ChatProvider, AppState>(
   164	      builder: (context, chatProvider, appState, _) {
   165	        final sessions = chatProvider.sessions;
   166	        final pinned = sessions.where((s) => s.isPinned).toList();
   167	        final today = sessions.where((s) {
   168	          final diff = DateTime.now().difference(s.updatedAt);
   169	          return !s.isPinned && diff.inHours < 24;
   170	        }).toList();
   171	        final older = sessions.where((s) {
   172	          final diff = DateTime.now().difference(s.updatedAt);
   173	          return !s.isPinned && diff.inHours >= 24;
   174	        }).toList();
   175	
   176	        return Column(
   177	          children: [
   178	            // New chat button
   179	            Padding(
   180	              padding: const EdgeInsets.all(12),
   181	              child: SizedBox(
   182	                width: double.infinity,
   183	                child: ElevatedButton.icon(
   184	                  onPressed: () {
   185	                    chatProvider.newChat();
   186	                    appState.setNavIndex(0);
   187	                  },
   188	                  icon: const Icon(Icons.add_rounded, size: 16),
   189	                  label: const Text('New Chat'),
   190	                  style: ElevatedButton.styleFrom(
   191	                    padding: const EdgeInsets.symmetric(vertical: 10),
   192	                  ),
   193	                ),
   194	              ),
   195	            ),
   196	            Expanded(
   197	              child: ListView(
   198	                padding: const EdgeInsets.only(bottom: 12),
   199	                children: [
   200	                  if (pinned.isNotEmpty) ...[
   201	                    _SectionLabel('Pinned'),
   202	                    ...pinned.map((s) => _ChatSessionTile(session: s)),
   203	                  ],
   204	                  if (today.isNotEmpty) ...[
   205	                    _SectionLabel('Today'),
   206	                    ...today.map((s) => _ChatSessionTile(session: s)),
   207	                  ],
   208	                  if (older.isNotEmpty) ...[
   209	                    _SectionLabel('Earlier'),
   210	                    ...older.map((s) => _ChatSessionTile(session: s)),
   211	                  ],
   212	                ],
   213	              ),
   214	            ),
   215	          ],
   216	        );
   217	      },
   218	    );
   219	  }
   220	}
   221	
   222	class _SectionLabel extends StatelessWidget {
   223	  final String label;
   224	  const _SectionLabel(this.label);
   225	
   226	  @override
   227	  Widget build(BuildContext context) {
   228	    return Padding(
   229	      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
   230	      child: Text(
   231	        label.toUpperCase(),
   232	        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: WeaverColors.textDisabled, letterSpacing: 1),
   233	      ),
   234	    );
   235	  }
   236	}
   237	
   238	class _ChatSessionTile extends StatefulWidget {
   239	  final ChatSession session;
   240	  const _ChatSessionTile({required this.session});
   241	
   242	  @override
   243	  State<_ChatSessionTile> createState() => _ChatSessionTileState();
   244	}
   245	
   246	class _ChatSessionTileState extends State<_ChatSessionTile> {
   247	  bool _hovered = false;
   248	
   249	  @override
   250	  Widget build(BuildContext context) {
   251	    return Consumer2<ChatProvider, AppState>(
   252	      builder: (context, chatProv, appState, _) {
   253	        final isActive = chatProv.activeSessionId == widget.session.id;
   254	        return MouseRegion(
   255	          onEnter: (_) => setState(() => _hovered = true),
   256	          onExit: (_) => setState(() => _hovered = false),
   257	          cursor: SystemMouseCursors.click,
   258	          child: GestureDetector(
   259	            onTap: () {
   260	              chatProv.openSession(widget.session.id);
   261	              appState.setNavIndex(0);
   262	            },
   263	            child: AnimatedContainer(
   264	              duration: const Duration(milliseconds: 120),
   265	              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
   266	              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
   267	              decoration: BoxDecoration(
   268	                color: isActive
   269	                    ? WeaverColors.accentGlow
   270	                    : _hovered
   271	                        ? WeaverColors.cardHover
   272	                        : Colors.transparent,
   273	                borderRadius: BorderRadius.circular(8),
   274	                border: isActive ? Border.all(color: WeaverColors.accent.withOpacity(0.3)) : null,
   275	              ),
   276	              child: Row(
   277	                children: [
   278	                  Expanded(
   279	                    child: Column(
   280	                      crossAxisAlignment: CrossAxisAlignment.start,
   281	                      children: [
   282	                        Text(
   283	                          widget.session.title,
   284	                          style: TextStyle(
   285	                            fontSize: 13,
   286	                            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
   287	                            color: isActive ? WeaverColors.textPrimary : WeaverColors.textSecondary,
   288	                          ),
   289	                          maxLines: 1,
   290	                          overflow: TextOverflow.ellipsis,
   291	                        ),
   292	                        const SizedBox(height: 2),
   293	                        Row(
   294	                          children: [
   295	                            Text(
   296	                              _formatTime(widget.session.updatedAt),
   297	                              style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted),
   298	                            ),
   299	                            if (widget.session.workflowCount > 0) ...[
   300	                              const SizedBox(width: 6),
   301	                              Container(
   302	                                width: 4, height: 4,
   303	                                decoration: const BoxDecoration(color: WeaverColors.textDisabled, shape: BoxShape.circle),
   304	                              ),
   305	                              const SizedBox(width: 6),
   306	                              Icon(Icons.account_tree_rounded, size: 11, color: WeaverColors.accent.withOpacity(0.6)),
   307	                              const SizedBox(width: 2),
   308	                              Text(
   309	                                '${widget.session.workflowCount}',
   310	                                style: TextStyle(fontSize: 11, color: WeaverColors.accent.withOpacity(0.6)),
   311	                              ),
   312	                            ],
   313	                          ],
   314	                        ),
   315	                      ],
   316	                    ),
   317	                  ),
   318	                  if (widget.session.isPinned)
   319	                    const Icon(Icons.push_pin_rounded, size: 12, color: WeaverColors.accent),
   320	                ],
   321	              ),
   322	            ),
   323	          ),
   324	        );
   325	      },
   326	    );
   327	  }
   328	
   329	  String _formatTime(DateTime dt) {
   330	    final diff = DateTime.now().difference(dt);
   331	    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
   332	    if (diff.inHours < 24) return '${diff.inHours}h ago';
   333	    return '${diff.inDays}d ago';
   334	  }
   335	}
```

## frontend/lib/widgets/shell/right_sidebar.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:provider/provider.dart';
     3	import '../../providers/providers.dart';
     4	import '../../theme/colors.dart';
     5	import '../../models/models.dart';
     6	import '../tool_card/tool_card.dart';
     7	import '../common/common_widgets.dart';
     8	import '../workflow/workflow_list_panel.dart';
     9	import '../chat/model_panel.dart';
    10	
    11	class RightSidebar extends StatelessWidget {
    12	  const RightSidebar({super.key});
    13	
    14	  @override
    15	  Widget build(BuildContext context) {
    16	    return Consumer<AppState>(
    17	      builder: (context, appState, _) {
    18	        if (!appState.rightSidebarOpen) return const SizedBox.shrink();
    19	        return Container(
    20	          width: 320,
    21	          decoration: const BoxDecoration(
    22	            color: WeaverColors.surface,
    23	            border: Border(left: BorderSide(color: WeaverColors.cardBorder)),
    24	          ),
    25	          child: Column(
    26	            children: [
    27	              // Panel tab bar
    28	              _RightSidebarTabBar(appState: appState),
    29	              const SizedBox(height: 1),
    30	              // Content
    31	              Expanded(
    32	                child: IndexedStack(
    33	                  index: appState.rightPanelTab,
    34	                  children: const [
    35	                    _ToolsPanel(),
    36	                    WorkflowListPanel(),
    37	                    ModelPanel(),
    38	                  ],
    39	                ),
    40	              ),
    41	            ],
    42	          ),
    43	        );
    44	      },
    45	    );
    46	  }
    47	}
    48	
    49	class _RightSidebarTabBar extends StatelessWidget {
    50	  final AppState appState;
    51	  const _RightSidebarTabBar({required this.appState});
    52	
    53	  @override
    54	  Widget build(BuildContext context) {
    55	    return Container(
    56	      height: 44,
    57	      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    58	      decoration: const BoxDecoration(
    59	        border: Border(bottom: BorderSide(color: WeaverColors.cardBorder)),
    60	      ),
    61	      child: Row(
    62	        children: [
    63	          _TabButton(
    64	              label: 'Tools',
    65	              icon: Icons.extension_rounded,
    66	              index: 0,
    67	              current: appState.rightPanelTab,
    68	              onTap: () => appState.setRightPanelTab(0)),
    69	          const SizedBox(width: 4),
    70	          _TabButton(
    71	              label: 'Workflows',
    72	              icon: Icons.account_tree_rounded,
    73	              index: 1,
    74	              current: appState.rightPanelTab,
    75	              onTap: () => appState.setRightPanelTab(1)),
    76	          const SizedBox(width: 4),
    77	          _TabButton(
    78	              label: 'Model',
    79	              icon: Icons.psychology_rounded,
    80	              index: 2,
    81	              current: appState.rightPanelTab,
    82	              onTap: () => appState.setRightPanelTab(2)),
    83	          const Spacer(),
    84	          IconButton(
    85	            onPressed: appState.toggleRightSidebar,
    86	            icon: const Icon(Icons.chevron_right_rounded, size: 18),
    87	            style: IconButton.styleFrom(
    88	              minimumSize: const Size(28, 28),
    89	              padding: EdgeInsets.zero,
    90	            ),
    91	          ),
    92	        ],
    93	      ),
    94	    );
    95	  }
    96	}
    97	
    98	class _TabButton extends StatefulWidget {
    99	  final String label;
   100	  final IconData icon;
   101	  final int index;
   102	  final int current;
   103	  final VoidCallback onTap;
   104	
   105	  const _TabButton(
   106	      {required this.label,
   107	      required this.icon,
   108	      required this.index,
   109	      required this.current,
   110	      required this.onTap});
   111	
   112	  @override
   113	  State<_TabButton> createState() => _TabButtonState();
   114	}
   115	
   116	class _TabButtonState extends State<_TabButton> {
   117	  bool _hovered = false;
   118	
   119	  @override
   120	  Widget build(BuildContext context) {
   121	    final selected = widget.index == widget.current;
   122	    return MouseRegion(
   123	      onEnter: (_) => setState(() => _hovered = true),
   124	      onExit: (_) => setState(() => _hovered = false),
   125	      cursor: SystemMouseCursors.click,
   126	      child: GestureDetector(
   127	        onTap: widget.onTap,
   128	        child: AnimatedContainer(
   129	          duration: const Duration(milliseconds: 150),
   130	          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
   131	          decoration: BoxDecoration(
   132	            color: selected
   133	                ? WeaverColors.accentGlow
   134	                : (_hovered ? WeaverColors.cardHover : Colors.transparent),
   135	            borderRadius: BorderRadius.circular(6),
   136	            border: selected
   137	                ? Border.all(color: WeaverColors.accent.withOpacity(0.4))
   138	                : null,
   139	          ),
   140	          child: Row(
   141	            mainAxisSize: MainAxisSize.min,
   142	            children: [
   143	              Icon(widget.icon,
   144	                  size: 13,
   145	                  color:
   146	                      selected ? WeaverColors.accent : WeaverColors.textMuted),
   147	              const SizedBox(width: 5),
   148	              Text(
   149	                widget.label,
   150	                style: TextStyle(
   151	                  fontSize: 12,
   152	                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
   153	                  color:
   154	                      selected ? WeaverColors.accent : WeaverColors.textMuted,
   155	                ),
   156	              ),
   157	            ],
   158	          ),
   159	        ),
   160	      ),
   161	    );
   162	  }
   163	}
   164	
   165	// ── Tools Panel ───────────────────────────────────────────────────────────────
   166	class _ToolsPanel extends StatelessWidget {
   167	  const _ToolsPanel();
   168	
   169	  @override
   170	  Widget build(BuildContext context) {
   171	    return Consumer<ToolsProvider>(
   172	      builder: (context, provider, _) {
   173	        if (provider.isLoading && provider.tools.isEmpty) {
   174	          return const Center(child: CircularProgressIndicator());
   175	        }
   176	
   177	        return Column(
   178	          children: [
   179	            // Search + stats
   180	            Padding(
   181	              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
   182	              child: Column(
   183	                children: [
   184	                  if (provider.lastError != null &&
   185	                      provider.lastError!.isNotEmpty)
   186	                    Container(
   187	                      width: double.infinity,
   188	                      margin: const EdgeInsets.only(bottom: 8),
   189	                      padding: const EdgeInsets.all(8),
   190	                      decoration: BoxDecoration(
   191	                        color: WeaverColors.errorDim,
   192	                        borderRadius: BorderRadius.circular(8),
   193	                        border: Border.all(
   194	                            color: WeaverColors.error.withOpacity(0.3)),
   195	                      ),
   196	                      child: Row(
   197	                        children: [
   198	                          const Icon(Icons.error_outline_rounded,
   199	                              size: 14, color: WeaverColors.error),
   200	                          const SizedBox(width: 6),
   201	                          Expanded(
   202	                            child: Text(
   203	                              provider.lastError!,
   204	                              style: const TextStyle(
   205	                                  fontSize: 11, color: WeaverColors.error),
   206	                              maxLines: 2,
   207	                              overflow: TextOverflow.ellipsis,
   208	                            ),
   209	                          ),
   210	                          const SizedBox(width: 6),
   211	                          GestureDetector(
   212	                            onTap: provider.refreshFromBackend,
   213	                            child: const Icon(Icons.refresh_rounded,
   214	                                size: 14, color: WeaverColors.error),
   215	                          ),
   216	                        ],
   217	                      ),
   218	                    ),
   219	                  // stats
   220	                  Row(
   221	                    children: [
   222	                      _StatPill(
   223	                          label: '${provider.connectedCount} connected',
   224	                          color: WeaverColors.success),
   225	                      const SizedBox(width: 6),
   226	                      _StatPill(
   227	                          label: '${provider.enabledCount} active',
   228	                          color: WeaverColors.accent),
   229	                      const Spacer(),
   230	                      IconButton(
   231	                        tooltip: 'Refresh tools',
   232	                        onPressed: provider.refreshFromBackend,
   233	                        icon: const Icon(Icons.refresh_rounded, size: 16),
   234	                        style: IconButton.styleFrom(
   235	                            minimumSize: const Size(24, 24),
   236	                            padding: EdgeInsets.zero),
   237	                      ),
   238	                    ],
   239	                  ),
   240	                  const SizedBox(height: 10),
   241	                  // Search
   242	                  TextField(
   243	                    decoration: const InputDecoration(
   244	                      hintText: 'Search tools...',
   245	                      prefixIcon: Icon(Icons.search_rounded, size: 17),
   246	                      isDense: true,
   247	                    ),
   248	                    style: const TextStyle(fontSize: 13),
   249	                    onChanged: provider.setSearch,
   250	                  ),
   251	                  const SizedBox(height: 8),
   252	                  // Category chips
   253	                  SingleChildScrollView(
   254	                    scrollDirection: Axis.horizontal,
   255	                    child: Row(
   256	                      children: [
   257	                        CategoryChip(
   258	                          label: 'All',
   259	                          isSelected: provider.filterCategory == null,
   260	                          onTap: () => provider.setCategory(null),
   261	                          color: WeaverColors.accent,
   262	                        ),
   263	                        const SizedBox(width: 4),
   264	                        ...ToolCategory.values.map((c) => Padding(
   265	                              padding: const EdgeInsets.only(right: 4),
   266	                              child: CategoryChip(
   267	                                label: _catLabel(c),
   268	                                isSelected: provider.filterCategory == c,
   269	                                onTap: () => provider.setCategory(
   270	                                    provider.filterCategory == c ? null : c),
   271	                                color: _catColor(c),
   272	                              ),
   273	                            )),
   274	                      ],
   275	                    ),
   276	                  ),
   277	                ],
   278	              ),
   279	            ),
   280	            Container(
   281	                height: 1, color: WeaverColors.cardBorder.withOpacity(0.4)),
   282	            // Tool list
   283	            Expanded(
   284	              child: ListView.builder(
   285	                padding: const EdgeInsets.all(12),
   286	                itemCount: provider.filteredTools.length,
   287	                itemBuilder: (context, i) =>
   288	                    ToolCard(tool: provider.filteredTools[i]),
   289	              ),
   290	            ),
   291	          ],
   292	        );
   293	      },
   294	    );
   295	  }
   296	
   297	  String _catLabel(ToolCategory c) => switch (c) {
   298	        ToolCategory.cloud => 'Cloud',
   299	        ToolCategory.messaging => 'Messaging',
   300	        ToolCategory.files => 'Files',
   301	        ToolCategory.dev => 'Dev',
   302	        ToolCategory.productivity => 'Productivity',
   303	        ToolCategory.ai => 'AI',
   304	      };
   305	
   306	  Color _catColor(ToolCategory c) => switch (c) {
   307	        ToolCategory.cloud => WeaverColors.cloudColor,
   308	        ToolCategory.messaging => WeaverColors.messagingColor,
   309	        ToolCategory.files => WeaverColors.filesColor,
   310	        ToolCategory.dev => WeaverColors.devColor,
   311	        ToolCategory.productivity => WeaverColors.productivityColor,
   312	        ToolCategory.ai => WeaverColors.accentBright,
   313	      };
   314	}
   315	
   316	class _StatPill extends StatelessWidget {
   317	  final String label;
   318	  final Color color;
   319	
   320	  const _StatPill({required this.label, required this.color});
   321	
   322	  @override
   323	  Widget build(BuildContext context) {
   324	    return Container(
   325	      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
   326	      decoration: BoxDecoration(
   327	        color: color.withOpacity(0.1),
   328	        borderRadius: BorderRadius.circular(12),
   329	        border: Border.all(color: color.withOpacity(0.3)),
   330	      ),
   331	      child: Text(label,
   332	          style: TextStyle(
   333	              fontSize: 11, color: color, fontWeight: FontWeight.w500)),
   334	    );
   335	  }
   336	}
```

## frontend/lib/widgets/shell/weaver_tab_bar.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:provider/provider.dart';
     3	import '../../providers/providers.dart';
     4	import '../../theme/colors.dart';
     5	
     6	class WeaverTabBar extends StatelessWidget {
     7	  const WeaverTabBar({super.key});
     8	
     9	  @override
    10	  Widget build(BuildContext context) {
    11	    return Consumer<ChatProvider>(
    12	      builder: (context, chatProvider, _) {
    13	        if (chatProvider.openTabIds.isEmpty) return const SizedBox.shrink();
    14	        return Container(
    15	          height: 38,
    16	          decoration: const BoxDecoration(
    17	            color: WeaverColors.background,
    18	            border: Border(bottom: BorderSide(color: WeaverColors.cardBorder)),
    19	          ),
    20	          child: Row(
    21	            children: [
    22	              Expanded(
    23	                child: ListView.builder(
    24	                  scrollDirection: Axis.horizontal,
    25	                  itemCount: chatProvider.openTabIds.length,
    26	                  itemBuilder: (context, i) {
    27	                    final sessionId = chatProvider.openTabIds[i];
    28	                    final session = chatProvider.sessions
    29	                        .where((s) => s.id == sessionId)
    30	                        .firstOrNull;
    31	                    if (session == null) return const SizedBox.shrink();
    32	                    return _ChatTab(
    33	                      session: session,
    34	                      isActive: chatProvider.activeTabId == sessionId,
    35	                      onTap: () => chatProvider.setActiveTab(sessionId),
    36	                      onClose: () => chatProvider.closeTab(sessionId),
    37	                    );
    38	                  },
    39	                ),
    40	              ),
    41	            ],
    42	          ),
    43	        );
    44	      },
    45	    );
    46	  }
    47	}
    48	
    49	class _ChatTab extends StatefulWidget {
    50	  final dynamic session;
    51	  final bool isActive;
    52	  final VoidCallback onTap;
    53	  final VoidCallback onClose;
    54	
    55	  const _ChatTab({required this.session, required this.isActive, required this.onTap, required this.onClose});
    56	
    57	  @override
    58	  State<_ChatTab> createState() => _ChatTabState();
    59	}
    60	
    61	class _ChatTabState extends State<_ChatTab> {
    62	  bool _hovered = false;
    63	  bool _closeHovered = false;
    64	
    65	  @override
    66	  Widget build(BuildContext context) {
    67	    return MouseRegion(
    68	      onEnter: (_) => setState(() => _hovered = true),
    69	      onExit: (_) => setState(() {
    70	        _hovered = false;
    71	        _closeHovered = false;
    72	      }),
    73	      cursor: SystemMouseCursors.click,
    74	      child: GestureDetector(
    75	        onTap: widget.onTap,
    76	        child: AnimatedContainer(
    77	          duration: const Duration(milliseconds: 120),
    78	          constraints: const BoxConstraints(maxWidth: 220, minWidth: 100),
    79	          padding: const EdgeInsets.symmetric(horizontal: 12),
    80	          decoration: BoxDecoration(
    81	            color: widget.isActive ? WeaverColors.surface : Colors.transparent,
    82	            border: Border(
    83	              right: const BorderSide(color: WeaverColors.cardBorder),
    84	              bottom: widget.isActive
    85	                  ? const BorderSide(color: WeaverColors.accent, width: 2)
    86	                  : BorderSide.none,
    87	            ),
    88	          ),
    89	          child: Row(
    90	            mainAxisSize: MainAxisSize.min,
    91	            children: [
    92	              Icon(
    93	                Icons.chat_bubble_outline_rounded,
    94	                size: 13,
    95	                color: widget.isActive ? WeaverColors.accent : WeaverColors.textMuted,
    96	              ),
    97	              const SizedBox(width: 6),
    98	              Flexible(
    99	                child: Text(
   100	                  widget.session.title,
   101	                  style: TextStyle(
   102	                    fontSize: 12,
   103	                    color: widget.isActive ? WeaverColors.textPrimary : WeaverColors.textMuted,
   104	                    fontWeight: widget.isActive ? FontWeight.w500 : FontWeight.w400,
   105	                  ),
   106	                  overflow: TextOverflow.ellipsis,
   107	                ),
   108	              ),
   109	              const SizedBox(width: 6),
   110	              // Close button
   111	              MouseRegion(
   112	                onEnter: (_) => setState(() => _closeHovered = true),
   113	                onExit: (_) => setState(() => _closeHovered = false),
   114	                cursor: SystemMouseCursors.click,
   115	                child: GestureDetector(
   116	                  onTap: widget.onClose,
   117	                  child: AnimatedContainer(
   118	                    duration: const Duration(milliseconds: 100),
   119	                    width: 16,
   120	                    height: 16,
   121	                    decoration: BoxDecoration(
   122	                      color: _closeHovered ? WeaverColors.cardBorder : Colors.transparent,
   123	                      borderRadius: BorderRadius.circular(3),
   124	                    ),
   125	                    child: Center(
   126	                      child: Icon(
   127	                        Icons.close_rounded,
   128	                        size: 11,
   129	                        color: _closeHovered ? WeaverColors.textPrimary : (_hovered ? WeaverColors.textMuted : Colors.transparent),
   130	                      ),
   131	                    ),
   132	                  ),
   133	                ),
   134	              ),
   135	            ],
   136	          ),
   137	        ),
   138	      ),
   139	    );
   140	  }
   141	}
```

## frontend/lib/widgets/tool_card/tool_card.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:flutter_animate/flutter_animate.dart';
     3	import 'package:provider/provider.dart';
     4	import '../../models/models.dart';
     5	import '../../providers/providers.dart';
     6	import '../../theme/colors.dart';
     7	import '../common/common_widgets.dart';
     8	
     9	class ToolCard extends StatelessWidget {
    10	  final ToolModel tool;
    11	
    12	  const ToolCard({super.key, required this.tool});
    13	
    14	  @override
    15	  Widget build(BuildContext context) {
    16	    return Consumer<ToolsProvider>(
    17	      builder: (context, provider, _) {
    18	        final isExpanded = provider.expandedToolId == tool.id;
    19	        return AnimatedContainer(
    20	          duration: const Duration(milliseconds: 250),
    21	          curve: Curves.easeInOut,
    22	          margin: const EdgeInsets.only(bottom: 8),
    23	          decoration: BoxDecoration(
    24	            color: isExpanded ? WeaverColors.cardHover : WeaverColors.card,
    25	            borderRadius: BorderRadius.circular(12),
    26	            border: Border.all(
    27	              color: isExpanded
    28	                  ? tool.categoryColor.withOpacity(0.5)
    29	                  : WeaverColors.cardBorder,
    30	              width: isExpanded ? 1.5 : 1,
    31	            ),
    32	          ),
    33	          child: Column(
    34	            children: [
    35	              _ToolCardHeader(
    36	                  tool: tool, isExpanded: isExpanded, provider: provider),
    37	              if (isExpanded)
    38	                _ToolCardBody(tool: tool, provider: provider)
    39	                    .animate()
    40	                    .fadeIn(duration: 200.ms)
    41	                    .slideY(begin: -0.05, end: 0, duration: 200.ms),
    42	            ],
    43	          ),
    44	        );
    45	      },
    46	    );
    47	  }
    48	}
    49	
    50	class _ToolCardHeader extends StatefulWidget {
    51	  final ToolModel tool;
    52	  final bool isExpanded;
    53	  final ToolsProvider provider;
    54	
    55	  const _ToolCardHeader(
    56	      {required this.tool, required this.isExpanded, required this.provider});
    57	
    58	  @override
    59	  State<_ToolCardHeader> createState() => _ToolCardHeaderState();
    60	}
    61	
    62	class _ToolCardHeaderState extends State<_ToolCardHeader> {
    63	  bool _hovered = false;
    64	
    65	  @override
    66	  Widget build(BuildContext context) {
    67	    final tool = widget.tool;
    68	    return MouseRegion(
    69	      onEnter: (_) => setState(() => _hovered = true),
    70	      onExit: (_) => setState(() => _hovered = false),
    71	      cursor: SystemMouseCursors.click,
    72	      child: GestureDetector(
    73	        onTap: () => widget.provider.toggleExpanded(tool.id),
    74	        child: Container(
    75	          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    76	          decoration: BoxDecoration(
    77	            color: _hovered && !widget.isExpanded
    78	                ? WeaverColors.cardHover
    79	                : Colors.transparent,
    80	            borderRadius: widget.isExpanded
    81	                ? const BorderRadius.vertical(top: Radius.circular(12))
    82	                : BorderRadius.circular(12),
    83	          ),
    84	          child: Row(
    85	            children: [
    86	              // Logo container
    87	              Container(
    88	                width: 38,
    89	                height: 38,
    90	                decoration: BoxDecoration(
    91	                  color: tool.categoryColor.withOpacity(0.12),
    92	                  borderRadius: BorderRadius.circular(9),
    93	                  border:
    94	                      Border.all(color: tool.categoryColor.withOpacity(0.25)),
    95	                ),
    96	                child: Center(
    97	                    child: Text(tool.logoEmoji,
    98	                        style: const TextStyle(fontSize: 18))),
    99	              ),
   100	              const SizedBox(width: 11),
   101	              // Name + status
   102	              Expanded(
   103	                child: Column(
   104	                  crossAxisAlignment: CrossAxisAlignment.start,
   105	                  children: [
   106	                    Row(
   107	                      children: [
   108	                        Text(
   109	                          tool.name,
   110	                          style: const TextStyle(
   111	                            fontSize: 13,
   112	                            fontWeight: FontWeight.w600,
   113	                            color: WeaverColors.textPrimary,
   114	                          ),
   115	                        ),
   116	                        const SizedBox(width: 6),
   117	                        StatusBadge(status: tool.authStatus, compact: true),
   118	                      ],
   119	                    ),
   120	                    const SizedBox(height: 2),
   121	                    Text(
   122	                      _categoryLabel(tool.category),
   123	                      style: TextStyle(
   124	                          fontSize: 11,
   125	                          color: tool.categoryColor,
   126	                          fontWeight: FontWeight.w500),
   127	                    ),
   128	                  ],
   129	                ),
   130	              ),
   131	              // Usage count
   132	              if (tool.usageCount > 0) ...[
   133	                Container(
   134	                  padding:
   135	                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
   136	                  decoration: BoxDecoration(
   137	                    color: WeaverColors.surface,
   138	                    borderRadius: BorderRadius.circular(10),
   139	                  ),
   140	                  child: Text(
   141	                    '${tool.usageCount}',
   142	                    style: const TextStyle(
   143	                        fontSize: 10,
   144	                        color: WeaverColors.textMuted,
   145	                        fontWeight: FontWeight.w600),
   146	                  ),
   147	                ),
   148	                const SizedBox(width: 8),
   149	              ],
   150	              // Toggle switch
   151	              Transform.scale(
   152	                scale: 0.8,
   153	                child: Switch(
   154	                  value: tool.isEnabled,
   155	                  onChanged: (v) {
   156	                    widget.provider.toggleEnabled(tool.id);
   157	                  },
   158	                ),
   159	              ),
   160	              // Expand arrow
   161	              AnimatedRotation(
   162	                turns: widget.isExpanded ? 0.5 : 0,
   163	                duration: const Duration(milliseconds: 200),
   164	                child: const Icon(Icons.expand_more_rounded,
   165	                    color: WeaverColors.textMuted, size: 18),
   166	              ),
   167	            ],
   168	          ),
   169	        ),
   170	      ),
   171	    );
   172	  }
   173	
   174	  String _categoryLabel(ToolCategory cat) => switch (cat) {
   175	        ToolCategory.cloud => 'Cloud',
   176	        ToolCategory.messaging => 'Messaging',
   177	        ToolCategory.files => 'Files',
   178	        ToolCategory.dev => 'Development',
   179	        ToolCategory.productivity => 'Productivity',
   180	        ToolCategory.ai => 'AI / Web',
   181	      };
   182	}
   183	
   184	class _ToolCardBody extends StatelessWidget {
   185	  final ToolModel tool;
   186	  final ToolsProvider provider;
   187	
   188	  const _ToolCardBody({required this.tool, required this.provider});
   189	
   190	  @override
   191	  Widget build(BuildContext context) {
   192	    return Container(
   193	      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
   194	      child: Column(
   195	        crossAxisAlignment: CrossAxisAlignment.start,
   196	        children: [
   197	          Container(height: 1, color: WeaverColors.cardBorder.withOpacity(0.4)),
   198	          const SizedBox(height: 12),
   199	
   200	          // Description
   201	          Text(tool.description,
   202	              style: const TextStyle(
   203	                  fontSize: 12,
   204	                  color: WeaverColors.textSecondary,
   205	                  height: 1.5)),
   206	          const SizedBox(height: 12),
   207	
   208	          // Auth status bar
   209	          _AuthStatusBar(tool: tool, provider: provider),
   210	          if (_connectedAccount(tool).isNotEmpty) ...[
   211	            const SizedBox(height: 8),
   212	            Text(
   213	              'Connected as: ${_connectedAccount(tool)}',
   214	              style:
   215	                  const TextStyle(fontSize: 11, color: WeaverColors.textMuted),
   216	            ),
   217	          ],
   218	          if (tool.id == 'filesystem') ...[
   219	            const SizedBox(height: 10),
   220	            _FilesystemRootEditor(tool: tool, provider: provider),
   221	          ],
   222	          if (tool.id == 'discord') ...[
   223	            const SizedBox(height: 10),
   224	            const _DiscordChannelEditor(),
   225	          ],
   226	          const SizedBox(height: 14),
   227	
   228	          // Capabilities
   229	          const Text('Capabilities',
   230	              style: TextStyle(
   231	                  fontSize: 11,
   232	                  fontWeight: FontWeight.w600,
   233	                  color: WeaverColors.textMuted,
   234	                  letterSpacing: 0.5)),
   235	          const SizedBox(height: 8),
   236	          ...tool.capabilities.map(
   237	              (cap) => _CapabilityRow(cap: cap, color: tool.categoryColor)),
   238	
   239	          // Last used
   240	          if (tool.lastUsed != null) ...[
   241	            const SizedBox(height: 12),
   242	            Container(
   243	                height: 1, color: WeaverColors.cardBorder.withOpacity(0.4)),
   244	            const SizedBox(height: 10),
   245	            Row(
   246	              children: [
   247	                const Icon(Icons.access_time_rounded,
   248	                    size: 12, color: WeaverColors.textMuted),
   249	                const SizedBox(width: 5),
   250	                Text('Last used ${tool.lastUsed}',
   251	                    style: const TextStyle(
   252	                        fontSize: 11, color: WeaverColors.textMuted)),
   253	                const Spacer(),
   254	                Text('${tool.usageCount} calls total',
   255	                    style: const TextStyle(
   256	                        fontSize: 11, color: WeaverColors.textMuted)),
   257	              ],
   258	            ),
   259	          ],
   260	        ],
   261	      ),
   262	    );
   263	  }
   264	
   265	  String _connectedAccount(ToolModel tool) {
   266	    final metadata = tool.metadata;
   267	    final profile = metadata['profile'] as Map<String, dynamic>?;
   268	    if (profile == null) return '';
   269	    if (tool.id == 'discord') {
   270	      return profile['display_name']?.toString() ??
   271	          profile['username']?.toString() ??
   272	          '';
   273	    }
   274	    return profile['email']?.toString() ?? profile['name']?.toString() ?? '';
   275	  }
   276	}
   277	
   278	class _FilesystemRootEditor extends StatefulWidget {
   279	  final ToolModel tool;
   280	  final ToolsProvider provider;
   281	
   282	  const _FilesystemRootEditor({required this.tool, required this.provider});
   283	
   284	  @override
   285	  State<_FilesystemRootEditor> createState() => _FilesystemRootEditorState();
   286	}
   287	
   288	class _FilesystemRootEditorState extends State<_FilesystemRootEditor> {
   289	  late final TextEditingController _rootController;
   290	
   291	  @override
   292	  void initState() {
   293	    super.initState();
   294	    _rootController = TextEditingController(
   295	      text: widget.tool.metadata['allowed_root']?.toString() ?? '',
   296	    );
   297	  }
   298	
   299	  @override
   300	  void didUpdateWidget(covariant _FilesystemRootEditor oldWidget) {
   301	    super.didUpdateWidget(oldWidget);
   302	    final root = widget.tool.metadata['allowed_root']?.toString() ?? '';
   303	    if (root.isNotEmpty && _rootController.text != root) {
   304	      _rootController.text = root;
   305	    }
   306	  }
   307	
   308	  @override
   309	  void dispose() {
   310	    _rootController.dispose();
   311	    super.dispose();
   312	  }
   313	
   314	  @override
   315	  Widget build(BuildContext context) {
   316	    return Container(
   317	      padding: const EdgeInsets.all(10),
   318	      decoration: BoxDecoration(
   319	        color: WeaverColors.surface,
   320	        borderRadius: BorderRadius.circular(8),
   321	        border: Border.all(color: WeaverColors.cardBorder),
   322	      ),
   323	      child: Column(
   324	        crossAxisAlignment: CrossAxisAlignment.start,
   325	        children: [
   326	          const Text(
   327	            'Allowed Root Directory',
   328	            style: TextStyle(
   329	                fontSize: 11,
   330	                color: WeaverColors.textMuted,
   331	                fontWeight: FontWeight.w600),
   332	          ),
   333	          const SizedBox(height: 6),
   334	          TextField(
   335	            controller: _rootController,
   336	            style:
   337	                const TextStyle(fontSize: 12, color: WeaverColors.textPrimary),
   338	            decoration: const InputDecoration(
   339	              hintText: '/home/user/projects/allowed-dir',
   340	              isDense: true,
   341	            ),
   342	          ),
   343	          const SizedBox(height: 8),
   344	          SizedBox(
   345	            height: 28,
   346	            child: ElevatedButton.icon(
   347	              onPressed: () =>
   348	                  widget.provider.setFilesystemRoot(_rootController.text),
   349	              icon: const Icon(Icons.save_rounded, size: 13),
   350	              label: const Text('Save Root', style: TextStyle(fontSize: 11)),
   351	              style: ElevatedButton.styleFrom(
   352	                  padding: const EdgeInsets.symmetric(horizontal: 10)),
   353	            ),
   354	          ),
   355	        ],
   356	      ),
   357	    );
   358	  }
   359	}
   360	
   361	class _DiscordChannelEditor extends StatefulWidget {
   362	  const _DiscordChannelEditor();
   363	
   364	  @override
   365	  State<_DiscordChannelEditor> createState() => _DiscordChannelEditorState();
   366	}
   367	
   368	class _DiscordChannelEditorState extends State<_DiscordChannelEditor> {
   369	  late final TextEditingController _channelController;
   370	
   371	  @override
   372	  void initState() {
   373	    super.initState();
   374	    final backend = context.read<BackendProvider>();
   375	    _channelController = TextEditingController(text: backend.discordChannelId);
   376	  }
   377	
   378	  @override
   379	  void didChangeDependencies() {
   380	    super.didChangeDependencies();
   381	    final saved = context.read<BackendProvider>().discordChannelId;
   382	    if (_channelController.text != saved) {
   383	      _channelController.text = saved;
   384	    }
   385	  }
   386	
   387	  @override
   388	  void dispose() {
   389	    _channelController.dispose();
   390	    super.dispose();
   391	  }
   392	
   393	  @override
   394	  Widget build(BuildContext context) {
   395	    return Container(
   396	      padding: const EdgeInsets.all(10),
   397	      decoration: BoxDecoration(
   398	        color: WeaverColors.surface,
   399	        borderRadius: BorderRadius.circular(8),
   400	        border: Border.all(color: WeaverColors.cardBorder),
   401	      ),
   402	      child: Column(
   403	        crossAxisAlignment: CrossAxisAlignment.start,
   404	        children: [
   405	          const Text(
   406	            'Default Discord Channel ID',
   407	            style: TextStyle(
   408	                fontSize: 11,
   409	                color: WeaverColors.textMuted,
   410	                fontWeight: FontWeight.w600),
   411	          ),
   412	          const SizedBox(height: 6),
   413	          TextField(
   414	            controller: _channelController,
   415	            keyboardType: TextInputType.number,
   416	            style:
   417	                const TextStyle(fontSize: 12, color: WeaverColors.textPrimary),
   418	            decoration: const InputDecoration(
   419	              hintText: '1494502217703620731',
   420	              isDense: true,
   421	            ),
   422	          ),
   423	          const SizedBox(height: 8),
   424	          Row(
   425	            children: [
   426	              SizedBox(
   427	                height: 28,
   428	                child: ElevatedButton.icon(
   429	                  onPressed: () => context
   430	                      .read<BackendProvider>()
   431	                      .setDiscordChannelId(_channelController.text),
   432	                  icon: const Icon(Icons.save_rounded, size: 13),
   433	                  label: const Text('Save Default',
   434	                      style: TextStyle(fontSize: 11)),
   435	                  style: ElevatedButton.styleFrom(
   436	                      padding: const EdgeInsets.symmetric(horizontal: 10)),
   437	                ),
   438	              ),
   439	              const SizedBox(width: 8),
   440	              const Expanded(
   441	                child: Text(
   442	                  'Used automatically when prompt asks to send to Discord.',
   443	                  style: TextStyle(fontSize: 11, color: WeaverColors.textMuted),
   444	                ),
   445	              ),
   446	            ],
   447	          ),
   448	        ],
   449	      ),
   450	    );
   451	  }
   452	}
   453	
   454	class _AuthStatusBar extends StatelessWidget {
   455	  final ToolModel tool;
   456	  final ToolsProvider provider;
   457	
   458	  const _AuthStatusBar({required this.tool, required this.provider});
   459	
   460	  @override
   461	  Widget build(BuildContext context) {
   462	    return Container(
   463	      padding: const EdgeInsets.all(10),
   464	      decoration: BoxDecoration(
   465	        color: WeaverColors.surface,
   466	        borderRadius: BorderRadius.circular(8),
   467	        border: Border.all(color: WeaverColors.cardBorder),
   468	      ),
   469	      child: Row(
   470	        children: [
   471	          StatusBadge(status: tool.authStatus),
   472	          const Spacer(),
   473	          if (tool.authStatus == AuthStatus.disconnected)
   474	            SizedBox(
   475	              height: 28,
   476	              child: ElevatedButton.icon(
   477	                onPressed: () => provider.connectTool(tool.id),
   478	                icon: const Icon(Icons.link_rounded, size: 13),
   479	                label: const Text('Connect', style: TextStyle(fontSize: 12)),
   480	                style: ElevatedButton.styleFrom(
   481	                    padding: const EdgeInsets.symmetric(horizontal: 12)),
   482	              ),
   483	            )
   484	          else if (tool.authStatus == AuthStatus.pending)
   485	            const SizedBox(
   486	              width: 14,
   487	              height: 14,
   488	              child: CircularProgressIndicator(
   489	                  strokeWidth: 2, color: WeaverColors.warning),
   490	            )
   491	          else if (tool.authStatus == AuthStatus.connected)
   492	            SizedBox(
   493	              height: 28,
   494	              child: OutlinedButton.icon(
   495	                onPressed: () => Provider.of<AppState>(context, listen: false)
   496	                    .setNavIndex(3),
   497	                icon: const Icon(Icons.settings_rounded, size: 12),
   498	                label: const Text('Settings', style: TextStyle(fontSize: 11)),
   499	                style: OutlinedButton.styleFrom(
   500	                    padding: const EdgeInsets.symmetric(horizontal: 10)),
   501	              ),
   502	            ),
   503	        ],
   504	      ),
   505	    );
   506	  }
   507	}
   508	
   509	class _CapabilityRow extends StatelessWidget {
   510	  final ToolCapability cap;
   511	  final Color color;
   512	
   513	  const _CapabilityRow({required this.cap, required this.color});
   514	
   515	  @override
   516	  Widget build(BuildContext context) {
   517	    return Padding(
   518	      padding: const EdgeInsets.only(bottom: 6),
   519	      child: Row(
   520	        children: [
   521	          Container(
   522	            width: 26,
   523	            height: 26,
   524	            decoration: BoxDecoration(
   525	              color: color.withOpacity(0.1),
   526	              borderRadius: BorderRadius.circular(6),
   527	            ),
   528	            child: Center(
   529	                child: Text(cap.icon, style: const TextStyle(fontSize: 12))),
   530	          ),
   531	          const SizedBox(width: 9),
   532	          Expanded(
   533	            child: Column(
   534	              crossAxisAlignment: CrossAxisAlignment.start,
   535	              children: [
   536	                Text(cap.name,
   537	                    style: const TextStyle(
   538	                        fontSize: 12,
   539	                        fontWeight: FontWeight.w500,
   540	                        color: WeaverColors.textPrimary)),
   541	                Text(cap.description,
   542	                    style: const TextStyle(
   543	                        fontSize: 11, color: WeaverColors.textMuted)),
   544	              ],
   545	            ),
   546	          ),
   547	        ],
   548	      ),
   549	    );
   550	  }
   551	}
```

## frontend/lib/widgets/workflow/workflow_canvas.dart

```dart
     1	import 'dart:math' as math;
     2	import 'package:flutter/material.dart';
     3	import 'package:flutter_animate/flutter_animate.dart';
     4	import 'package:provider/provider.dart';
     5	import '../../providers/providers.dart';
     6	import '../../theme/colors.dart';
     7	import '../../models/models.dart';
     8	import '../common/common_widgets.dart';
     9	
    10	// ── n8n-Style Workflow Canvas ─────────────────────────────────────────────────
    11	class WorkflowCanvas extends StatefulWidget {
    12	  final WorkflowModel workflow;
    13	
    14	  const WorkflowCanvas({super.key, required this.workflow});
    15	
    16	  @override
    17	  State<WorkflowCanvas> createState() => _WorkflowCanvasState();
    18	}
    19	
    20	class _WorkflowCanvasState extends State<WorkflowCanvas> {
    21	  double _scale = 1.0;
    22	  Offset _offset = Offset.zero;
    23	  String? _selectedNodeId;
    24	  Offset? _dragStart;
    25	  Offset? _nodeStartPos;
    26	
    27	  @override
    28	  Widget build(BuildContext context) {
    29	    return Consumer<WorkflowsProvider>(
    30	      builder: (context, wfProv, _) {
    31	        return Column(
    32	          children: [
    33	            _CanvasTopBar(workflow: widget.workflow, onRun: () => wfProv.runWorkflow(widget.workflow.id)),
    34	            Expanded(
    35	              child: Row(
    36	                children: [
    37	                  // Main canvas
    38	                  Expanded(
    39	                    child: Stack(
    40	                      children: [
    41	                        // Grid background
    42	                        Positioned.fill(child: _GridBackground()),
    43	                        // Canvas content
    44	                        GestureDetector(
    45	                          onPanUpdate: (d) {
    46	                            if (_selectedNodeId == null) {
    47	                              setState(() => _offset += d.delta);
    48	                            }
    49	                          },
    50	                          child: ClipRect(
    51	                            child: Transform(
    52	                              transform: Matrix4.identity()
    53	                                ..translate(_offset.dx, _offset.dy)
    54	                                ..scale(_scale),
    55	                              child: SizedBox.expand(
    56	                                child: Stack(
    57	                                  clipBehavior: Clip.none,
    58	                                  children: [
    59	                                    // Draw edges
    60	                                    Positioned.fill(
    61	                                      child: CustomPaint(
    62	                                        painter: _EdgePainter(
    63	                                          nodes: widget.workflow.nodes,
    64	                                          edges: widget.workflow.edges,
    65	                                          status: widget.workflow.status,
    66	                                        ),
    67	                                      ),
    68	                                    ),
    69	                                    // Draw nodes
    70	                                    ...widget.workflow.nodes.map((node) => _DraggableNode(
    71	                                      key: Key(node.id),
    72	                                      node: node,
    73	                                      isSelected: _selectedNodeId == node.id,
    74	                                      onTap: () => setState(() => _selectedNodeId = node.id == _selectedNodeId ? null : node.id),
    75	                                      onDragUpdate: (delta) {
    76	                                        wfProv.updateNodePosition(
    77	                                          widget.workflow.id,
    78	                                          node.id,
    79	                                          node.position + delta / _scale,
    80	                                        );
    81	                                      },
    82	                                    )),
    83	                                  ],
    84	                                ),
    85	                              ),
    86	                            ),
    87	                          ),
    88	                        ),
    89	                        // Zoom controls
    90	                        Positioned(
    91	                          right: 16,
    92	                          bottom: 16,
    93	                          child: _ZoomControls(
    94	                            scale: _scale,
    95	                            onZoomIn: () => setState(() => _scale = (_scale * 1.2).clamp(0.3, 3.0)),
    96	                            onZoomOut: () => setState(() => _scale = (_scale / 1.2).clamp(0.3, 3.0)),
    97	                            onReset: () => setState(() { _scale = 1.0; _offset = Offset.zero; }),
    98	                          ),
    99	                        ),
   100	                        // Add node button
   101	                        Positioned(
   102	                          left: 16,
   103	                          bottom: 16,
   104	                          child: _AddNodeButton(workflowId: widget.workflow.id),
   105	                        ),
   106	                      ],
   107	                    ),
   108	                  ),
   109	                  // Node config panel (when a node is selected)
   110	                  if (_selectedNodeId != null)
   111	                    _NodeConfigPanel(
   112	                      node: widget.workflow.nodes.firstWhere((n) => n.id == _selectedNodeId, orElse: () => widget.workflow.nodes.first),
   113	                      onClose: () => setState(() => _selectedNodeId = null),
   114	                    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.05, end: 0),
   115	                ],
   116	              ),
   117	            ),
   118	          ],
   119	        );
   120	      },
   121	    );
   122	  }
   123	}
   124	
   125	// ── Canvas top bar ────────────────────────────────────────────────────────────
   126	class _CanvasTopBar extends StatelessWidget {
   127	  final WorkflowModel workflow;
   128	  final VoidCallback onRun;
   129	
   130	  const _CanvasTopBar({required this.workflow, required this.onRun});
   131	
   132	  @override
   133	  Widget build(BuildContext context) {
   134	    return Container(
   135	      height: 50,
   136	      padding: const EdgeInsets.symmetric(horizontal: 16),
   137	      decoration: const BoxDecoration(
   138	        color: WeaverColors.surface,
   139	        border: Border(bottom: BorderSide(color: WeaverColors.cardBorder)),
   140	      ),
   141	      child: Row(
   142	        children: [
   143	          IconButton(
   144	            icon: const Icon(Icons.arrow_back_rounded, size: 18),
   145	            onPressed: () => Provider.of<WorkflowsProvider>(context, listen: false).closeWorkflow(),
   146	          ),
   147	          const SizedBox(width: 8),
   148	          Expanded(
   149	            child: Column(
   150	              mainAxisAlignment: MainAxisAlignment.center,
   151	              crossAxisAlignment: CrossAxisAlignment.start,
   152	              children: [
   153	                Text(workflow.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
   154	                Text('${workflow.nodes.length} nodes · ${workflow.runCount} runs', style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted)),
   155	              ],
   156	            ),
   157	          ),
   158	          WorkflowStatusBadge(status: workflow.status),
   159	          const SizedBox(width: 12),
   160	          // AI Build button
   161	          OutlinedButton.icon(
   162	            onPressed: () => _showAiBuildDialog(context, workflow),
   163	            icon: const Icon(Icons.auto_awesome_rounded, size: 14),
   164	            label: const Text('AI Build', style: TextStyle(fontSize: 12)),
   165	          ),
   166	          const SizedBox(width: 8),
   167	          // Run button
   168	          ElevatedButton.icon(
   169	            onPressed: workflow.status == WorkflowStatus.running ? null : onRun,
   170	            icon: Icon(workflow.status == WorkflowStatus.running ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 15),
   171	            label: Text(workflow.status == WorkflowStatus.running ? 'Running...' : 'Run', style: const TextStyle(fontSize: 12)),
   172	          ),
   173	          const SizedBox(width: 8),
   174	          IconButton(icon: const Icon(Icons.save_rounded, size: 18), tooltip: 'Save', onPressed: () {}),
   175	          IconButton(icon: const Icon(Icons.more_vert_rounded, size: 18), tooltip: 'More', onPressed: () {}),
   176	        ],
   177	      ),
   178	    );
   179	  }
   180	
   181	  void _showAiBuildDialog(BuildContext context, WorkflowModel workflow) {
   182	    showDialog(
   183	      context: context,
   184	      builder: (ctx) => _AiBuildDialog(workflow: workflow),
   185	    );
   186	  }
   187	}
   188	
   189	class _AiBuildDialog extends StatefulWidget {
   190	  final WorkflowModel workflow;
   191	  const _AiBuildDialog({required this.workflow});
   192	
   193	  @override
   194	  State<_AiBuildDialog> createState() => _AiBuildDialogState();
   195	}
   196	
   197	class _AiBuildDialogState extends State<_AiBuildDialog> {
   198	  final _controller = TextEditingController();
   199	  bool _loading = false;
   200	
   201	  @override
   202	  void dispose() {
   203	    _controller.dispose();
   204	    super.dispose();
   205	  }
   206	
   207	  @override
   208	  Widget build(BuildContext context) {
   209	    return Dialog(
   210	      backgroundColor: WeaverColors.card,
   211	      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: WeaverColors.cardBorder)),
   212	      child: SizedBox(
   213	        width: 500,
   214	        child: Padding(
   215	          padding: const EdgeInsets.all(24),
   216	          child: Column(
   217	            mainAxisSize: MainAxisSize.min,
   218	            crossAxisAlignment: CrossAxisAlignment.start,
   219	            children: [
   220	              Row(
   221	                children: [
   222	                  Container(
   223	                    width: 36, height: 36,
   224	                    decoration: BoxDecoration(color: WeaverColors.accentGlow, borderRadius: BorderRadius.circular(8), border: Border.all(color: WeaverColors.accent.withOpacity(0.3))),
   225	                    child: const Center(child: Icon(Icons.auto_awesome_rounded, color: WeaverColors.accent, size: 18)),
   226	                  ),
   227	                  const SizedBox(width: 12),
   228	                  const Column(
   229	                    crossAxisAlignment: CrossAxisAlignment.start,
   230	                    children: [
   231	                      Text('AI Workflow Builder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
   232	                      Text('Describe what you want to automate', style: TextStyle(fontSize: 12, color: WeaverColors.textMuted)),
   233	                    ],
   234	                  ),
   235	                ],
   236	              ),
   237	              const SizedBox(height: 20),
   238	              TextField(
   239	                controller: _controller,
   240	                maxLines: 4,
   241	                autofocus: true,
   242	                style: const TextStyle(fontSize: 14, color: WeaverColors.textPrimary),
   243	                decoration: const InputDecoration(
   244	                  hintText: 'e.g. "Every morning at 8am, fetch my unread Gmail emails, filter out newsletters, summarize with AI, and post digest to Discord"',
   245	                  hintMaxLines: 3,
   246	                ),
   247	              ),
   248	              const SizedBox(height: 8),
   249	              const Text(
   250	                'The AI will create a workflow with the right nodes and connections for your description.',
   251	                style: TextStyle(fontSize: 12, color: WeaverColors.textMuted, height: 1.4),
   252	              ),
   253	              const SizedBox(height: 20),
   254	              // Quick templates
   255	              const Text('TEMPLATES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: WeaverColors.textMuted, letterSpacing: 0.8)),
   256	              const SizedBox(height: 8),
   257	              Wrap(
   258	                spacing: 6,
   259	                runSpacing: 6,
   260	                children: [
   261	                  _TemplateChip('Email to Discord digest', onTap: () => _controller.text = 'Fetch unread emails daily and post a summary to Discord'),
   262	                  _TemplateChip('Drive file backup', onTap: () => _controller.text = 'Watch Drive for new files and back them up with timestamps'),
   263	                  _TemplateChip('Web research report', onTap: () => _controller.text = 'Search the web on a topic and save AI-compiled report to Drive'),
   264	                ],
   265	              ),
   266	              const SizedBox(height: 20),
   267	              Row(
   268	                mainAxisAlignment: MainAxisAlignment.end,
   269	                children: [
   270	                  OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
   271	                  const SizedBox(width: 12),
   272	                  ElevatedButton.icon(
   273	                    onPressed: _loading ? null : () {
   274	                      setState(() => _loading = true);
   275	                      Future.delayed(const Duration(seconds: 2), () {
   276	                        Navigator.pop(context);
   277	                        ScaffoldMessenger.of(context).showSnackBar(
   278	                          const SnackBar(
   279	                            content: Text('✨ Workflow generated by AI!'),
   280	                            backgroundColor: WeaverColors.success,
   281	                            duration: Duration(seconds: 2),
   282	                          ),
   283	                        );
   284	                      });
   285	                    },
   286	                    icon: _loading
   287	                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: WeaverColors.background))
   288	                        : const Icon(Icons.auto_awesome_rounded, size: 15),
   289	                    label: Text(_loading ? 'Generating...' : 'Generate'),
   290	                  ),
   291	                ],
   292	              ),
   293	            ],
   294	          ),
   295	        ),
   296	      ),
   297	    );
   298	  }
   299	}
   300	
   301	class _TemplateChip extends StatelessWidget {
   302	  final String label;
   303	  final VoidCallback onTap;
   304	  const _TemplateChip(this.label, {required this.onTap});
   305	
   306	  @override
   307	  Widget build(BuildContext context) {
   308	    return GestureDetector(
   309	      onTap: onTap,
   310	      child: Container(
   311	        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
   312	        decoration: BoxDecoration(
   313	          color: WeaverColors.surface,
   314	          borderRadius: BorderRadius.circular(20),
   315	          border: Border.all(color: WeaverColors.cardBorder),
   316	        ),
   317	        child: Text(label, style: const TextStyle(fontSize: 11, color: WeaverColors.textSecondary)),
   318	      ),
   319	    );
   320	  }
   321	}
   322	
   323	// ── Grid Background ───────────────────────────────────────────────────────────
   324	class _GridBackground extends StatelessWidget {
   325	  @override
   326	  Widget build(BuildContext context) {
   327	    return CustomPaint(
   328	      painter: _GridPainter(),
   329	      size: Size.infinite,
   330	    );
   331	  }
   332	}
   333	
   334	class _GridPainter extends CustomPainter {
   335	  @override
   336	  void paint(Canvas canvas, Size size) {
   337	    final paint = Paint()
   338	      ..color = WeaverColors.cardBorder.withOpacity(0.3)
   339	      ..strokeWidth = 0.5;
   340	    const spacing = 28.0;
   341	    for (double x = 0; x < size.width; x += spacing) {
   342	      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
   343	    }
   344	    for (double y = 0; y < size.height; y += spacing) {
   345	      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
   346	    }
   347	    // Dot grid overlay
   348	    final dotPaint = Paint()
   349	      ..color = WeaverColors.cardBorder.withOpacity(0.6)
   350	      ..style = PaintingStyle.fill;
   351	    for (double x = 0; x < size.width; x += spacing) {
   352	      for (double y = 0; y < size.height; y += spacing) {
   353	        canvas.drawCircle(Offset(x, y), 1, dotPaint);
   354	      }
   355	    }
   356	  }
   357	
   358	  @override
   359	  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
   360	}
   361	
   362	// ── Edge Painter (silk thread bezier curves) ──────────────────────────────────
   363	class _EdgePainter extends CustomPainter {
   364	  final List<WorkflowNode> nodes;
   365	  final List<WorkflowEdge> edges;
   366	  final WorkflowStatus status;
   367	
   368	  const _EdgePainter({required this.nodes, required this.edges, required this.status});
   369	
   370	  @override
   371	  void paint(Canvas canvas, Size size) {
   372	    for (final edge in edges) {
   373	      final fromNode = nodes.where((n) => n.id == edge.fromNodeId).firstOrNull;
   374	      final toNode = nodes.where((n) => n.id == edge.toNodeId).firstOrNull;
   375	      if (fromNode == null || toNode == null) continue;
   376	
   377	      const nodeW = 180.0;
   378	      const nodeH = 60.0;
   379	
   380	      final start = Offset(fromNode.position.dx + nodeW, fromNode.position.dy + nodeH / 2);
   381	      final end = Offset(toNode.position.dx, toNode.position.dy + nodeH / 2);
   382	
   383	      final cpDist = (end.dx - start.dx).abs() * 0.5;
   384	      final cp1 = Offset(start.dx + cpDist, start.dy);
   385	      final cp2 = Offset(end.dx - cpDist, end.dy);
   386	
   387	      final path = Path()
   388	        ..moveTo(start.dx, start.dy)
   389	        ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);
   390	
   391	      // Glow effect
   392	      final glowPaint = Paint()
   393	        ..color = _edgeColor().withOpacity(0.15)
   394	        ..style = PaintingStyle.stroke
   395	        ..strokeWidth = 8
   396	        ..strokeCap = StrokeCap.round;
   397	      canvas.drawPath(path, glowPaint);
   398	
   399	      // Main line
   400	      final linePaint = Paint()
   401	        ..color = _edgeColor().withOpacity(0.7)
   402	        ..style = PaintingStyle.stroke
   403	        ..strokeWidth = 2
   404	        ..strokeCap = StrokeCap.round;
   405	      canvas.drawPath(path, linePaint);
   406	
   407	      // Arrow head
   408	      _drawArrow(canvas, cp2, end, _edgeColor().withOpacity(0.7));
   409	
   410	      // Port circles
   411	      _drawPort(canvas, start, fromNode.color);
   412	      _drawPort(canvas, end, toNode.color);
   413	    }
   414	  }
   415	
   416	  Color _edgeColor() => switch (status) {
   417	        WorkflowStatus.running => WeaverColors.info,
   418	        WorkflowStatus.success => WeaverColors.success,
   419	        WorkflowStatus.error => WeaverColors.error,
   420	        _ => WeaverColors.accent,
   421	      };
   422	
   423	  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
   424	    final dir = (to - from);
   425	    final len = dir.distance;
   426	    if (len == 0) return;
   427	    final norm = dir / len;
   428	    final perp = Offset(-norm.dy, norm.dx);
   429	    const arrowSize = 8.0;
   430	    final p1 = to - norm * arrowSize + perp * arrowSize * 0.5;
   431	    final p2 = to - norm * arrowSize - perp * arrowSize * 0.5;
   432	    final paint = Paint()
   433	      ..color = color
   434	      ..style = PaintingStyle.fill;
   435	    final path = Path()
   436	      ..moveTo(to.dx, to.dy)
   437	      ..lineTo(p1.dx, p1.dy)
   438	      ..lineTo(p2.dx, p2.dy)
   439	      ..close();
   440	    canvas.drawPath(path, paint);
   441	  }
   442	
   443	  void _drawPort(Canvas canvas, Offset center, Color color) {
   444	    canvas.drawCircle(center, 5, Paint()..color = color.withOpacity(0.8));
   445	    canvas.drawCircle(center, 5, Paint()..color = WeaverColors.background..style = PaintingStyle.stroke..strokeWidth = 1.5);
   446	  }
   447	
   448	  @override
   449	  bool shouldRepaint(covariant _EdgePainter old) =>
   450	      old.nodes != nodes || old.edges != edges || old.status != status;
   451	}
   452	
   453	// ── Draggable Node ────────────────────────────────────────────────────────────
   454	class _DraggableNode extends StatefulWidget {
   455	  final WorkflowNode node;
   456	  final bool isSelected;
   457	  final VoidCallback onTap;
   458	  final ValueChanged<Offset> onDragUpdate;
   459	
   460	  const _DraggableNode({
   461	    super.key,
   462	    required this.node,
   463	    required this.isSelected,
   464	    required this.onTap,
   465	    required this.onDragUpdate,
   466	  });
   467	
   468	  @override
   469	  State<_DraggableNode> createState() => _DraggableNodeState();
   470	}
   471	
   472	class _DraggableNodeState extends State<_DraggableNode> {
   473	  bool _dragging = false;
   474	  Offset _lastPos = Offset.zero;
   475	
   476	  @override
   477	  Widget build(BuildContext context) {
   478	    const w = 180.0;
   479	    const h = 60.0;
   480	
   481	    return Positioned(
   482	      left: widget.node.position.dx,
   483	      top: widget.node.position.dy,
   484	      child: GestureDetector(
   485	        onTap: widget.onTap,
   486	        onPanStart: (d) {
   487	          _dragging = true;
   488	          _lastPos = d.globalPosition;
   489	        },
   490	        onPanUpdate: (d) {
   491	          if (_dragging) {
   492	            final delta = d.globalPosition - _lastPos;
   493	            _lastPos = d.globalPosition;
   494	            widget.onDragUpdate(delta);
   495	          }
   496	        },
   497	        onPanEnd: (_) => _dragging = false,
   498	        child: AnimatedContainer(
   499	          duration: const Duration(milliseconds: 120),
   500	          width: w,
   501	          height: h,
   502	          decoration: BoxDecoration(
   503	            color: WeaverColors.card,
   504	            borderRadius: BorderRadius.circular(10),
   505	            border: Border.all(
   506	              color: widget.isSelected
   507	                  ? widget.node.color
   508	                  : widget.node.color.withOpacity(0.35),
   509	              width: widget.isSelected ? 2 : 1.5,
   510	            ),
   511	            boxShadow: [
   512	              BoxShadow(
   513	                color: widget.node.color.withOpacity(widget.isSelected ? 0.3 : 0.1),
   514	                blurRadius: widget.isSelected ? 12 : 6,
   515	                spreadRadius: widget.isSelected ? 1 : 0,
   516	              ),
   517	            ],
   518	          ),
   519	          child: Row(
   520	            children: [
   521	              // Color strip
   522	              Container(
   523	                width: 4,
   524	                decoration: BoxDecoration(
   525	                  color: widget.node.color,
   526	                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
   527	                ),
   528	              ),
   529	              const SizedBox(width: 10),
   530	              // Icon
   531	              Container(
   532	                width: 28, height: 28,
   533	                decoration: BoxDecoration(
   534	                  color: widget.node.color.withOpacity(0.12),
   535	                  borderRadius: BorderRadius.circular(7),
   536	                ),
   537	                child: Center(child: Text(widget.node.icon, style: const TextStyle(fontSize: 14))),
   538	              ),
   539	              const SizedBox(width: 8),
   540	              // Labels
   541	              Expanded(
   542	                child: Column(
   543	                  mainAxisAlignment: MainAxisAlignment.center,
   544	                  crossAxisAlignment: CrossAxisAlignment.start,
   545	                  children: [
   546	                    Text(
   547	                      widget.node.label,
   548	                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary),
   549	                      overflow: TextOverflow.ellipsis,
   550	                    ),
   551	                    Text(
   552	                      widget.node.toolName,
   553	                      style: TextStyle(fontSize: 10, color: widget.node.color, fontWeight: FontWeight.w500),
   554	                      overflow: TextOverflow.ellipsis,
   555	                    ),
   556	                  ],
   557	                ),
   558	              ),
   559	              // Type pill
   560	              Padding(
   561	                padding: const EdgeInsets.only(right: 6),
   562	                child: _NodeTypePill(type: widget.node.type, color: widget.node.color),
   563	              ),
   564	            ],
   565	          ),
   566	        ),
   567	      ),
   568	    );
   569	  }
   570	}
   571	
   572	class _NodeTypePill extends StatelessWidget {
   573	  final NodeType type;
   574	  final Color color;
   575	  const _NodeTypePill({required this.type, required this.color});
   576	
   577	  @override
   578	  Widget build(BuildContext context) {
   579	    final label = switch (type) {
   580	      NodeType.trigger => 'T',
   581	      NodeType.action => 'A',
   582	      NodeType.condition => 'C',
   583	      NodeType.transform => 'X',
   584	      NodeType.output => 'O',
   585	    };
   586	    return Container(
   587	      width: 18, height: 18,
   588	      decoration: BoxDecoration(
   589	        color: color.withOpacity(0.15),
   590	        shape: BoxShape.circle,
   591	        border: Border.all(color: color.withOpacity(0.4)),
   592	      ),
   593	      child: Center(child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color))),
   594	    );
   595	  }
   596	}
   597	
   598	// ── Zoom Controls ─────────────────────────────────────────────────────────────
   599	class _ZoomControls extends StatelessWidget {
   600	  final double scale;
   601	  final VoidCallback onZoomIn;
   602	  final VoidCallback onZoomOut;
   603	  final VoidCallback onReset;
   604	
   605	  const _ZoomControls({required this.scale, required this.onZoomIn, required this.onZoomOut, required this.onReset});
   606	
   607	  @override
   608	  Widget build(BuildContext context) {
   609	    return Container(
   610	      decoration: BoxDecoration(
   611	        color: WeaverColors.card,
   612	        borderRadius: BorderRadius.circular(8),
   613	        border: Border.all(color: WeaverColors.cardBorder),
   614	      ),
   615	      child: Column(
   616	        mainAxisSize: MainAxisSize.min,
   617	        children: [
   618	          _ZoomBtn(icon: Icons.add_rounded, onTap: onZoomIn),
   619	          Container(width: 32, height: 1, color: WeaverColors.cardBorder),
   620	          Padding(
   621	            padding: const EdgeInsets.symmetric(vertical: 4),
   622	            child: Text('${(scale * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: WeaverColors.textMuted, fontWeight: FontWeight.w600)),
   623	          ),
   624	          Container(width: 32, height: 1, color: WeaverColors.cardBorder),
   625	          _ZoomBtn(icon: Icons.remove_rounded, onTap: onZoomOut),
   626	          Container(width: 32, height: 1, color: WeaverColors.cardBorder),
   627	          _ZoomBtn(icon: Icons.fit_screen_rounded, onTap: onReset),
   628	        ],
   629	      ),
   630	    );
   631	  }
   632	}
   633	
   634	class _ZoomBtn extends StatelessWidget {
   635	  final IconData icon;
   636	  final VoidCallback onTap;
   637	  const _ZoomBtn({required this.icon, required this.onTap});
   638	
   639	  @override
   640	  Widget build(BuildContext context) {
   641	    return IconButton(
   642	      icon: Icon(icon, size: 16),
   643	      onPressed: onTap,
   644	      style: IconButton.styleFrom(minimumSize: const Size(32, 32), padding: EdgeInsets.zero),
   645	    );
   646	  }
   647	}
   648	
   649	// ── Add Node Button ───────────────────────────────────────────────────────────
   650	class _AddNodeButton extends StatelessWidget {
   651	  final String workflowId;
   652	  const _AddNodeButton({required this.workflowId});
   653	
   654	  @override
   655	  Widget build(BuildContext context) {
   656	    return ElevatedButton.icon(
   657	      onPressed: () => _showAddNodeSheet(context),
   658	      icon: const Icon(Icons.add_rounded, size: 15),
   659	      label: const Text('Add Node', style: TextStyle(fontSize: 12)),
   660	      style: ElevatedButton.styleFrom(
   661	        backgroundColor: WeaverColors.card,
   662	        foregroundColor: WeaverColors.textPrimary,
   663	        side: const BorderSide(color: WeaverColors.cardBorder),
   664	        elevation: 2,
   665	        shadowColor: WeaverColors.background,
   666	      ),
   667	    );
   668	  }
   669	
   670	  void _showAddNodeSheet(BuildContext context) {
   671	    showModalBottomSheet(
   672	      context: context,
   673	      backgroundColor: WeaverColors.card,
   674	      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
   675	      builder: (ctx) => _AddNodeSheet(workflowId: workflowId),
   676	    );
   677	  }
   678	}
   679	
   680	class _AddNodeSheet extends StatelessWidget {
   681	  final String workflowId;
   682	  const _AddNodeSheet({required this.workflowId});
   683	
   684	  static const _nodeTypes = [
   685	    (icon: '⏰', label: 'Schedule Trigger', type: NodeType.trigger, color: WeaverColors.triggerNode),
   686	    (icon: '▶️', label: 'Manual Trigger', type: NodeType.trigger, color: WeaverColors.triggerNode),
   687	    (icon: '🔗', label: 'Webhook Trigger', type: NodeType.trigger, color: WeaverColors.triggerNode),
   688	    (icon: '✉️', label: 'Gmail Action', type: NodeType.action, color: WeaverColors.cloudColor),
   689	    (icon: '🗂️', label: 'Drive Action', type: NodeType.action, color: WeaverColors.cloudColor),
   690	    (icon: '🎮', label: 'Discord Action', type: NodeType.action, color: WeaverColors.messagingColor),
   691	    (icon: '🗄️', label: 'Filesystem Action', type: NodeType.action, color: WeaverColors.filesColor),
   692	    (icon: '🌐', label: 'Web Search', type: NodeType.action, color: WeaverColors.accentBright),
   693	    (icon: '🔀', label: 'Condition / Filter', type: NodeType.condition, color: WeaverColors.conditionNode),
   694	    (icon: '🧠', label: 'AI Transform', type: NodeType.transform, color: WeaverColors.accentBright),
   695	    (icon: '🔄', label: 'Data Transform', type: NodeType.transform, color: WeaverColors.conditionNode),
   696	    (icon: '📤', label: 'Output / Response', type: NodeType.output, color: WeaverColors.outputNode),
   697	  ];
   698	
   699	  @override
   700	  Widget build(BuildContext context) {
   701	    return Column(
   702	      mainAxisSize: MainAxisSize.min,
   703	      children: [
   704	        Container(
   705	          margin: const EdgeInsets.symmetric(vertical: 10),
   706	          width: 36, height: 4,
   707	          decoration: BoxDecoration(color: WeaverColors.cardBorder, borderRadius: BorderRadius.circular(2)),
   708	        ),
   709	        const Padding(
   710	          padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
   711	          child: Row(
   712	            children: [
   713	              Text('Add Node', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
   714	            ],
   715	          ),
   716	        ),
   717	        SizedBox(
   718	          height: 300,
   719	          child: GridView.builder(
   720	            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
   721	            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
   722	              crossAxisCount: 3,
   723	              mainAxisSpacing: 8,
   724	              crossAxisSpacing: 8,
   725	              childAspectRatio: 1.4,
   726	            ),
   727	            itemCount: _nodeTypes.length,
   728	            itemBuilder: (ctx, i) {
   729	              final n = _nodeTypes[i];
   730	              return GestureDetector(
   731	                onTap: () {
   732	                  Navigator.pop(ctx);
   733	                  ScaffoldMessenger.of(ctx).showSnackBar(
   734	                    SnackBar(content: Text('Added "${n.label}" node'), duration: const Duration(seconds: 1), backgroundColor: WeaverColors.success),
   735	                  );
   736	                },
   737	                child: Container(
   738	                  decoration: BoxDecoration(
   739	                    color: WeaverColors.surface,
   740	                    borderRadius: BorderRadius.circular(10),
   741	                    border: Border.all(color: n.color.withOpacity(0.35)),
   742	                  ),
   743	                  child: Column(
   744	                    mainAxisAlignment: MainAxisAlignment.center,
   745	                    children: [
   746	                      Text(n.icon, style: const TextStyle(fontSize: 20)),
   747	                      const SizedBox(height: 5),
   748	                      Text(n.label, style: const TextStyle(fontSize: 10, color: WeaverColors.textSecondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2),
   749	                    ],
   750	                  ),
   751	                ),
   752	              );
   753	            },
   754	          ),
   755	        ),
   756	      ],
   757	    );
   758	  }
   759	}
   760	
   761	// ── Node Config Panel (right side when node selected) ─────────────────────────
   762	class _NodeConfigPanel extends StatelessWidget {
   763	  final WorkflowNode node;
   764	  final VoidCallback onClose;
   765	
   766	  const _NodeConfigPanel({required this.node, required this.onClose});
   767	
   768	  @override
   769	  Widget build(BuildContext context) {
   770	    return Container(
   771	      width: 280,
   772	      decoration: const BoxDecoration(
   773	        color: WeaverColors.surface,
   774	        border: Border(left: BorderSide(color: WeaverColors.cardBorder)),
   775	      ),
   776	      child: Column(
   777	        crossAxisAlignment: CrossAxisAlignment.start,
   778	        children: [
   779	          // Header
   780	          Container(
   781	            padding: const EdgeInsets.all(14),
   782	            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: WeaverColors.cardBorder))),
   783	            child: Row(
   784	              children: [
   785	                Container(
   786	                  width: 32, height: 32,
   787	                  decoration: BoxDecoration(color: node.color.withOpacity(0.12), borderRadius: BorderRadius.circular(7)),
   788	                  child: Center(child: Text(node.icon, style: const TextStyle(fontSize: 16))),
   789	                ),
   790	                const SizedBox(width: 10),
   791	                Expanded(
   792	                  child: Column(
   793	                    crossAxisAlignment: CrossAxisAlignment.start,
   794	                    children: [
   795	                      Text(node.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
   796	                      Text(node.toolName, style: TextStyle(fontSize: 11, color: node.color, fontWeight: FontWeight.w500)),
   797	                    ],
   798	                  ),
   799	                ),
   800	                IconButton(icon: const Icon(Icons.close_rounded, size: 16), onPressed: onClose, style: IconButton.styleFrom(minimumSize: const Size(28, 28), padding: EdgeInsets.zero)),
   801	              ],
   802	            ),
   803	          ),
   804	          // Config fields
   805	          Expanded(
   806	            child: ListView(
   807	              padding: const EdgeInsets.all(14),
   808	              children: [
   809	                // Node type badge
   810	                Row(
   811	                  children: [
   812	                    _ConfigLabel('NODE TYPE'),
   813	                    const Spacer(),
   814	                    Container(
   815	                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
   816	                      decoration: BoxDecoration(color: node.color.withOpacity(0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: node.color.withOpacity(0.3))),
   817	                      child: Text(_typeLabel(node.type), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: node.color)),
   818	                    ),
   819	                  ],
   820	                ),
   821	                const SizedBox(height: 16),
   822	
   823	                // Ports
   824	                _ConfigLabel('CONNECTIONS'),
   825	                const SizedBox(height: 8),
   826	                ...node.ports.map((port) => _PortRow(port: port, color: node.color)),
   827	                const SizedBox(height: 16),
   828	
   829	                // Config
   830	                if (node.config.isNotEmpty) ...[
   831	                  _ConfigLabel('CONFIGURATION'),
   832	                  const SizedBox(height: 8),
   833	                  ...node.config.entries.map((e) => _ConfigField(key_: e.key, value: e.value.toString())),
   834	                  const SizedBox(height: 16),
   835	                ],
   836	
   837	                // Actions
   838	                _ConfigLabel('ACTIONS'),
   839	                const SizedBox(height: 8),
   840	                OutlinedButton.icon(
   841	                  onPressed: () {},
   842	                  icon: const Icon(Icons.settings_rounded, size: 13),
   843	                  label: const Text('Configure Node', style: TextStyle(fontSize: 12)),
   844	                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
   845	                ),
   846	                const SizedBox(height: 6),
   847	                OutlinedButton.icon(
   848	                  onPressed: () {},
   849	                  icon: const Icon(Icons.play_arrow_rounded, size: 13),
   850	                  label: const Text('Test Node', style: TextStyle(fontSize: 12)),
   851	                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
   852	                ),
   853	                const SizedBox(height: 6),
   854	                OutlinedButton.icon(
   855	                  onPressed: () {},
   856	                  icon: const Icon(Icons.delete_outline_rounded, size: 13, color: WeaverColors.error),
   857	                  label: const Text('Remove Node', style: TextStyle(fontSize: 12, color: WeaverColors.error)),
   858	                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36), side: const BorderSide(color: WeaverColors.error)),
   859	                ),
   860	              ],
   861	            ),
   862	          ),
   863	        ],
   864	      ),
   865	    );
   866	  }
   867	
   868	  String _typeLabel(NodeType t) => switch (t) {
   869	        NodeType.trigger => 'Trigger',
   870	        NodeType.action => 'Action',
   871	        NodeType.condition => 'Condition',
   872	        NodeType.transform => 'Transform',
   873	        NodeType.output => 'Output',
   874	      };
   875	}
   876	
   877	class _ConfigLabel extends StatelessWidget {
   878	  final String label;
   879	  const _ConfigLabel(this.label);
   880	
   881	  @override
   882	  Widget build(BuildContext context) {
   883	    return Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: WeaverColors.textMuted, letterSpacing: 0.8));
   884	  }
   885	}
   886	
   887	class _PortRow extends StatelessWidget {
   888	  final WorkflowPort port;
   889	  final Color color;
   890	  const _PortRow({required this.port, required this.color});
   891	
   892	  @override
   893	  Widget build(BuildContext context) {
   894	    return Padding(
   895	      padding: const EdgeInsets.only(bottom: 6),
   896	      child: Row(
   897	        children: [
   898	          Icon(port.isInput ? Icons.input_rounded : Icons.output_rounded, size: 13, color: color.withOpacity(0.6)),
   899	          const SizedBox(width: 8),
   900	          Text(port.label, style: const TextStyle(fontSize: 12, color: WeaverColors.textSecondary)),
   901	          const Spacer(),
   902	          Container(
   903	            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
   904	            decoration: BoxDecoration(color: WeaverColors.surface, borderRadius: BorderRadius.circular(4)),
   905	            child: Text(port.isInput ? 'IN' : 'OUT', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: WeaverColors.textMuted)),
   906	          ),
   907	        ],
   908	      ),
   909	    );
   910	  }
   911	}
   912	
   913	class _ConfigField extends StatelessWidget {
   914	  final String key_;
   915	  final String value;
   916	  const _ConfigField({required this.key_, required this.value});
   917	
   918	  @override
   919	  Widget build(BuildContext context) {
   920	    return Padding(
   921	      padding: const EdgeInsets.only(bottom: 8),
   922	      child: Column(
   923	        crossAxisAlignment: CrossAxisAlignment.start,
   924	        children: [
   925	          Text(key_, style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted, fontWeight: FontWeight.w500)),
   926	          const SizedBox(height: 4),
   927	          TextField(
   928	            controller: TextEditingController(text: value),
   929	            style: const TextStyle(fontSize: 12, color: WeaverColors.textPrimary, fontFamily: 'JetBrainsMono'),
   930	            decoration: const InputDecoration(isDense: true),
   931	          ),
   932	        ],
   933	      ),
   934	    );
   935	  }
   936	}
```

## frontend/lib/widgets/workflow/workflow_list_panel.dart

```dart
     1	import 'package:flutter/material.dart';
     2	import 'package:flutter_animate/flutter_animate.dart';
     3	import 'package:provider/provider.dart';
     4	import '../../providers/providers.dart';
     5	import '../../theme/colors.dart';
     6	import '../../models/models.dart';
     7	import '../common/common_widgets.dart';
     8	
     9	// ── Workflow List Panel (in right sidebar) ────────────────────────────────────
    10	class WorkflowListPanel extends StatelessWidget {
    11	  const WorkflowListPanel({super.key});
    12	
    13	  @override
    14	  Widget build(BuildContext context) {
    15	    return Consumer2<WorkflowsProvider, ChatProvider>(
    16	      builder: (context, wfProv, chatProv, _) {
    17	        final sessionId = chatProv.activeSessionId;
    18	        final sessionWorkflows = sessionId != null
    19	            ? wfProv.workflowsForSession(sessionId)
    20	            : <WorkflowModel>[];
    21	        final allOther = wfProv.workflows.where((w) => w.chatSessionId != sessionId).toList();
    22	
    23	        return Column(
    24	          children: [
    25	            // Create workflow button
    26	            Padding(
    27	              padding: const EdgeInsets.all(12),
    28	              child: SizedBox(
    29	                width: double.infinity,
    30	                child: ElevatedButton.icon(
    31	                  onPressed: wfProv.toggleCreateDialog,
    32	                  icon: const Icon(Icons.add_rounded, size: 15),
    33	                  label: const Text('Create Workflow', style: TextStyle(fontSize: 13)),
    34	                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
    35	                ),
    36	              ),
    37	            ),
    38	
    39	            // Create dialog
    40	            if (wfProv.showCreateDialog)
    41	              _CreateWorkflowDialog(chatSessionId: sessionId ?? 'chat-1'),
    42	
    43	            // Stats bar
    44	            Padding(
    45	              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    46	              child: Row(
    47	                children: [
    48	                  _StatChip(label: '${wfProv.totalWorkflowCount} total', color: WeaverColors.textMuted),
    49	                  const SizedBox(width: 6),
    50	                  _StatChip(label: '${wfProv.activeWorkflowCount} running', color: WeaverColors.info),
    51	                ],
    52	              ),
    53	            ),
    54	
    55	            Container(height: 1, color: WeaverColors.cardBorder.withOpacity(0.4)),
    56	
    57	            Expanded(
    58	              child: ListView(
    59	                padding: const EdgeInsets.all(10),
    60	                children: [
    61	                  if (sessionWorkflows.isNotEmpty) ...[
    62	                    const _PanelLabel('This Chat'),
    63	                    ...sessionWorkflows.map((w) => _WorkflowMiniCard(workflow: w)),
    64	                    const SizedBox(height: 12),
    65	                  ],
    66	                  if (allOther.isNotEmpty) ...[
    67	                    const _PanelLabel('Other Chats'),
    68	                    ...allOther.map((w) => _WorkflowMiniCard(workflow: w)),
    69	                  ],
    70	                ],
    71	              ),
    72	            ),
    73	          ],
    74	        );
    75	      },
    76	    );
    77	  }
    78	}
    79	
    80	class _CreateWorkflowDialog extends StatefulWidget {
    81	  final String chatSessionId;
    82	  const _CreateWorkflowDialog({required this.chatSessionId});
    83	
    84	  @override
    85	  State<_CreateWorkflowDialog> createState() => _CreateWorkflowDialogState();
    86	}
    87	
    88	class _CreateWorkflowDialogState extends State<_CreateWorkflowDialog> {
    89	  final _controller = TextEditingController();
    90	
    91	  @override
    92	  void dispose() {
    93	    _controller.dispose();
    94	    super.dispose();
    95	  }
    96	
    97	  @override
    98	  Widget build(BuildContext context) {
    99	    return Container(
   100	      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
   101	      padding: const EdgeInsets.all(14),
   102	      decoration: BoxDecoration(
   103	        color: WeaverColors.card,
   104	        borderRadius: BorderRadius.circular(10),
   105	        border: Border.all(color: WeaverColors.accent.withOpacity(0.3)),
   106	      ),
   107	      child: Column(
   108	        crossAxisAlignment: CrossAxisAlignment.start,
   109	        mainAxisSize: MainAxisSize.min,
   110	        children: [
   111	          const Text('New Workflow', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WeaverColors.textPrimary)),
   112	          const SizedBox(height: 10),
   113	          TextField(
   114	            controller: _controller,
   115	            autofocus: true,
   116	            style: const TextStyle(fontSize: 13),
   117	            decoration: const InputDecoration(hintText: 'Workflow name...', isDense: true),
   118	          ),
   119	          const SizedBox(height: 10),
   120	          Row(
   121	            children: [
   122	              Expanded(
   123	                child: OutlinedButton(
   124	                  onPressed: () => Provider.of<WorkflowsProvider>(context, listen: false).toggleCreateDialog(),
   125	                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
   126	                ),
   127	              ),
   128	              const SizedBox(width: 8),
   129	              Expanded(
   130	                child: ElevatedButton(
   131	                  onPressed: () {
   132	                    if (_controller.text.trim().isNotEmpty) {
   133	                      Provider.of<WorkflowsProvider>(context, listen: false)
   134	                          .createWorkflow(_controller.text.trim(), widget.chatSessionId);
   135	                      // Open the canvas
   136	                      Provider.of<AppState>(context, listen: false).setNavIndex(2);
   137	                    }
   138	                  },
   139	                  child: const Text('Create', style: TextStyle(fontSize: 12)),
   140	                ),
   141	              ),
   142	            ],
   143	          ),
   144	        ],
   145	      ),
   146	    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1);
   147	  }
   148	}
   149	
   150	class _WorkflowMiniCard extends StatefulWidget {
   151	  final WorkflowModel workflow;
   152	  const _WorkflowMiniCard({required this.workflow});
   153	
   154	  @override
   155	  State<_WorkflowMiniCard> createState() => _WorkflowMiniCardState();
   156	}
   157	
   158	class _WorkflowMiniCardState extends State<_WorkflowMiniCard> {
   159	  bool _hovered = false;
   160	
   161	  @override
   162	  Widget build(BuildContext context) {
   163	    return MouseRegion(
   164	      onEnter: (_) => setState(() => _hovered = true),
   165	      onExit: (_) => setState(() => _hovered = false),
   166	      cursor: SystemMouseCursors.click,
   167	      child: GestureDetector(
   168	        onTap: () {
   169	          Provider.of<WorkflowsProvider>(context, listen: false).setOpenWorkflow(widget.workflow.id);
   170	          Provider.of<AppState>(context, listen: false).setNavIndex(2);
   171	        },
   172	        child: AnimatedContainer(
   173	          duration: const Duration(milliseconds: 120),
   174	          margin: const EdgeInsets.only(bottom: 6),
   175	          padding: const EdgeInsets.all(10),
   176	          decoration: BoxDecoration(
   177	            color: _hovered ? WeaverColors.cardHover : WeaverColors.card,
   178	            borderRadius: BorderRadius.circular(8),
   179	            border: Border.all(color: _hovered ? WeaverColors.accent.withOpacity(0.3) : WeaverColors.cardBorder),
   180	          ),
   181	          child: Column(
   182	            crossAxisAlignment: CrossAxisAlignment.start,
   183	            children: [
   184	              Row(
   185	                children: [
   186	                  Expanded(
   187	                    child: Text(widget.workflow.name,
   188	                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: WeaverColors.textPrimary),
   189	                        maxLines: 1, overflow: TextOverflow.ellipsis),
   190	                  ),
   191	                  WorkflowStatusBadge(status: widget.workflow.status),
   192	                ],
   193	              ),
   194	              const SizedBox(height: 4),
   195	              Row(
   196	                children: [
   197	                  Icon(Icons.hub_rounded, size: 11, color: WeaverColors.textMuted),
   198	                  const SizedBox(width: 4),
   199	                  Text('${widget.workflow.nodes.length} nodes', style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted)),
   200	                  const SizedBox(width: 8),
   201	                  if (widget.workflow.lastRun != null) ...[
   202	                    Icon(Icons.play_circle_outline_rounded, size: 11, color: WeaverColors.textMuted),
   203	                    const SizedBox(width: 4),
   204	                    Text(_formatTime(widget.workflow.lastRun!), style: const TextStyle(fontSize: 11, color: WeaverColors.textMuted)),
   205	                  ],
   206	                ],
   207	              ),
   208	            ],
   209	          ),
   210	        ),
   211	      ),
   212	    );
   213	  }
   214	
   215	  String _formatTime(DateTime dt) {
   216	    final diff = DateTime.now().difference(dt);
   217	    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
   218	    if (diff.inHours < 24) return '${diff.inHours}h ago';
   219	    return '${diff.inDays}d ago';
   220	  }
   221	}
   222	
   223	class _PanelLabel extends StatelessWidget {
   224	  final String label;
   225	  const _PanelLabel(this.label);
   226	
   227	  @override
   228	  Widget build(BuildContext context) {
   229	    return Padding(
   230	      padding: const EdgeInsets.fromLTRB(2, 4, 2, 6),
   231	      child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: WeaverColors.textDisabled, letterSpacing: 0.8)),
   232	    );
   233	  }
   234	}
   235	
   236	class _StatChip extends StatelessWidget {
   237	  final String label;
   238	  final Color color;
   239	  const _StatChip({required this.label, required this.color});
   240	
   241	  @override
   242	  Widget build(BuildContext context) {
   243	    return Container(
   244	      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
   245	      decoration: BoxDecoration(
   246	        color: color.withOpacity(0.1),
   247	        borderRadius: BorderRadius.circular(12),
   248	        border: Border.all(color: color.withOpacity(0.3)),
   249	      ),
   250	      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
   251	    );
   252	  }
   253	}
```

