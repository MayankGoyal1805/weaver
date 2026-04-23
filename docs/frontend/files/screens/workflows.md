# Source Code Guide: `lib/screens/workflows_screen.dart`

The `WorkflowsScreen` serves as the command center for automation. It manages two distinct views: the **Workflows Dashboard** (list of all automations) and the **Workflow Canvas** (the visual builder).

---

## State-Driven View Switching (Lines 10-26)

The screen uses a simple `if` statement within a `Consumer<WorkflowsProvider>` to decide what to show:
- If `wfProv.openWorkflow` is NOT null, it displays the `WorkflowCanvas`.
- Otherwise, it displays the `_WorkflowsDashboard`.

---

## The Dashboard View (Lines 28-63)

### 1. Grouping Logic (Lines 33-37)
Before rendering, the dashboard groups workflows by their `chatSessionId`. This keeps the UI organized, especially when you have many automations linked to different conversations.

### 2. Header & Stats (Lines 65-111)
- Shows the total count of workflows and how many are currently active.
- Includes **Filter Chips** (Line 113) that allow users to quickly find "Active" or "Draft" workflows.
- features a "New Workflow" button that opens an overlay.

### 3. Workflow Cards (Lines 202-289)
Each automation is represented by a `_WorkflowCard`:
- **Mini Preview (Line 299)**: Shows the icons of the first 4 nodes in the workflow, giving a quick visual hint of what it does.
- **Status Badge (Line 272)**: Shows if the workflow is "Running", "Success", or has an "Error".
- **Toggle (Line 254)**: Allows enabling or disabling the workflow without opening it.

---

## Create Workflow Overlay (Lines 347-434)

When creating a new workflow, the user must:
1.  **Name it**: Give the automation a clear name.
2.  **Link it**: Select which Chat Session this workflow belongs to.
This linkage is important because workflows often use context or variables from a specific conversation.

---

## Why this design?

- **Visual Cues**: Using the same icons from the canvas on the dashboard cards creates a strong mental link between the list and the builder.
- **Contextual Organization**: Grouping by chat session reflects how users actually use the tool (building automations to solve specific problems discussed in a chat).

## Key References
- [Flutter GridView widget](https://api.flutter.dev/flutter/widgets/GridView-class.html)
- [Flutter Dialog class](https://api.flutter.dev/flutter/material/Dialog-class.html)
