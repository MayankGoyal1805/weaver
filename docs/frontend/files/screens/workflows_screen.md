# Source Code Guide: `lib/screens/workflows_screen.dart`

The `WorkflowsScreen` is the primary interface for managing and building automation workflows. It features a dashboard to see all your workflows and a "Canvas" where you can visually arrange tools.

---

## 1. Complete Code (Highlights)

```dart
class WorkflowsScreen extends StatelessWidget {
  const WorkflowsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Listen for changes in the WorkflowsProvider
    return Consumer<WorkflowsProvider>(
      builder: (context, wfProv, _) {
        // 2. Logic: Should we show the list or the editor?
        if (wfProv.openWorkflow != null) {
          return WorkflowCanvas(workflow: wfProv.openWorkflow!);
        }
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
        // 3. Group workflows by their parent chat session
        final Map<String, List<WorkflowModel>> bySession = {};
        for (final wf in wfProv.workflows) {
          bySession.putIfAbsent(wf.chatSessionId, () => []).add(wf);
        }

        return Column(
          children: [
            _WorkflowsHeader(wfProv: wfProv, chatProv: chatProv),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: bySession.entries.map((entry) {
                  final session = chatProv.sessions.where((s) => s.id == entry.key).firstOrNull;
                  return _WorkflowGroup(
                    sessionTitle: session?.title ?? 'Unknown Chat',
                    workflows: entry.value,
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
```

---

## 2. Line-by-Line Deep Dive

### Dynamic Routing (Conditional UI)

- **Lines 15-24**: `Consumer<WorkflowsProvider>`
  - This is a very common Flutter pattern. Instead of using a separate "Page Router," we just check the state.
  - If `wfProv.openWorkflow` is NOT null, it means the user clicked on a workflow card, so we swap the entire screen content for the `WorkflowCanvas`.

### Dashboard Organization

- **Lines 31-37**: `Consumer2` and Grouping.
  - `Consumer2` lets us listen to **two** providers at once (Workflows and Chat).
  - We use a Python-style loop (`for (final wf in wfProv.workflows)`) to group workflows. This is because every workflow is created *during* a chat session, so it makes sense to group them that way.

### The Header (`_WorkflowsHeader`)

- **Lines 95-106**: "New Workflow" Button.
  - When clicked, it calls `wfProv.toggleCreateDialog()` and shows a `showDialog` overlay.
  - This is where the user gives their workflow a name and links it to a chat session.

### Animation

- **Line 54**: `.animate().fadeIn(duration: 300.ms)`
  - We use the `flutter_animate` library to give the app a premium feel. When the dashboard loads, the groups don't just "pop" in—they gently fade into view.

---

## 3. Educational Callouts

> [!TIP]
> **Private Classes (`_`)**:
> Notice that `_WorkflowsDashboard` starts with an underscore. This means this class can ONLY be used within this file. This is a great way to hide internal UI details from the rest of the app.

---

## Key References
- [Flutter: Consumer Widget](https://pub.dev/documentation/provider/latest/provider/Consumer-class.html)
- [Flutter: ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html)
- [Flutter Animate Library](https://pub.dev/packages/flutter_animate)
