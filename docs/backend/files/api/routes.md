# Source Code Guide: API Routes (`api/v1/routes/`)

This guide covers the entry points for Authentication and Tool management.

---

## 1. `app/api/v1/routes/auth.py`

This file manages the OAuth2 flows for Google and Discord.

### Key Endpoints

- **`GET /google/connect` (Line 26)**:
    - Generates a secure `state` token to prevent CSRF attacks.
    - Returns the Google Auth URL to the frontend.
- **`GET /google/callback` (Line 38)**:
    - This is the "Redirect URI". After the user signs in with Google, they are sent here with a `code`.
    - The backend exchanges this code for tokens and fetches the user's profile info.
    - **Persistence**: Tokens and profile info are saved in the `oauth_token_store`.
- **`GET /google/userinfo` (Line 62)**:
    - Returns the currently logged-in user's name and email.
    - **Self-Healing**: If the access token is expired, it automatically tries to refresh it using the `refresh_token` before returning the profile.
- **`GET /discord/bot-status` (Line 178)**:
    - Checks if the `DISCORD_BOT_TOKEN` in the `.env` file is valid and returns the bot's username.

---

## 2. `app/api/v1/routes/tools.py`

This file provides the API for the frontend to explore and use tools.

### Key Endpoints

- **`GET /catalog` (Line 11)**:
    - Returns the complete list of available tools, their descriptions, and their input/output schemas.
- **`POST /execute` (Line 16)**:
    - Allows the frontend to manually run a tool (e.g., "Delete File").
    - It validates that the `tool_id` exists before calling the `tool_execution_service`.
- **`GET /cards/state` (Line 30)**:
    - This is a high-performance endpoint used by the Dashboard and Sidebar.
    - It returns a summary of every provider's status (Connected, Auth Required) and relevant metadata (like the allowed root path for the filesystem).
- **`POST /filesystem/root` (Line 70)**:
    - Allows the user to change the sandboxed directory that Weaver is allowed to access.

---

## Why use APIRouter?
By using `APIRouter` with prefixes (like `/auth` or `/tools`), we keep the `main.py` file clean and allow different teams or modules to work on separate parts of the API independently.

## Key References
- [FastAPI Bigger Applications (Multiple Files)](https://fastapi.tiangolo.com/tutorial/bigger-applications/)
- [OAuth 2.0 State Parameter](https://auth0.com/docs/secure/attack-protection/state-parameters)
