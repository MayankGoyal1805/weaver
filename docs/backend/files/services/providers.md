# Source Code Guide: Provider Integrations (`services/providers/`)

Weaver integrates with third-party services like Google and Discord using their respective APIs. This guide covers how these integrations are implemented.

---

## 1. `app/services/providers/google/service.py`

This file handles **Google OAuth2** and interactions with **Gmail** and **Google Drive**.

### OAuth Flow (Lines 18-76)
- **`build_oauth_url`**: Generates the URL that the user clicks in the Flutter app to sign in. It includes the `GOOGLE_SCOPES` (Gmail read/send, Drive file access).
- **`exchange_code`**: After the user signs in, Google sends back a "Code". This function swaps that code for an `access_token` and a `refresh_token`.
- **`refresh_access_token`**: Google tokens expire every hour. This function uses the `refresh_token` to get a new `access_token` without bothering the user.

### Tool Implementations (Lines 78-155)
- **`list_gmail_threads`**: Calls the Gmail API to get a list of recent conversation threads.
- **`list_drive_files`**: Calls the Drive API to list files. It is configured to look across all drives (shared drives included).
- **`get_latest_gmail_email`**: A complex helper that first finds the ID of the latest message and then fetches the full content (including headers like "From" and "Subject").

### Helper: Body Extraction (Lines 193-224)
- Google returns email bodies in a complex, multi-part JSON structure, often encoded in **Base64URL**.
- `_extract_message_body` recursively searches the parts of the email to find the "text/plain" version and decodes it into a readable string.

---

## 2. `app/services/providers/discord/service.py`

This file handles **Discord OAuth** and the **Discord Bot** functionality.

### OAuth Flow (Lines 11-52)
- Similar to Google, it provides `build_oauth_url` and `exchange_code`.
- It requests the `identify` and `guilds` scopes to verify who the user is.

### Bot Actions (Lines 54-83)
- **`send_message`**: Unlike Google, which uses the user's token, this function uses a **Bot Token** from the `.env` file.
- It sends a JSON payload to Discord's `/messages` endpoint for a specific channel.
- **Error Handling (Lines 132-162)**: Provides very detailed error messages (e.g., "Bot lacks permission" or "Channel not found") to help the user debug setup issues.

---

## Security Note
All tokens (Access and Refresh) are handled as sensitive data. In a production environment, these should be encrypted at rest (Weaver uses a local encrypted token store for this).

## Key References
- [Google Identity: OAuth 2.0 for Web](https://developers.google.com/identity/protocols/oauth2/web-server)
- [Discord API Documentation](https://discord.com/developers/docs/intro)
- [Gmail API Reference](https://developers.google.com/gmail/api/reference/rest)
