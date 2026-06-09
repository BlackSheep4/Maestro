"""Tests para src/storage.py."""
from __future__ import annotations

import json
import os
import tempfile
import unittest

from src import storage


class TestStorage(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.path = os.path.join(self.tmp.name, "notes.json")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_load_returns_empty_when_file_missing(self) -> None:
        self.assertEqual(storage.load(self.path), [])

    def test_save_then_load_roundtrip(self) -> None:
        notes = [{"id": 1, "title": "hola", "body": "mundo", "created_at": "2026-04-27T00:00:00+00:00"}]
        storage.save(notes, self.path)
        self.assertEqual(storage.load(self.path), notes)

    def test_save_is_atomic(self) -> None:
        notes = [{"id": 1, "title": "x", "body": "y", "created_at": "z"}]
        storage.save(notes, self.path)
        with open(self.path, "r", encoding="utf-8") as f:
            content = f.read()
        self.assertEqual(json.loads(content), notes)
        leftovers = [f for f in os.listdir(self.tmp.name) if f.startswith(".notes_")]
        self.assertEqual(leftovers, [])


if __name__ == "__main__":
    unittest.main()
