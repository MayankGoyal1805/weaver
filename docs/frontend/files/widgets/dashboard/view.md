# Source Code Guide: `lib/widgets/dashboard/dashboard_view.dart`

The `DashboardView` provides a high-level overview of the user's workspace, including stats, tool status, and recent activity.

---

## 1. The Layout (Lines 15-57)

The view uses a `SingleChildScrollView` with a two-column layout on larger screens:
- **Left Column (flex: 3)**: Contains the most important data—`ToolStatusCard` and `RecentActivityCard`.
- **Right Column (flex: 2)**: Contains secondary information—`WorkflowsCard` and `AgentCard`.

---

## 2. Stats Row (Lines 103-153)

- Uses `Consumer3<ChatProvider, ToolsProvider, WorkflowsProvider>` to aggregate data from across the app.
- Displays four key metrics: Active Chats, Connected Tools, Total Workflows, and Running Workflows.
- **Visuals**: Each card uses a subtle gradient and an icon corresponding to its data type.

---

## 3. Tool Status Card (Lines 218-312)

- Provides a quick glance at every tool's health.
- **Usage Progress Bar (Line 282)**: A custom-built progress bar that shows how much a tool has been used relative to a maximum threshold. This is a great example of using `FractionallySizedBox` for custom UI elements.

---

## 4. Recent Activity (Lines 314-442)

- Displays a timeline of events.
- **Timeline UI**: Built using a `Column` of `_ActivityRow` widgets. Each row has a circular icon and a vertical line connecting it to the next one, creating a clean "Activity Feed" look.

---

## 5. Agent Card (Lines 542-651)

- Summarizes the current AI configuration.
- Displays technical details like the model name, max tokens, and temperature.
- Includes a "Configure" button that takes the user directly to the Model settings.

---

## Design Philosophy

- **Glanceability**: Important numbers are large and bold.
- **Interactivity**: Clicking "Manage" or "View All" on any card navigates the user to the full-page version of that feature.
- **Modernity**: Extensive use of `flutter_animate` ensures that the dashboard "assembles" itself smoothly when the user first opens it.

## Key References
- [FL Chart Package](https://pub.dev/packages/fl_chart) (Used for more complex data visualizations)
- [Flutter Row flex property](https://api.flutter.dev/flutter/widgets/Flexible/flex.html)
