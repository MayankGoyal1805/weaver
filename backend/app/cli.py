import argparse
import json
import re
import subprocess
import sys
import time
from pathlib import Path
from urllib.parse import urlparse
import webbrowser

import httpx
import uvicorn


DEFAULT_BASE_URL = "http://127.0.0.1:8000"


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Weaver backend local CLI")
    sub = parser.add_subparsers(dest="command", required=True)

    runserver = sub.add_parser("runserver", help="Run local FastAPI server")
    runserver.add_argument("--host", default="0.0.0.0")
    runserver.add_argument("--port", type=int, default=8000)

    health = sub.add_parser("health", help="Check backend health")
    health.add_argument("--base-url", default=DEFAULT_BASE_URL)
    health.add_argument("--no-auto-start", action="store_true")

    chat = sub.add_parser("chat", help="Send prompt to /api/v1/chat")
    chat.add_argument("prompt")
    chat.add_argument("--base-url", default=DEFAULT_BASE_URL)
    chat.add_argument("--no-auto-start", action="store_true")
    chat.add_argument("--system-prompt", default=None)
    chat.add_argument("--model-name", default=None)
    chat.add_argument("--allow-tools", action="store_true")
    chat.add_argument("--discord-channel-id", default=None)

    prompt = sub.add_parser("prompt", help="Alias of chat; quick prompt test")
    prompt.add_argument("prompt")
    prompt.add_argument("--base-url", default=DEFAULT_BASE_URL)
    prompt.add_argument("--no-auto-start", action="store_true")
    prompt.add_argument("--system-prompt", default=None)
    prompt.add_argument("--model-name", default=None)
    prompt.add_argument("--allow-tools", action="store_true")
    prompt.add_argument("--discord-channel-id", default=None)

    catalog = sub.add_parser("catalog", help="List tool catalog")
    catalog.add_argument("--base-url", default=DEFAULT_BASE_URL)
    catalog.add_argument("--no-auto-start", action="store_true")

    execute = sub.add_parser("execute-tool", help="Execute a tool")
    execute.add_argument("tool_id")
    execute.add_argument("--arguments-json", default="{}")
    execute.add_argument("--run-id", default=None)
    execute.add_argument("--base-url", default=DEFAULT_BASE_URL)
    execute.add_argument("--no-auto-start", action="store_true")

    auth_google = sub.add_parser("auth-google", help="Authenticate Google OAuth in browser")
    auth_google.add_argument("--base-url", default=DEFAULT_BASE_URL)
    auth_google.add_argument("--no-auto-start", action="store_true")
    auth_google.add_argument("--no-open", action="store_true")
    auth_google.add_argument("--timeout-seconds", type=int, default=180)

    auth_discord = sub.add_parser("auth-discord", help="Authenticate Discord OAuth in browser")
    auth_discord.add_argument("--base-url", default=DEFAULT_BASE_URL)
    auth_discord.add_argument("--no-auto-start", action="store_true")
    auth_discord.add_argument("--no-open", action="store_true")
    auth_discord.add_argument("--timeout-seconds", type=int, default=180)

    google_drive = sub.add_parser(
        "google-drive",
        aliases=["google_drive"],
        help="Google Drive provider helper commands",
    )
    google_drive_sub = google_drive.add_subparsers(dest="google_drive_command", required=True)
    google_drive_auth = google_drive_sub.add_parser("auth", help="Authenticate Google OAuth for Drive/Gmail")
    google_drive_auth.add_argument("--base-url", default=DEFAULT_BASE_URL)
    google_drive_auth.add_argument("--no-auto-start", action="store_true")
    google_drive_auth.add_argument("--no-open", action="store_true")
    google_drive_auth.add_argument("--timeout-seconds", type=int, default=180)
    google_drive_status = google_drive_sub.add_parser("status", help="Show Google OAuth status")
    google_drive_status.add_argument("--base-url", default=DEFAULT_BASE_URL)
    google_drive_status.add_argument("--no-auto-start", action="store_true")

    gmail_to_discord = sub.add_parser(
        "gmail-to-discord",
        help="Send latest Gmail message to a Discord channel",
    )
    gmail_to_discord.add_argument("--channel-id", required=True)
    gmail_to_discord.add_argument("--base-url", default=DEFAULT_BASE_URL)
    gmail_to_discord.add_argument("--no-auto-start", action="store_true")
    gmail_to_discord.add_argument("--format-with-llm", action="store_true")

    discord_send = sub.add_parser("discord-send", help="Send a test message to a Discord channel")
    discord_send.add_argument("--channel-id", required=True)
    discord_send.add_argument("--message", required=True)
    discord_send.add_argument("--base-url", default=DEFAULT_BASE_URL)
    discord_send.add_argument("--no-auto-start", action="store_true")

    return parser


def _request_json(method: str, url: str, payload: dict | None = None) -> dict:
    with httpx.Client(timeout=60.0) as client:
        response = client.request(method, url, json=payload)
        if response.is_error:
            detail = response.text
            raise RuntimeError(f"HTTP {response.status_code} from {url}: {detail}")
        return response.json()


def _is_server_healthy(base_url: str) -> bool:
    try:
        _request_json("GET", f"{base_url.rstrip('/')}/health")
        return True
    except Exception:
        return False


def _start_local_server(base_url: str) -> subprocess.Popen | None:
    parsed = urlparse(base_url)
    host = parsed.hostname
    port = parsed.port or 8000
    if host not in {"127.0.0.1", "localhost"}:
        raise RuntimeError(
            "Server is not reachable and auto-start is only supported for localhost/127.0.0.1. "
            "Start your remote server manually."
        )

    backend_root = Path(__file__).resolve().parents[1]
    command = [
        sys.executable,
        "-m",
        "uvicorn",
        "app.main:app",
        "--host",
        host,
        "--port",
        str(port),
    ]
    process = subprocess.Popen(command, cwd=str(backend_root))

    for _ in range(40):
        if process.poll() is not None:
            raise RuntimeError("Auto-started server exited unexpectedly.")
        if _is_server_healthy(base_url):
            print(f"Auto-started backend server at {base_url}")
            return process
        time.sleep(0.25)

    process.terminate()
    raise RuntimeError("Timed out waiting for auto-started backend server to become healthy.")


def _ensure_server(base_url: str, no_auto_start: bool) -> subprocess.Popen | None:
    if _is_server_healthy(base_url):
        return None

    if no_auto_start:
        raise RuntimeError(
            "Backend server is not reachable. Run weaver-cli runserver or remove --no-auto-start."
        )

    return _start_local_server(base_url)


def _stop_server(process: subprocess.Popen | None) -> None:
    if process is None:
        return
    process.terminate()
    try:
        process.wait(timeout=5)
    except Exception:
        process.kill()


def _run_browser_auth(provider: str, base_url: str, no_open: bool, timeout_seconds: int) -> int:
    start_url = f"{base_url.rstrip('/')}/api/v1/auth/{provider}/start"
    status_url = f"{base_url.rstrip('/')}/api/v1/auth/{provider}/status"

    print(f"Open this URL to authenticate {provider}: {start_url}")
    if not no_open:
        webbrowser.open(start_url)

    deadline = time.time() + timeout_seconds
    while time.time() < deadline:
        try:
            status = _request_json("GET", status_url)
        except Exception:
            time.sleep(1)
            continue

        if status.get("authenticated"):
            print(json.dumps(status, indent=2))
            print(f"{provider} auth completed.")
            return 0
        time.sleep(2)

    print(f"Timed out waiting for {provider} auth completion.", file=sys.stderr)
    return 1


def _format_latest_email_message(email: dict) -> str:
    if not email.get("found"):
        return "No recent email found in inbox."

    body = (email.get("body_text") or email.get("snippet") or "").strip()
    if len(body) > 800:
        body = body[:800] + "..."

    return (
        "Latest Gmail received:\n"
        f"From: {email.get('from', '')}\n"
        f"Subject: {email.get('subject', '(no subject)')}\n"
        f"Date: {email.get('date', '')}\n"
        f"Summary: {email.get('snippet', '')}\n"
        f"Body: {body}"
    )


def _discord_safe_content(text: str, max_chars: int = 1900) -> str:
    # Some reasoning-capable models may include <think> blocks that bloat payloads.
    cleaned = re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL | re.IGNORECASE).strip()
    if len(cleaned) <= max_chars:
        return cleaned
    return cleaned[: max_chars - 3].rstrip() + "..."


def _execute_tool(base_url: str, tool_id: str, arguments: dict) -> dict:
    return _request_json(
        "POST",
        f"{base_url.rstrip('/')}/api/v1/tools/execute",
        {"tool_id": tool_id, "arguments": arguments},
    )


def _tool_intent(prompt: str) -> dict:
    p = prompt.lower()
    wants_latest_gmail = any(x in p for x in ["latest gmail", "latest email", "last gmail", "last email"])
    wants_discord = "discord" in p or "channel" in p
    return {"gmail_latest": wants_latest_gmail, "discord": wants_discord}


def _tool_aware_prompt(
    *,
    base_url: str,
    prompt: str,
    system_prompt: str | None,
    model_name: str | None,
    discord_channel_id: str | None,
) -> dict:
    intent = _tool_intent(prompt)
    tool_calls: list[dict] = []
    latest_email: dict | None = None
    chat_error: str | None = None

    if intent["gmail_latest"]:
        gmail_out = _execute_tool(base_url, "google.gmail.get_latest_email", {})
        tool_calls.append({"tool_id": "google.gmail.get_latest_email", "result": gmail_out})
        latest_email = gmail_out.get("result", {})

    tool_context = ""
    if latest_email is not None:
        tool_context = "\n\nTool result for latest gmail:\n" + json.dumps(latest_email, ensure_ascii=False)

    chat_out: dict = {}
    llm_prompt = prompt + tool_context
    llm_system_prompt = system_prompt
    if intent["gmail_latest"] and intent["discord"] and latest_email is not None:
        llm_system_prompt = (
            "Write a concise Discord notification under 900 characters. "
            "Do not include code blocks, setup instructions, or policy text. "
            "Use plain text with sender, subject, and short summary only."
        )
        llm_prompt = (
            "Create a concise Discord message for this latest Gmail item. "
            "Return message text only.\n\n"
            f"{json.dumps(latest_email, ensure_ascii=False)}"
        )

    try:
        chat_out = _request_json(
            "POST",
            f"{base_url.rstrip('/')}/api/v1/chat",
            {
                "prompt": llm_prompt,
                "system_prompt": llm_system_prompt,
                "model_name": model_name,
            },
        )
    except Exception as exc:
        chat_error = str(exc)

    discord_send: dict | None = None
    if intent["discord"] and discord_channel_id:
        content = (chat_out.get("content") or "").strip()
        if not content and latest_email is not None:
            content = _format_latest_email_message(latest_email)
        if not content:
            content = "Requested Discord message could not be generated from prompt."
        content = _discord_safe_content(content)

        send_out = _execute_tool(
            base_url,
            "discord.send_message",
            {"channel_id": discord_channel_id, "content": content},
        )
        tool_calls.append({"tool_id": "discord.send_message", "result": send_out})
        discord_send = send_out

    return {
        "intent": intent,
        "chat": chat_out,
        "chat_error": chat_error,
        "tool_calls": tool_calls,
        "discord_send": discord_send,
    }


def main() -> int:
    parser = _build_parser()
    args = parser.parse_args()

    if args.command == "runserver":
        uvicorn.run("app.main:app", host=args.host, port=args.port, reload=False)
        return 0

    if args.command == "health":
        proc = None
        try:
            proc = _ensure_server(args.base_url, args.no_auto_start)
            data = _request_json("GET", f"{args.base_url.rstrip('/')}/health")
        except Exception as exc:
            print(str(exc), file=sys.stderr)
            return 1
        finally:
            _stop_server(proc)
        print(json.dumps(data, indent=2))
        return 0

    if args.command in {"chat", "prompt"}:
        proc = None
        payload = {
            "prompt": args.prompt,
            "system_prompt": args.system_prompt,
            "model_name": args.model_name,
        }
        try:
            proc = _ensure_server(args.base_url, args.no_auto_start)
            if args.allow_tools:
                data = _tool_aware_prompt(
                    base_url=args.base_url,
                    prompt=args.prompt,
                    system_prompt=args.system_prompt,
                    model_name=args.model_name,
                    discord_channel_id=args.discord_channel_id,
                )
            else:
                data = _request_json("POST", f"{args.base_url.rstrip('/')}/api/v1/chat", payload)
        except Exception as exc:
            print(str(exc), file=sys.stderr)
            return 1
        finally:
            _stop_server(proc)
        print(json.dumps(data, indent=2))
        return 0

    if args.command == "catalog":
        proc = None
        try:
            proc = _ensure_server(args.base_url, args.no_auto_start)
            data = _request_json("GET", f"{args.base_url.rstrip('/')}/api/v1/tools/catalog")
        except Exception as exc:
            print(str(exc), file=sys.stderr)
            return 1
        finally:
            _stop_server(proc)
        print(json.dumps(data, indent=2))
        return 0

    if args.command == "execute-tool":
        try:
            args_obj = json.loads(args.arguments_json)
            if not isinstance(args_obj, dict):
                raise ValueError("arguments-json must decode to a JSON object")
        except Exception as exc:
            print(f"Invalid --arguments-json: {exc}", file=sys.stderr)
            return 2

        payload = {"run_id": args.run_id, "tool_id": args.tool_id, "arguments": args_obj}
        proc = None
        try:
            proc = _ensure_server(args.base_url, args.no_auto_start)
            data = _request_json("POST", f"{args.base_url.rstrip('/')}/api/v1/tools/execute", payload)
        except Exception as exc:
            print(str(exc), file=sys.stderr)
            return 1
        finally:
            _stop_server(proc)
        print(json.dumps(data, indent=2))
        return 0

    if args.command == "auth-google":
        proc = None
        try:
            proc = _ensure_server(args.base_url, args.no_auto_start)
            return _run_browser_auth("google", args.base_url, args.no_open, args.timeout_seconds)
        except Exception as exc:
            print(str(exc), file=sys.stderr)
            return 1
        finally:
            _stop_server(proc)

    if args.command == "auth-discord":
        proc = None
        try:
            proc = _ensure_server(args.base_url, args.no_auto_start)
            return _run_browser_auth("discord", args.base_url, args.no_open, args.timeout_seconds)
        except Exception as exc:
            print(str(exc), file=sys.stderr)
            return 1
        finally:
            _stop_server(proc)

    if args.command in {"google-drive", "google_drive"}:
        if args.google_drive_command == "auth":
            proc = None
            try:
                proc = _ensure_server(args.base_url, args.no_auto_start)
                return _run_browser_auth("google", args.base_url, args.no_open, args.timeout_seconds)
            except Exception as exc:
                print(str(exc), file=sys.stderr)
                return 1
            finally:
                _stop_server(proc)

        if args.google_drive_command == "status":
            proc = None
            try:
                proc = _ensure_server(args.base_url, args.no_auto_start)
                data = _request_json("GET", f"{args.base_url.rstrip('/')}/api/v1/auth/google/status")
            except Exception as exc:
                print(str(exc), file=sys.stderr)
                return 1
            finally:
                _stop_server(proc)
            print(json.dumps(data, indent=2))
            return 0

    if args.command == "gmail-to-discord":
        proc = None
        try:
            proc = _ensure_server(args.base_url, args.no_auto_start)
            email_tool = _request_json(
                "POST",
                f"{args.base_url.rstrip('/')}/api/v1/tools/execute",
                {"tool_id": "google.gmail.get_latest_email", "arguments": {}},
            )
            email_result = email_tool.get("result", {})
            message_content = _format_latest_email_message(email_result)

            if args.format_with_llm:
                chat = _request_json(
                    "POST",
                    f"{args.base_url.rstrip('/')}/api/v1/chat",
                    {
                        "system_prompt": "You rewrite notifications for Discord.",
                        "prompt": (
                            "Rewrite the following email notification into a concise Discord message "
                            "under 1200 characters. Keep sender, subject, and key context.\n\n"
                            + message_content
                        ),
                    },
                )
                message_content = (chat.get("content") or message_content).strip()

            message_content = _discord_safe_content(message_content)

            send_tool = _request_json(
                "POST",
                f"{args.base_url.rstrip('/')}/api/v1/tools/execute",
                {
                    "tool_id": "discord.send_message",
                    "arguments": {"channel_id": args.channel_id, "content": message_content},
                },
            )
        except Exception as exc:
            print(str(exc), file=sys.stderr)
            return 1
        finally:
            _stop_server(proc)

        print(json.dumps({"latest_email": email_result, "discord_send": send_tool}, indent=2))
        return 0

    if args.command == "discord-send":
        proc = None
        try:
            proc = _ensure_server(args.base_url, args.no_auto_start)
            out = _execute_tool(
                args.base_url,
                "discord.send_message",
                {"channel_id": args.channel_id, "content": args.message},
            )
        except Exception as exc:
            print(str(exc), file=sys.stderr)
            return 1
        finally:
            _stop_server(proc)

        print(json.dumps(out, indent=2))
        return 0

    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
