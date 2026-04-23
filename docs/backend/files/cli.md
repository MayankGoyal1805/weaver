# Source Code Guide: `app/cli.py`

The `cli.py` file provides a powerful Command Line Interface (CLI) for interacting with the Weaver backend without the Flutter UI. It is essential for testing, debugging, and advanced automation tasks.

## Key Features
- **Run Server**: Quickly start the FastAPI backend.
- **Health Check**: Verify the backend status.
- **Prompt Testing**: Send single prompts or chat with the agent directly from the terminal.
- **Tool Execution**: Manually trigger any registered tool.
- **OAuth Management**: Handle Google and Discord authentication flows.
- **Auto-Start**: Most commands will automatically start a local server if one isn't running.

---

## Line-by-Line Explanation

### Imports and Constants (Lines 1-15)
- Standard Python libraries like `argparse` (for CLI arguments), `subprocess` (to run the server), and `httpx` (for making API requests).
- **Line 15**: `DEFAULT_BASE_URL` is set to `http://127.0.0.1:8000`.

### CLI Parser Construction (Lines 18-101)
- **`_build_parser()`**: This function defines the entire CLI structure using `argparse`.
- It creates sub-commands like `runserver`, `health`, `chat`, `catalog`, `execute-tool`, and provider-specific commands like `google-drive`.

### Helper Utilities (Lines 104-176)
- **`_request_json` (Line 104)**: A generic wrapper around `httpx` for making JSON requests to the backend.
- **`_ensure_server` (Line 156)**: Checks if the server is healthy; if not, and `no_auto_start` is false, it calls `_start_local_server`.
- **`_start_local_server` (Line 121)**: Spawns a new process running `uvicorn` and waits for it to become healthy.

### Tool Orchestration (Lines 230-318)
- **`_execute_tool` (Line 230)**: Sends a POST request to the backend's tool execution endpoint.
- **`_tool_aware_prompt` (Line 245)**: Implements a simplified version of the agent orchestration logic. It detects intent (like "fetch gmail") and executes the necessary tools before calling the LLM.

### Main Entry Point (Lines 321-520)
- **`main()`**: The core logic that parses arguments and dispatches to the correct helper function.
- It handles the logic for each command, printing the JSON results to the terminal.

---

## Example Usage

### 1. Check Health
```bash
python app/cli.py health
```

### 2. Simple Prompt
```bash
python app/cli.py prompt "Hello, who are you?"
```

### 3. Tool-Aware Prompt (Fetch Gmail)
```bash
python app/cli.py prompt "fetch the latest gmail" --allow-tools
```

### 4. Execute a File Tool
```bash
python app/cli.py execute-tool filesystem.list_directory --arguments-json '{"path": "."}'
```

---

## Key References
- [Python argparse Documentation](https://docs.python.org/3/library/argparse.html)
- [HTTPX Documentation](https://www.python-httpx.org/)
- [Uvicorn Documentation](https://www.uvicorn.org/)
