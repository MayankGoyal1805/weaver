# Source Code Guide: `app/services/providers/filesystem/service.py`

This file is a **Security Sandbox** for file operations. It allows the AI agent to read and write files, but strictly limits it to a specific folder (the "Allowed Root"). This prevents the agent from accidentally deleting your system files or reading private data.

---

## 1. Complete Code (Highlights)

```python
from pathlib import Path
import shutil
from app.core.config import get_settings

class FilesystemToolService:
    def __init__(self) -> None:
        settings = get_settings()
        # 1. Initialize the sandbox folder
        self.allowed_root = Path(settings.allowed_file_root).resolve()
        self.allowed_root.mkdir(parents=True, exist_ok=True)

    def _resolve(self, path: str) -> Path:
        # 2. Security Check (Sandbox Enforcement)
        candidate = (self.allowed_root / path).resolve()
        if not str(candidate).startswith(str(self.allowed_root)):
            raise FileSandboxError("Path escapes allowed file root")
        return candidate

    def list_directory(self, path: str = ".") -> dict:
        directory = self._resolve(path)
        # ... logic to list files
        return {"path": str(directory), "entries": entries}

    def write_file(self, path: str, content: str, ...) -> dict:
        target = self._resolve(path)
        target.write_text(content, encoding="utf-8")
        return {"path": str(target), "bytes_written": len(content)}
```

---

## 2. Line-by-Line Deep Dive

### The Sandbox Guard

- **Lines 17-21**: `_resolve(path)`
  - This is the **most important** function in this file. 
  - **`self.allowed_root / path`**: Combines the sandbox folder with the user's requested path.
  - **`.resolve()`**: Converts a path like `../../etc/passwd` into a real absolute path.
  - **`startswith(...)`**: We check if the final path is *still inside* the sandbox. If the user tries to "Break out" using `..`, this check will fail and throw a `FileSandboxError`.

### File Operations (`shutil`)

- **Lines 60-70**: `copy_path`
  - We use the `shutil` library, which is Python's "High-level" file utility.
  - **`shutil.copytree`**: Copies an entire folder and all its contents.
  - **`shutil.copy2`**: Copies a single file *and* its metadata (like the "Last Modified" time).

### Resource Management

- **Line 37**: `sorted(directory.iterdir(), ...)`
  - We use `iterdir()` to get the contents of a folder.
  - We **sort** them by name so the UI always shows files in a predictable alphabetical order.

---

## 3. Educational Callouts

> [!CAUTION]
> **Path Traversal Attacks**:
> Without the `_resolve` logic, an AI could be tricked into writing a file to your startup folder or reading your SSH keys. This pattern is essential whenever a program accepts file paths as input from a user or an AI.

---

## Key References
- [Python Pathlib: resolve()](https://docs.python.org/3/library/pathlib.html#pathlib.Path.resolve)
- [OWASP: Path Traversal](https://owasp.org/www-community/attacks/Path_Traversal)
- [Python Shutil Module](https://docs.python.org/3/library/shutil.html)
