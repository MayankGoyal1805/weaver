# Source Code Guide: `app/db/base.py`

This file defines the base class for all our database models. In SQLAlchemy, we use the "Declarative" system, where we define our tables as Python classes.

---

## 1. Complete Code

```python
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    """
    The parent class for all database models (User, Tool, Run, etc.).
    """
    pass
```

---

## 2. Line-by-Line Deep Dive

### The Base Class

- **Line 1**: `from sqlalchemy.orm import DeclarativeBase`
  - **What**: Imports the modern base class for SQLAlchemy models.
- **Line 4**: `class Base(DeclarativeBase):`
  - **Why**: By inheriting from `DeclarativeBase`, our `Base` class becomes a "Registry". Every time we create a new model (like `User`), it registers itself with `Base`.
  - **Benefit**: This allows SQLAlchemy to know about all the tables in the system, which is essential for generating migrations (with Alembic) and creating the tables initially.

---

## 3. Educational Callouts

> [!NOTE]
> **Why is this so simple?**
> You might wonder why we need a whole file for 3 lines of code. It's about **Centralization**. By having a single `base.py`, we avoid circular imports. Every model in the system imports `Base` from here, and the session management also knows about `Base`.

---

## Key References
- [SQLAlchemy Declarative Mapping](https://docs.sqlalchemy.org/en/20/orm/declarative_mapping.html)
- [Alembic Migrations](https://alembic.sqlalchemy.org/en/latest/)
