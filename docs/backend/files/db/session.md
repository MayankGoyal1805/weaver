# Source Code Guide: `app/db/session.py`

In an asynchronous application like Weaver, managing database connections requires care. We use **SQLAlchemy 2.0** with **asyncio** to ensure that database queries don't "block" the rest of the application.

This file is responsible for setting up the connection engine and providing a way for the API to request a "Session" for each request.

---

## 1. Complete Code

```python
from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import get_settings

# 1. Load Settings
settings = get_settings()

# 2. Create the Engine
engine = create_async_engine(
    settings.database_url, 
    future=True, 
    pool_pre_ping=True
)

# 3. Create the Session Factory
SessionLocal = async_sessionmaker(
    engine, 
    expire_on_commit=False, 
    class_=AsyncSession
)


# 4. Dependency for FastAPI
async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    """
    Yields a database session and ensures it is closed after use.
    """
    async with SessionLocal() as session:
        yield session
```

---

## 2. Line-by-Line Deep Dive

### Imports

- **Line 1**: `from collections.abc import AsyncGenerator`
  - **What**: Type hinting for functions that `yield` asynchronously.
- **Line 3**: `AsyncSession`, `async_sessionmaker`, `create_async_engine`
  - **What**: The three pillars of SQLAlchemy Async support.
- **Line 5**: `from app.core.config import get_settings`
  - **What**: Bringing in our configuration to get the `database_url`.

---

### The Engine (The Connection)

- **Lines 9-13**: `create_async_engine(...)`
  - **Engine**: Think of this as the "Base" connection to the database (SQLite in our case).
  - **`future=True`**: Ensures we are using the SQLAlchemy 2.0 style API.
  - **`pool_pre_ping=True`**: Before the engine gives a connection to the app, it "pings" the database. If the connection died (e.g., the database restarted), it transparently creates a new one.

---

### The Session Factory

- **Lines 16-20**: `async_sessionmaker(...)`
  - **SessionLocal**: This isn't a session itself; it's a *factory* that makes sessions.
  - **`expire_on_commit=False`**: Crucial for Async! By default, SQLAlchemy "expires" objects after you commit. Accessing them again would trigger a new (hidden) database call, which fails in async mode unless specifically handled. Setting this to `False` keeps the data in memory.

---

### The Dependency Injection

- **Lines 23-28**: `async def get_db_session()`
  - **FastAPI Pattern**: We use this function in our API routes like this: 
    `async def create_user(db: AsyncSession = Depends(get_db_session)):`
  - **`async with`**: This is a Context Manager. It guarantees that even if your code crashes, the database connection is safely returned to the pool (closed).
  - **`yield session`**: This "hands over" the session to the API route. Once the route finishes, execution resumes here and closes the session.

---

## 3. Educational Callouts

> [!TIP]
> **What is a Session?**
> Think of the **Engine** as the physical pipe to the database. A **Session** is a single "conversation" or transaction happening over that pipe. You should generally use one session per web request.

---

## Key References
- [SQLAlchemy Async Documentation](https://docs.sqlalchemy.org/en/20/orm/extensions/asyncio.html)
- [FastAPI: Dependencies with yield](https://fastapi.tiangolo.com/tutorial/dependencies/dependencies-with-yield/)
