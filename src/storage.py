"""Persistencia atómica de notas en un archivo JSON."""
from __future__ import annotations

import json
import os
import tempfile

DEFAULT_NOTES_PATH = os.environ.get("NOTES_FILE", ".notes.json")


def load(path: str | None = None) -> list[dict]:
    path = path or DEFAULT_NOTES_PATH
    if not os.path.exists(path):
        return []
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save(notes: list[dict], path: str | None = None) -> None:
    path = path or DEFAULT_NOTES_PATH
    directory = os.path.dirname(os.path.abspath(path))
    fd, tmp_path = tempfile.mkstemp(prefix=".notes_", suffix=".json", dir=directory)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(notes, f, ensure_ascii=False, indent=2)
        os.replace(tmp_path, path)
    except Exception:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
        raise
