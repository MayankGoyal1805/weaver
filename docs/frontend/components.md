# Frontend Component Overview

The Weaver UI is built from a collection of focused, reusable widgets. This modular approach makes the codebase easy to maintain and expand.

## Core Directories

- `lib/screens/`: High-level page layouts.
- `lib/widgets/`:
    - `chat/`: Everything related to the AI conversation interface.
    - `dashboard/`: Stats, summaries, and activity feeds.
    - `workflow/`: The node-based automation canvas.
    - `tool_card/`: The specialized UI for viewing and managing tools.
    - `common/`: Reusable buttons, inputs, and cards.

---

## Key Components

### 1. `ChatView` & `ChatMessage`
- **Location**: `lib/widgets/chat/`
- **Purpose**: Handles the rendering of the conversation history. `ChatMessage` uses `flutter_markdown` to display rich text and special blocks for tool execution results.

### 2. `WorkflowCanvas`
- **Location**: `lib/widgets/workflow/`
- **Purpose**: A custom-painted interactive area where users can drag and drop nodes to create automation flows. It uses `GestureDetector` and `CustomPainter` for high performance.

### 3. `ToolCard`
- **Location**: `lib/widgets/tool_card/`
- **Purpose**: The "star" of Weaver. Each card displays a tool's name, description, and authentication status. It provides "Connect" buttons that trigger OAuth flows.

### 4. `AppProvider`
- **Location**: `lib/providers/`
- **Purpose**: Not a UI component, but the "glue" that connects the UI to the backend. It holds the active state for the entire app.

---

## Design Tokens

Weaver uses a centralized theme configuration in `lib/theme/` to ensure visual consistency.

- **Colors**: A modern, dark-mode focused palette with vibrant accents (Vivid Blue, Deep Indigo).
- **Typography**: Uses the "Inter" font for UI elements and "Outfit" for headings.
- **Spacing**: Standardized gaps (4px, 8px, 16px, 24px) are used throughout the layout.

---

## Interaction Model

- **Hover Effects**: Most buttons and cards have subtle scale or color transitions on hover to feel responsive.
- **Micro-animations**: Entry animations (`FadeIn`, `SlideIn`) are applied to new messages and tool results to guide the user's eye.
- **Loading States**: Shimmer effects or animated loaders are shown while waiting for backend responses.
