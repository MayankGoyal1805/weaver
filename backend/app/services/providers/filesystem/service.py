from pathlib import Path
import shutil

from app.core.config import get_settings


class FileSandboxError(Exception):
    pass


class FilesystemToolService:
    def __init__(self) -> None:
        settings = get_settings()
        self.allowed_root = Path(settings.allowed_file_root).resolve()
        self.allowed_root.mkdir(parents=True, exist_ok=True)

    def _resolve(self, path: str) -> Path:
        candidate = (self.allowed_root / path).resolve()
        if not str(candidate).startswith(str(self.allowed_root)):
            raise FileSandboxError("Path escapes allowed file root")
        return candidate

    def list_directory(self, path: str = ".") -> dict:
        directory = self._resolve(path)
        if not directory.exists() or not directory.is_dir():
            raise FileSandboxError("Directory does not exist")
        entries = []
        for entry in sorted(directory.iterdir(), key=lambda x: x.name):
            entries.append(
                {
                    "name": entry.name,
                    "is_dir": entry.is_dir(),
                    "size": entry.stat().st_size if entry.exists() and entry.is_file() else None,
                }
            )
        return {"path": str(directory), "entries": entries}

    def read_file(self, path: str) -> dict:
        target = self._resolve(path)
        if not target.exists() or not target.is_file():
            raise FileSandboxError("File does not exist")
        return {"path": str(target), "content": target.read_text(encoding="utf-8")}

    def write_file(self, path: str, content: str, create_dirs: bool = True) -> dict:
        target = self._resolve(path)
        if create_dirs:
            target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
        return {"path": str(target), "bytes_written": len(content.encode("utf-8"))}

    def copy_path(self, source: str, destination: str) -> dict:
        src = self._resolve(source)
        dest = self._resolve(destination)
        if not src.exists():
            raise FileSandboxError("Source path does not exist")
        if src.is_dir():
            shutil.copytree(src, dest, dirs_exist_ok=True)
            return {"source": str(src), "destination": str(dest), "copied": "directory"}
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dest)
        return {"source": str(src), "destination": str(dest), "copied": "file"}

    def move_path(self, source: str, destination: str) -> dict:
        src = self._resolve(source)
        dest = self._resolve(destination)
        if not src.exists():
            raise FileSandboxError("Source path does not exist")
        dest.parent.mkdir(parents=True, exist_ok=True)
        moved_to = shutil.move(str(src), str(dest))
        return {"source": str(src), "destination": moved_to}

    def delete_path(self, path: str, recursive: bool = False) -> dict:
        target = self._resolve(path)
        if not target.exists():
            raise FileSandboxError("Path does not exist")
        if target.is_dir():
            if recursive:
                shutil.rmtree(target)
            else:
                target.rmdir()
            return {"path": str(target), "deleted": "directory"}
        target.unlink()
        return {"path": str(target), "deleted": "file"}


filesystem_service = FilesystemToolService()
