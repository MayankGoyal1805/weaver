"""initial schema

Revision ID: 0001_initial
Revises: None
Create Date: 2026-04-17 00:00:00
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "0001_initial"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.String(length=36), primary_key=True, nullable=False),
        sa.Column("email", sa.String(length=320), nullable=False, unique=True),
        sa.Column("display_name", sa.String(length=120), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_table(
        "tool_definitions",
        sa.Column("id", sa.String(length=36), primary_key=True, nullable=False),
        sa.Column("tool_id", sa.String(length=200), nullable=False, unique=True),
        sa.Column("display_name", sa.String(length=200), nullable=False),
        sa.Column("provider", sa.String(length=80), nullable=False),
        sa.Column("auth_type", sa.String(length=40), nullable=False),
        sa.Column("capabilities", sa.JSON(), nullable=False),
        sa.Column("required_scopes", sa.JSON(), nullable=False),
        sa.Column("input_schema", sa.JSON(), nullable=False),
        sa.Column("output_schema", sa.JSON(), nullable=False),
        sa.Column("is_side_effecting", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_table(
        "tool_connections",
        sa.Column("id", sa.String(length=36), primary_key=True, nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("provider", sa.String(length=80), nullable=False),
        sa.Column("status", sa.String(length=40), nullable=False, server_default="auth_required"),
        sa.Column("encrypted_access_token", sa.Text(), nullable=True),
        sa.Column("encrypted_refresh_token", sa.Text(), nullable=True),
        sa.Column("scopes", sa.JSON(), nullable=False),
        sa.Column("metadata_json", sa.JSON(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_table(
        "runs",
        sa.Column("id", sa.String(length=36), primary_key=True, nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("mode", sa.String(length=20), nullable=False),
        sa.Column("status", sa.String(length=30), nullable=False, server_default="queued"),
        sa.Column("prompt", sa.Text(), nullable=True),
        sa.Column("graph_json", sa.JSON(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_table(
        "tool_call_events",
        sa.Column("id", sa.String(length=36), primary_key=True, nullable=False),
        sa.Column("run_id", sa.String(length=36), nullable=False),
        sa.Column("tool_id", sa.String(length=200), nullable=False),
        sa.Column("event_type", sa.String(length=60), nullable=False),
        sa.Column("payload", sa.JSON(), nullable=False),
        sa.Column("status", sa.String(length=30), nullable=False, server_default="ok"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_index("ix_tool_connections_user_provider", "tool_connections", ["user_id", "provider"], unique=False)
    op.create_index("ix_tool_call_events_run_id", "tool_call_events", ["run_id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_tool_call_events_run_id", table_name="tool_call_events")
    op.drop_index("ix_tool_connections_user_provider", table_name="tool_connections")
    op.drop_table("tool_call_events")
    op.drop_table("runs")
    op.drop_table("tool_connections")
    op.drop_table("tool_definitions")
    op.drop_table("users")
