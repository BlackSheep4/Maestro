"""Interfaz de línea de comandos."""
from __future__ import annotations

import argparse
import sys

from src import storage
from src.notes import Note, NoteError, NoteNotFound


def cmd_add(args: argparse.Namespace) -> int:
    notes = storage.load()
    note = Note.new(args.title, args.body, notes)
    notes.append(note.to_dict())
    storage.save(notes)
    print(f"id={note.id}")
    return 0


def cmd_list(args: argparse.Namespace) -> int:
    notes = storage.load()
    for n in notes:
        print(f"{n['id']}\t{n['created_at']}\t{n['title']}")
    return 0


def cmd_show(args: argparse.Namespace) -> int:
    notes = storage.load()
    for n in notes:
        if n["id"] == args.id:
            print(n["title"])
            print(n["created_at"])
            print(n["body"])
            return 0
    raise NoteNotFound(f"no existe la nota con id={args.id}")


def cmd_delete(args: argparse.Namespace) -> int:
    notes = storage.load()
    remaining = [n for n in notes if n["id"] != args.id]
    if len(remaining) == len(notes):
        raise NoteNotFound(f"no existe la nota con id={args.id}")
    storage.save(remaining)
    print(f"borrada id={args.id}")
    return 0


def cmd_search(args: argparse.Namespace) -> int:
    notes = storage.load()
    query = args.query.lower()
    matches = [n for n in notes if query in n["title"].lower() or query in n["body"].lower()]
    if not matches:
        raise NoteNotFound(f"no hay notas que contengan \"{args.query}\"")
    for n in matches:
        print(f"{n['id']}\t{n['created_at']}\t{n['title']}")
    return 0


def cmd_recent(args: argparse.Namespace) -> int:
    if args.limit <= 0:
        raise NoteError("--limit debe ser un entero positivo")
    notes = storage.load()
    if not notes:
        return 0
    ordered = sorted(notes, key=lambda n: n["created_at"], reverse=True)
    for n in ordered[: args.limit]:
        print(f"{n['id']}\t{n['created_at']}\t{n['title']}")
    return 0


def cmd_edit(args: argparse.Namespace) -> int:
    if args.title is None and args.body is None:
        raise NoteError("debes pasar --title y/o --body")
    notes = storage.load()
    for i, n in enumerate(notes):
        if n["id"] == args.id:
            updated = Note(
                id=n["id"],
                title=args.title if args.title is not None else n["title"],
                body=args.body if args.body is not None else n["body"],
                created_at=n["created_at"],
            )
            notes[i] = updated.to_dict()
            storage.save(notes)
            print(f"editada id={args.id}")
            return 0
    raise NoteNotFound(f"no existe la nota con id={args.id}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="notes", description="CLI minimalista de notas.")
    sub = parser.add_subparsers(dest="command", required=True)

    p_add = sub.add_parser("add", help="Añadir una nota.")
    p_add.add_argument("title")
    p_add.add_argument("--body", default="")
    p_add.set_defaults(func=cmd_add)

    p_list = sub.add_parser("list", help="Listar todas las notas.")
    p_list.set_defaults(func=cmd_list)

    p_show = sub.add_parser("show", help="Mostrar una nota por id.")
    p_show.add_argument("id", type=int)
    p_show.set_defaults(func=cmd_show)

    p_delete = sub.add_parser("delete", help="Borrar una nota por id.")
    p_delete.add_argument("id", type=int)
    p_delete.set_defaults(func=cmd_delete)

    p_search = sub.add_parser("search", help="Buscar notas por palabra.")
    p_search.add_argument("query")
    p_search.set_defaults(func=cmd_search)

    p_edit = sub.add_parser("edit", help="Editar una nota por id.")
    p_edit.add_argument("id", type=int)
    p_edit.add_argument("--title", default=None)
    p_edit.add_argument("--body", default=None)
    p_edit.set_defaults(func=cmd_edit)

    p_recent = sub.add_parser("recent", help="Listar las N notas más recientes.")
    p_recent.add_argument("--limit", type=int, default=5)
    p_recent.set_defaults(func=cmd_recent)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        return args.func(args)
    except NoteError as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
