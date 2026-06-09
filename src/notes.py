"""Modelo de dominio: la Nota."""
from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import datetime, timezone


class NoteError(Exception):
    """Base para errores del dominio."""


class NoteNotFound(NoteError):
    """Se lanza cuando se busca una nota inexistente."""


@dataclass(frozen=True)
class Note:
    id: int
    title: str
    body: str
    created_at: str

    @staticmethod
    def new(title: str, body: str, existing: list[dict]) -> "Note":
        next_id = max((n["id"] for n in existing), default=0) + 1
        return Note(
            id=next_id,
            title=title,
            body=body,
            created_at=datetime.now(timezone.utc).isoformat(timespec="seconds"),
        )

    def to_dict(self) -> dict:
        return asdict(self)
