# Database Layer Overview

The database layer in Weaver is built on **SQLAlchemy 2.0** using **AsyncIO**. This ensures the backend remains responsive even when performing heavy database operations.

The layer is split into three main parts:

### 1. The Core Infrastructure
These files handle the connection, sessions, and the base registry for the ORM.

- [**`base.py`**](./base.md): The Declarative Base that all models inherit from.
- [**`session.py`**](./session.md): Connection engine and session factory.

### 2. Models
Models are Python classes that represent database tables. They are located in `app/db/models/`.
- [User Model](./models/user.md) (Example)

### 3. Migrations
We use **Alembic** to track changes to our database schema. Migrations are stored in `app/db/migrations/`.

---

## How to add a new Table?
1.  Create a new file in `app/db/models/`.
2.  Import `Base` from `app.db.base`.
3.  Define your class (e.g., `class User(Base): ...`).
4.  Run an Alembic command to generate a migration:
    ```bash
    alembic revision --autogenerate -m "Add user table"
    alembic upgrade head
    ```

---

## Key References
- [SQLAlchemy 2.0 Unified Tutorial](https://docs.sqlalchemy.org/en/20/tutorial/index.html)
- [FastAPI Database SQL (Relational)](https://fastapi.tiangolo.com/tutorial/sql-databases/)
