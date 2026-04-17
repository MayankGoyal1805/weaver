# CLI Usage

A local CLI is available for backend testing.

Command entrypoint:
- `uv run weaver-cli`

## Commands

### 1. Run API server
- `uv run weaver-cli runserver --host 0.0.0.0 --port 8000`

### 2. Health check
- `uv run weaver-cli health --base-url http://localhost:8000`

### 3. Prompt test (LLM)
- `uv run weaver-cli chat "Give me 3 ideas for Weaver automations"`
- Optional model override:
  - `uv run weaver-cli chat "hello" --model-name gpt-4.1-mini`

### 4. Tool catalog
- `uv run weaver-cli catalog`

### 5. Execute tool
- `uv run weaver-cli execute-tool filesystem.list_directory --arguments-json '{"path":"."}'`
- With run id:
  - `uv run weaver-cli execute-tool filesystem.read_file --run-id demo-1 --arguments-json '{"path":"notes.txt"}'`

## Required LLM Environment Variables

- `LLM_MODEL_NAME`
- `LLM_API_KEY`
- `LLM_BASE_URL`

Recommended OpenAI-compatible pattern:
- `LLM_BASE_URL` should be a base API path like `https://api.openai.com/v1`
- backend calls `<LLM_BASE_URL>/chat/completions`
