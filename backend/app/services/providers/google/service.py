from urllib.parse import urlencode
import base64

import httpx

from app.core.config import get_settings


GOOGLE_SCOPES = [
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/gmail.send",
    "https://www.googleapis.com/auth/drive.file",
    "https://www.googleapis.com/auth/drive.metadata.readonly",
]


class GoogleIntegrationService:
    @staticmethod
    def build_oauth_url(state: str) -> str:
        settings = get_settings()
        params = {
            "client_id": settings.google_client_id,
            "redirect_uri": settings.google_redirect_uri,
            "response_type": "code",
            "scope": " ".join(GOOGLE_SCOPES),
            "access_type": "offline",
            "include_granted_scopes": "true",
            "prompt": "consent",
            "state": state,
        }
        return f"https://accounts.google.com/o/oauth2/v2/auth?{urlencode(params)}"

    @staticmethod
    async def exchange_code(code: str) -> dict:
        settings = get_settings()
        payload = {
            "code": code,
            "client_id": settings.google_client_id,
            "client_secret": settings.google_client_secret,
            "redirect_uri": settings.google_redirect_uri,
            "grant_type": "authorization_code",
        }
        async with httpx.AsyncClient(timeout=20.0) as client:
            response = await client.post("https://oauth2.googleapis.com/token", data=payload)
            response.raise_for_status()
            token_data = response.json()
        return {
            "access_token": token_data.get("access_token", ""),
            "refresh_token": token_data.get("refresh_token", ""),
            "scopes": token_data.get("scope", "").split(),
            "provider_account_id": token_data.get("id_token", ""),
            "expires_in": token_data.get("expires_in"),
            "token_type": token_data.get("token_type"),
        }

    @staticmethod
    async def refresh_access_token(refresh_token: str) -> dict:
        settings = get_settings()
        payload = {
            "client_id": settings.google_client_id,
            "client_secret": settings.google_client_secret,
            "refresh_token": refresh_token,
            "grant_type": "refresh_token",
        }
        async with httpx.AsyncClient(timeout=20.0) as client:
            response = await client.post("https://oauth2.googleapis.com/token", data=payload)
            response.raise_for_status()
            token_data = response.json()
        return {
            "access_token": token_data.get("access_token", ""),
            "refresh_token": refresh_token,
            "scopes": token_data.get("scope", "").split(),
            "provider_account_id": "",
            "expires_in": token_data.get("expires_in"),
            "token_type": token_data.get("token_type"),
        }

    @staticmethod
    async def list_gmail_threads(access_token: str, max_results: int = 20) -> dict:
        headers = {"Authorization": f"Bearer {access_token}"}
        params = {"maxResults": max_results}
        async with httpx.AsyncClient(timeout=20.0) as client:
            response = await client.get(
                "https://gmail.googleapis.com/gmail/v1/users/me/threads",
                headers=headers,
                params=params,
            )
            response.raise_for_status()
            data = response.json()
        return {
            "threads": data.get("threads", []),
            "next_page_token": data.get("nextPageToken"),
            "result_size_estimate": data.get("resultSizeEstimate", 0),
        }

    @staticmethod
    async def list_drive_files(access_token: str, page_size: int = 20) -> dict:
        headers = {"Authorization": f"Bearer {access_token}"}
        params = {
            "pageSize": page_size,
            "fields": "files(id,name,mimeType,modifiedTime,size),nextPageToken",
            "supportsAllDrives": "true",
            "includeItemsFromAllDrives": "true",
        }
        async with httpx.AsyncClient(timeout=20.0) as client:
            response = await client.get(
                "https://www.googleapis.com/drive/v3/files",
                headers=headers,
                params=params,
            )
            response.raise_for_status()
            data = response.json()
        return {"files": data.get("files", []), "next_page_token": data.get("nextPageToken")}

    @staticmethod
    async def get_latest_gmail_email(access_token: str) -> dict:
        headers = {"Authorization": f"Bearer {access_token}"}
        params = {"maxResults": 1, "labelIds": "INBOX", "q": "-in:chats"}
        async with httpx.AsyncClient(timeout=20.0) as client:
            list_resp = await client.get(
                "https://gmail.googleapis.com/gmail/v1/users/me/messages",
                headers=headers,
                params=params,
            )
            list_resp.raise_for_status()
            list_data = list_resp.json()

            messages = list_data.get("messages", [])
            if not messages:
                return {"found": False, "reason": "No messages found in inbox"}

            message_id = messages[0].get("id", "")
            msg_resp = await client.get(
                f"https://gmail.googleapis.com/gmail/v1/users/me/messages/{message_id}",
                headers=headers,
                params={"format": "full"},
            )
            msg_resp.raise_for_status()
            msg = msg_resp.json()

        payload = msg.get("payload", {})
        headers_list = payload.get("headers", [])
        by_name = {h.get("name", "").lower(): h.get("value", "") for h in headers_list}
        body_text = _extract_message_body(payload)

        return {
            "found": True,
            "id": msg.get("id"),
            "thread_id": msg.get("threadId"),
            "subject": by_name.get("subject", "(no subject)"),
            "from": by_name.get("from", ""),
            "date": by_name.get("date", ""),
            "snippet": msg.get("snippet", ""),
            "body_text": body_text,
        }

    @staticmethod
    async def get_user_info(access_token: str) -> dict:
        headers = {"Authorization": f"Bearer {access_token}"}
        async with httpx.AsyncClient(timeout=20.0) as client:
            response = await client.get(
                "https://www.googleapis.com/oauth2/v2/userinfo",
                headers=headers,
            )
            response.raise_for_status()
            data = response.json()
        return {
            "id": data.get("id"),
            "email": data.get("email"),
            "name": data.get("name"),
            "picture": data.get("picture"),
            "verified_email": data.get("verified_email"),
        }


def _extract_message_body(payload: dict) -> str:
    plain_text = _find_plain_text(payload)
    if plain_text:
        return plain_text

    data = payload.get("body", {}).get("data")
    if not data:
        return ""

    return _decode_base64url(data)


def _find_plain_text(part: dict) -> str:
    mime_type = part.get("mimeType", "")
    body_data = part.get("body", {}).get("data")
    if mime_type == "text/plain" and body_data:
        return _decode_base64url(body_data)

    for child in part.get("parts", []) or []:
        found = _find_plain_text(child)
        if found:
            return found
    return ""


def _decode_base64url(data: str) -> str:
    normalized = data.replace("-", "+").replace("_", "/")
    pad = len(normalized) % 4
    if pad:
        normalized += "=" * (4 - pad)
    decoded = base64.b64decode(normalized)
    return decoded.decode("utf-8", errors="replace")


google_service = GoogleIntegrationService()
