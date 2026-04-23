# Source Code Guide: `lib/widgets/workflow/workflow_canvas.dart`

The `WorkflowCanvas` is a high-fidelity, n8n-style visual builder. It allows users to drag nodes, connect them with bezier curves, and configure automation logic.

[Note: This file is nearly 1000 lines. This guide covers the core architectural components.]

---

## 1. Canvas Transformation (Lines 21-88)

The canvas supports **Panning** and **Zooming**.
- **`_scale`**: Controls the zoom level (0.3x to 3.0x).
- **`_offset`**: Controls the current scroll position.
- **`Transform` (Line 51)**: The core widget that applies these values to everything inside the canvas.
- **`GestureDetector` (Line 44)**: Captures mouse drag events to update the `_offset`.

---

## 2. Drawing the Edges (Lines 363-451)

The "Silk Thread" connections between nodes are drawn using a **`CustomPainter`**.
- **Bezier Curves (Line 387)**: Uses `path.cubicTo` to create smooth, curved lines instead of straight ones.
- **Dynamic Colors**: The edge color changes based on the workflow's status (blue for running, green for success, red for error).
- **Glow Effect (Line 392)**: Draws a thicker, semi-transparent line behind the main line to create a "glowing" neon effect.

---

## 3. Draggable Nodes (Lines 454-569)

Each node is a `Positioned` widget inside a `Stack`.
- **Drag Logic (Line 486)**: When a user drags a node, it updates the `WorkflowsProvider` with the new coordinates.
- **Selection (Line 506)**: Clicking a node highlights it with a thicker border and opens the `_NodeConfigPanel`.
- **Visuals**: Each node type (Trigger, Action, etc.) has its own color scheme and icon.

---

## 4. AI Workflow Builder (Lines 189-300)

One of Weaver's standout features is the **AI Build** dialog.
- Users describe their automation goal in plain English.
- The intent is sent to the backend, which returns a structured list of nodes and connections.
- The UI then "renders" this new workflow onto the canvas.

---

## 5. Grid Background (Lines 324-360)

The canvas isn't just a blank white space. It features a technical "Dot Grid" drawn with a `CustomPainter`. This helps users align their nodes and makes the builder feel like a professional engineering tool.

---

## Key Design Patterns

- **Painter Pattern**: Complex graphics (grid, curves, arrows) are offloaded to `CustomPainter` to keep the widget tree clean and performance high.
- **Relative Coordinates**: All node positions are stored as absolute offsets but are rendered relative to the canvas's current zoom and pan state.

## Key References
- [Flutter CustomPaint widget](https://api.flutter.dev/flutter/widgets/CustomPaint-class.html)
- [Flutter Matrix4 (for transformations)](https://api.flutter.dev/flutter/vector_math/Matrix4-class.html)
- [Bezier Curves Explained](https://javascript.info/bezier-curve)
