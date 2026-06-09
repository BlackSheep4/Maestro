"""Tests para src/notes.py."""
from __future__ import annotations

import unittest

from src.notes import Note


class TestNote(unittest.TestCase):
    def test_new_assigns_id_one_when_no_existing(self) -> None:
        note = Note.new("hola", "mundo", existing=[])
        self.assertEqual(note.id, 1)
        self.assertEqual(note.title, "hola")
        self.assertEqual(note.body, "mundo")
        self.assertTrue(note.created_at)

    def test_new_increments_id(self) -> None:
        existing = [{"id": 1}, {"id": 2}, {"id": 5}]
        note = Note.new("x", "y", existing=existing)
        self.assertEqual(note.id, 6)

    def test_to_dict_round_trip(self) -> None:
        note = Note.new("a", "b", existing=[])
        d = note.to_dict()
        self.assertEqual(set(d.keys()), {"id", "title", "body", "created_at"})

    def test_note_is_frozen(self) -> None:
        note = Note.new("a", "b", existing=[])
        with self.assertRaises(Exception):
            note.title = "otro"  # type: ignore[misc]


if __name__ == "__main__":
    unittest.main()
