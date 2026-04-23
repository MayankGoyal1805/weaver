# Source Code Guide: `app/db/models/user.py`

This file defines the **User Model**, which represents the `users` table in our database. It stores the basic identity information for anyone using the Weaver platform.

---

## 1. Complete Code

```python
import uuid
from datetime import datetime
from sqlalchemy import DateTime, String, func
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class User(Base):
    """
    Represents a user in the system.
    """
    __tablename__ = "users"

    # 1. Primary Key (UUID)
    id: Mapped[str] = mapped_column(
        String(36), 
        primary_key=True, 
        default=lambda: str(uuid.uuid4())
    )

    # 2. Identity Information
    email: Mapped[str] = mapped_column(String(320), unique=True, nullable=False)
    display_name: Mapped[str | None] = mapped_column(String(120))

    # 3. Metadata
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        server_default=func.now()
    )
```

---

## 2. Line-by-Line Deep Dive

### SQLAlchemy 2.0 Syntax

- **Line 5**: `from sqlalchemy.orm import Mapped, mapped_column`
  - **What**: This is the modern, type-safe way to define models in SQLAlchemy 2.0.
  - **`Mapped[str]`**: This tells Python (and tools like VS Code) that this field will contain a string.

### The ID Field

- **Line 13**: `default=lambda: str(uuid.uuid4())`
  - **What**: Generates a unique "Universally Unique Identifier".
  - **Why**: Instead of using 1, 2, 3 (which are easy to guess), we use UUIDs. They are much harder to guess and safer for public APIs.

### The Email Field

- **Line 14**: `unique=True, nullable=False`
  - **Constraint**: This ensures that no two users can have the same email address, and every user *must* have an email.

### The Created_at Field

- **Line 16**: `server_default=func.now()`
  - **Logic**: We don't have to provide the time manually in Python. The **Database itself** (Postgres/SQLite) will automatically set the current timestamp when a new user is created.

---

## 3. Educational Callouts

> [!TIP]
> **What is an ORM?**
> SQLAlchemy is an Object-Relational Mapper. It allows you to treat database tables as Python classes. Instead of writing `INSERT INTO users (email) VALUES ('test@test.com')`, you just do:
> ```python
> user = User(email="test@test.com")
> session.add(user)
> ```

---

## Key References
- [SQLAlchemy: Declarative Mapping](https://docs.sqlalchemy.org/en/20/orm/declarative_mapping.html)
- [Python UUID Module](https://docs.python.org/3/library/uuid.html)
