# Learning Path (Backend + Frontend)

This project is best learned in loops: first architecture, then one full user flow, then deeper internals.

## Phase 1: Big Picture

1. Read [backend/guide.md](backend/guide.md) sections:
   - "System Overview"
   - "Backend Directory Breakdown"
2. Read [frontend/guide.md](frontend/guide.md) sections:
   - "System Overview"
   - "Frontend Directory Breakdown"
Outcome:
- You should know where API routes live, where provider state lives, and how UI talks to backend.

## Phase 2: First End-to-End Flow (Chat)

1. Backend:
   - Read `backend/app/api/v1/routes/chat.py` in [reference/backend-source-reference.md](reference/backend-source-reference.md).
   - Read `backend/app/services/llm.py` in [reference/backend-source-reference.md](reference/backend-source-reference.md).
2. Frontend:
   - Read `frontend/lib/providers/providers.dart` in [reference/frontend-source-reference.md](reference/frontend-source-reference.md).
   - Read `frontend/lib/widgets/chat/chat_view.dart` in [reference/frontend-source-reference.md](reference/frontend-source-reference.md).

Outcome:
- You should understand how a user message is created in UI, sent to backend, and rendered back.

## Phase 3: Tool Integration Flow

1. Backend:
   - `backend/app/api/v1/routes/tools.py`
   - `backend/app/api/v1/routes/auth.py`
   - `backend/app/services/providers/*`
2. Frontend:
   - `frontend/lib/widgets/tool_card/tool_card.dart`
   - `frontend/lib/screens/settings_screen.dart`
   - `frontend/lib/services/backend_api.dart`

Outcome:
- You should understand OAuth state, tool card state, and tool action execution.

## Phase 4: Data Contracts and Models

1. Read backend schemas:
   - `backend/app/schemas/*.py`
2. Read frontend models:
   - `frontend/lib/models/models.dart`

Outcome:
- You should map every API response shape to frontend model usage.

## Phase 5: Persistence and Reliability

1. Backend DB and migrations:
   - `backend/app/db/*`
2. Frontend local persistence:
   - `frontend/lib/services/backend_api.dart`
3. Prompt and payload safety:
   - `backend/app/services/llm.py`

Outcome:
- You should understand where state is durable and where it is transient.

## How To Study A Single File

Use this method for each file in source reference:

1. Read imports first and identify dependencies.
2. List top-level constants and classes.
3. For each function/method:
   - inputs
   - outputs
   - side effects
   - error handling
4. Trace where it is called from.
5. Run one manual test that exercises that code path.

## Practice Exercises

1. Add one new backend route and consume it in frontend.
2. Add one new tool capability and expose it in the tool card.
3. Add one validation rule in backend schema and update frontend to match.