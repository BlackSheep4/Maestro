"""Tests de integración para src/cli.py."""
from __future__ import annotations

import io
import os
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from datetime import datetime, timedelta, timezone
from unittest.mock import patch

from src import cli, storage


class TestCli(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.path = os.path.join(self.tmp.name, "notes.json")
        self._patch = patch.object(storage, "DEFAULT_NOTES_PATH", self.path)
        self._patch.start()

    def tearDown(self) -> None:
        self._patch.stop()
        self.tmp.cleanup()

    def _run(self, argv: list[str]) -> tuple[int, str, str]:
        out_buf = io.StringIO()
        err_buf = io.StringIO()
        with redirect_stdout(out_buf), redirect_stderr(err_buf):
            code = cli.main(argv)
        return code, out_buf.getvalue(), err_buf.getvalue()

    def test_add_creates_note_and_prints_id(self) -> None:
        code, out, _ = self._run(["add", "primera", "--body", "hola"])
        self.assertEqual(code, 0)
        self.assertIn("id=1", out)
        notes = storage.load(self.path)
        self.assertEqual(len(notes), 1)
        self.assertEqual(notes[0]["title"], "primera")

    def test_list_shows_existing_notes(self) -> None:
        self._run(["add", "uno", "--body", "a"])
        self._run(["add", "dos", "--body", "b"])
        code, out, _ = self._run(["list"])
        self.assertEqual(code, 0)
        self.assertIn("uno", out)
        self.assertIn("dos", out)
        self.assertEqual(len(out.strip().splitlines()), 2)

    def test_list_empty_outputs_nothing(self) -> None:
        code, out, _ = self._run(["list"])
        self.assertEqual(code, 0)
        self.assertEqual(out, "")

    def test_show_prints_title_date_body(self) -> None:
        self._run(["add", "titulo-uno", "--body", "cuerpo-uno"])
        code, out, _ = self._run(["show", "1"])
        self.assertEqual(code, 0)
        lines = out.splitlines()
        self.assertEqual(lines[0], "titulo-uno")
        self.assertRegex(lines[1], r"\d{4}-\d{2}-\d{2}T")
        self.assertEqual(lines[2], "cuerpo-uno")

    def test_show_missing_id_returns_error(self) -> None:
        code, out, err = self._run(["show", "99"])
        self.assertNotEqual(code, 0)
        self.assertEqual(out, "")
        self.assertIn("99", err)

    def test_delete_removes_note_and_confirms(self) -> None:
        self._run(["add", "uno", "--body", "a"])
        self._run(["add", "dos", "--body", "b"])
        code, out, _ = self._run(["delete", "1"])
        self.assertEqual(code, 0)
        self.assertIn("id=1", out)
        notes = storage.load(self.path)
        self.assertEqual(len(notes), 1)
        self.assertEqual(notes[0]["id"], 2)

    def test_delete_missing_id_returns_error(self) -> None:
        self._run(["add", "uno", "--body", "a"])
        code, out, err = self._run(["delete", "42"])
        self.assertNotEqual(code, 0)
        self.assertEqual(out, "")
        self.assertIn("42", err)
        notes = storage.load(self.path)
        self.assertEqual(len(notes), 1)


    def test_search_finds_matching_notes(self) -> None:
        self._run(["add", "comprar leche", "--body", "en el super"])
        self._run(["add", "llamar doctor", "--body", "cita lunes"])
        code, out, _ = self._run(["search", "leche"])
        self.assertEqual(code, 0)
        self.assertIn("comprar leche", out)
        self.assertNotIn("llamar doctor", out)

    def test_search_no_match_returns_error(self) -> None:
        self._run(["add", "comprar leche", "--body", "en el super"])
        code, out, err = self._run(["search", "zapatos"])
        self.assertNotEqual(code, 0)
        self.assertEqual(out, "")
        self.assertIn("zapatos", err)

    def test_search_is_case_insensitive(self) -> None:
        self._run(["add", "Comprar LECHE", "--body", "en el super"])
        code, out, _ = self._run(["search", "comprar leche"])
        self.assertEqual(code, 0)
        self.assertIn("Comprar LECHE", out)

    def test_edit_updates_only_title(self) -> None:
        self._run(["add", "viejo", "--body", "cuerpo"])
        code, out, _ = self._run(["edit", "1", "--title", "nuevo"])
        self.assertEqual(code, 0)
        self.assertIn("id=1", out)
        notes = storage.load(self.path)
        self.assertEqual(notes[0]["title"], "nuevo")
        self.assertEqual(notes[0]["body"], "cuerpo")

    def test_edit_updates_only_body(self) -> None:
        self._run(["add", "titulo", "--body", "viejo"])
        code, out, _ = self._run(["edit", "1", "--body", "nuevo"])
        self.assertEqual(code, 0)
        self.assertIn("id=1", out)
        notes = storage.load(self.path)
        self.assertEqual(notes[0]["title"], "titulo")
        self.assertEqual(notes[0]["body"], "nuevo")

    def test_edit_updates_both_fields(self) -> None:
        self._run(["add", "viejo-t", "--body", "viejo-b"])
        code, out, _ = self._run(["edit", "1", "--title", "nuevo-t", "--body", "nuevo-b"])
        self.assertEqual(code, 0)
        self.assertIn("id=1", out)
        notes = storage.load(self.path)
        self.assertEqual(notes[0]["title"], "nuevo-t")
        self.assertEqual(notes[0]["body"], "nuevo-b")

    def test_edit_missing_id_returns_error(self) -> None:
        self._run(["add", "uno", "--body", "a"])
        code, out, err = self._run(["edit", "99", "--title", "x"])
        self.assertNotEqual(code, 0)
        self.assertEqual(out, "")
        self.assertIn("99", err)

    def test_edit_without_flags_returns_error(self) -> None:
        self._run(["add", "uno", "--body", "a"])
        code, out, err = self._run(["edit", "1"])
        self.assertNotEqual(code, 0)
        self.assertEqual(out, "")
        self.assertNotEqual(err, "")
        notes = storage.load(self.path)
        self.assertEqual(notes[0]["title"], "uno")
        self.assertEqual(notes[0]["body"], "a")

    def _add_with_created_at(self, title: str, body: str, created_at: str) -> None:
        existing = storage.load(self.path)
        next_id = max((n["id"] for n in existing), default=0) + 1
        existing.append({
            "id": next_id,
            "title": title,
            "body": body,
            "created_at": created_at,
        })
        storage.save(existing, self.path)

    def test_recent_default_limit_orders_by_created_at_desc(self) -> None:
        base = datetime(2026, 1, 1, 12, 0, 0, tzinfo=timezone.utc)
        for i in range(7):
            ts = (base + timedelta(minutes=i)).isoformat(timespec="seconds")
            self._add_with_created_at(f"nota-{i}", f"body-{i}", ts)
        code, out, _ = self._run(["recent"])
        self.assertEqual(code, 0)
        lines = out.strip().splitlines()
        self.assertEqual(len(lines), 5)
        timestamps = [line.split("\t")[1] for line in lines]
        self.assertEqual(timestamps, sorted(timestamps, reverse=True))
        titles = [line.split("\t")[2] for line in lines]
        self.assertEqual(titles, ["nota-6", "nota-5", "nota-4", "nota-3", "nota-2"])

    def test_recent_custom_limit(self) -> None:
        base = datetime(2026, 2, 1, 9, 0, 0, tzinfo=timezone.utc)
        for i in range(6):
            ts = (base + timedelta(minutes=i)).isoformat(timespec="seconds")
            self._add_with_created_at(f"titulo-{i}", f"body-{i}", ts)
        code, out, _ = self._run(["recent", "--limit", "3"])
        self.assertEqual(code, 0)
        lines = out.strip().splitlines()
        self.assertEqual(len(lines), 3)
        for line in lines:
            parts = line.split("\t")
            self.assertEqual(len(parts), 3)
            self.assertRegex(parts[0], r"^\d+$")
            self.assertRegex(parts[1], r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}")

    def test_recent_empty_outputs_nothing(self) -> None:
        code, out, err = self._run(["recent"])
        self.assertEqual(code, 0)
        self.assertEqual(out, "")
        self.assertEqual(err, "")

    def test_recent_invalid_limit_zero(self) -> None:
        self._run(["add", "uno", "--body", "a"])
        before = storage.load(self.path)
        with open(self.path, "rb") as f:
            before_bytes = f.read()
        code, out, err = self._run(["recent", "--limit", "0"])
        self.assertNotEqual(code, 0)
        self.assertEqual(out, "")
        self.assertNotEqual(err, "")
        after = storage.load(self.path)
        self.assertEqual(before, after)
        with open(self.path, "rb") as f:
            self.assertEqual(before_bytes, f.read())

    def test_recent_invalid_limit_negative(self) -> None:
        self._run(["add", "uno", "--body", "a"])
        before = storage.load(self.path)
        with open(self.path, "rb") as f:
            before_bytes = f.read()
        code, out, err = self._run(["recent", "--limit", "-3"])
        self.assertNotEqual(code, 0)
        self.assertEqual(out, "")
        self.assertNotEqual(err, "")
        after = storage.load(self.path)
        self.assertEqual(before, after)
        with open(self.path, "rb") as f:
            self.assertEqual(before_bytes, f.read())


if __name__ == "__main__":
    unittest.main()
