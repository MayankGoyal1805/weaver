from urllib.parse import urlencode

import httpx

from app.core.config import get_settings


DISCORD_SCOPES = ["identify", "guilds", "email"]


class DiscordIntegrationService:
    @staticmethod
    def build_oauth_url(state: str) -> str:
        settings = get_settings()
        params = {
            "client_id": settings.discord_client_id,
            "redirect_uri": settings.discord_redirect_uri,
            "response_type": "code",
            "scope": " ".join(DISCORD_SCOPES),
            "prompt": "consent",
            "state": state,
        }
        return f"https://discord.com/oauth2/authorize?{urlencode(params)}"

    @staticmethod
    async def exchange_code(code: str) -> dict:
        settings = get_settings()
        payload = {
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": settings.discord_redirect_uri,
        }
        auth = (settings.discord_client_id, settings.discord_client_secret)
        headers = {"Content-Type": "application/x-www-form-urlencoded"}
        async with httpx.AsyncClient(timeout=20.0) as client:
            response = await client.post(
                "https://discord.com/api/oauth2/token",
                data=payload,
                headers=headers,
                auth=auth,
            )
            response.raise_for_status()
            token_data = response.json()

        return {
            "access_token": token_data.get("access_token", ""),
            "refresh_token": token_data.get("refresh_token", ""),
            "scopes": token_data.get("scope", "").split(),
            "provider_account_id": "",
            "expires_in": token_data.get("expires_in"),
            "token_type": token_data.get("token_type"),
        }

    @staticmethod
    async def send_message(channel_id: str, content: str, bot_token: str) -> dict:
        if not bot_token:
            return {
                "channel_id": channel_id,
                "content": content,
                "sent": False,
                "error": "DISCORD_BOT_TOKEN missing",
            }

        headers = {
            "Authorization": f"Bot {bot_token}",
            "Content-Type": "application/json",
        }
        payload = {"content": content}
        async with httpx.AsyncClient(timeout=20.0) as client:
            response = await client.post(
                f"https://discord.com/api/v10/channels/{channel_id}/messages",
                headers=headers,
                json=payload,
            )
            if response.is_error:
                raise RuntimeError(_format_discord_error(response, channel_id))
            data = response.json()
        return {
            "channel_id": channel_id,
            "message_id": data.get("id"),
            "content": data.get("content"),
            "sent": True,
        }


def _format_discord_error(response: httpx.Response, channel_id: str) -> str:
    status = response.status_code
    text = response.text
    code = None
    message = None
    try:
        payload = response.json()
        code = payload.get("code")
        message = payload.get("message")
    except Exception:
        payload = None

    parts = [f"Discord API error {status} for channel {channel_id}."]

    if code is not None or message:
        parts.append(f"code={code} message={message}")

    if status == 403:
        parts.append(
            "Bot lacks access/permission for this channel. "
            "Check bot is in server and has View Channel + Send Messages in target channel."
        )
    elif status == 404:
        parts.append("Channel not found for this bot. Verify channel id and server membership.")
    elif status == 401:
        parts.append("Invalid bot token. Rotate DISCORD_BOT_TOKEN and update .env.")

    if not (code or message):
        parts.append(f"raw={text[:300]}")

    return " ".join(parts)


discord_service = DiscordIntegrationService()
