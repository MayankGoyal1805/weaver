# Source Code Guide: `app/db/models/tool.py`

This file handles the **Registry of Capabilities**. It defines how we store information about tools (like "Send Gmail") and how we store the encrypted credentials (tokens) that allow the agent to use those tools.

---

## 1. Complete Code (Highlights)

```python
class ToolDefinition(Base):
    """
    Stores 'What' a tool can do.
    """
    __tablename__ = "tool_definitions"

    tool_id: Mapped[str] = mapped_column(String(200), unique=True, nullable=False)
    display_name: Mapped[str] = mapped_column(String(200), nullable=False)
    provider: Mapped[str] = mapped_column(String(80), nullable=False)
    
    # JSON schemas for AI compatibility
    input_schema: Mapped[dict] = mapped_column(JSON, default=dict)
    output_schema: Mapped[dict] = mapped_column(JSON, default=dict)

class ToolConnection(Base):
    """
    Stores the user's connection to a provider (Google, Discord).
    """
    __tablename__ = "tool_connections"

    user_id: Mapped[str] = mapped_column(String(36), nullable=False)
    provider: Mapped[str] = mapped_column(String(80), nullable=False)
    status: Mapped[str] = mapped_column(String(40), default="auth_required")
    
    # Encrypted tokens (Security!)
    encrypted_access_token: Mapped[str | None] = mapped_column(Text)
    encrypted_refresh_token: Mapped[str | None] = mapped_column(Text)
```

---

## 2. Line-by-Line Deep Dive

### JSON Support

- **Lines 18-21**: `Mapped[dict] = mapped_column(JSON, ...)`
  - **What**: This allows us to store complex nested objects (like a list of parameters or an AI schema) directly in a single column.
  - **Why**: Instead of creating 50 separate columns for every possible tool parameter, we store them as a JSON blob.

### Capability Schemas

- **`input_schema`**: This is the "User Manual" for the AI. It tells the LLM: "To use the Gmail tool, you must provide a 'to' address and a 'subject' string."

### Tool Connections (Security)

- **Lines 34-35**: `encrypted_access_token`
  - **Constraint**: Notice we use `Text` instead of `String(255)`. OAuth tokens can be very long.
  - **Encryption**: Even though the variable says "encrypted", this model just provides the **storage space**. The actual encryption/decryption logic happens in the `TokenStore` service before the data hits the database.

### Update Tracking

- **Line 38**: `onupdate=func.now()`
  - **What**: Every time you change your Discord settings, this column automatically updates to the current time. This is useful for debugging ("When did the user last re-connect?").

---

## 3. Educational Callouts

> [!IMPORTANT]
> **One Table for Definitions, One for Connections**:
> This is a "Many-to-Many" logic. `ToolDefinition` stores the general info (used by all users). `ToolConnection` stores the specific tokens for *one* specific user.

---

## Key References
- [SQLAlchemy: JSON Type](https://docs.sqlalchemy.org/en/20/core/type_basics.html#sqlalchemy.types.JSON)
- [OAuth Token Management Best Practices](https://auth0.com/docs/secure/tokens/token-storage)
