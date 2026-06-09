# Review — feature 7 (cli_recent)

**Veredicto:** APPROVED

## Trazabilidad requirements ↔ tests

- R1 (default <= 5 notas): [x] cubierto por `test_recent_default_limit_orders_by_created_at_desc`
  (`tests/test_cli.py:166-178`, crea 7 notas, espera exactamente 5 líneas).
- R2 (`--limit N` con N > 0): [x] cubierto por `test_recent_custom_limit`
  (`tests/test_cli.py:180-193`, crea 6 notas, `--limit 3`, espera 3 líneas).
- R3 (orden por `created_at` desc): [x] cubierto por
  `test_recent_default_limit_orders_by_created_at_desc`
  (`tests/test_cli.py:175-178`, valida `timestamps == sorted(reverse=True)` y
  el orden de títulos `nota-6..nota-2`).
- R4 (formato `<id>\t<created_at>\t<title>`): [x] cubierto por
  `test_recent_custom_limit` (`tests/test_cli.py:189-193`, valida 3 campos
  separados por tab, primer campo numérico, segundo campo ISO 8601).
- R5 (sin notas: exit 0, stdout vacío): [x] cubierto por
  `test_recent_empty_outputs_nothing` (`tests/test_cli.py:195-199`, comprueba
  `code == 0`, `out == ""`, `err == ""`).
- R6 (`--limit <= 0`: exit != 0, stderr no vacío): [x] cubierto por
  `test_recent_invalid_limit_zero` (`tests/test_cli.py:201-213`) y
  `test_recent_invalid_limit_negative` (`tests/test_cli.py:215-227`).
- R7 (`--limit <= 0`: no modifica el archivo): [x] cubierto por los mismos
  dos tests (comparan `before/after` con `storage.load` y bytes exactos del
  archivo).

## Tasks completas

- T1 (`cmd_recent` en `src/cli.py`): [x]
- T2 (subparser `recent` en `build_parser`): [x]
- T3 (`test_recent_default_limit_orders_by_created_at_desc`): [x]
- T4 (`test_recent_custom_limit`): [x]
- T5 (`test_recent_empty_outputs_nothing`): [x]
- T6 (`test_recent_invalid_limit_zero` + `test_recent_invalid_limit_negative`): [x]
- T7 (trazabilidad en `progress/impl_cli_recent.md`): [x]
- T8 (`./init.sh` verde): [x]

Todas las tasks de `specs/cli_recent/tasks.md` están marcadas `[x]`.

## Cumplimiento de `docs/architecture.md`

- [x] Capas respetadas: `cmd_recent` vive en `src/cli.py` (UI), usa
  `storage.load()` y no toca `src/notes.py` ni `src/storage.py`.
- [x] Sin dependencias externas (no hay `requirements.txt`).
- [x] Errores explícitos: `NoteError("--limit debe ser un entero positivo")`
  (excepción nombrada, no `None`).
- [x] Sin IO mezclado en dominio (la feature solo añade lógica de
  presentación).
- [x] Mensaje de error va a `stderr` vía el handler `main()` existente
  (`src/cli.py:132-134`), exit code 1.

## Cumplimiento de `docs/conventions.md`

- [x] Cabecera de archivo intacta (`src/cli.py:1-2`: docstring +
  `from __future__ import annotations`).
- [x] Comillas dobles en toda la implementación nueva.
- [x] f-strings para interpolación (`src/cli.py:61, 67`).
- [x] Nombres `snake_case` (`cmd_recent`, `p_recent`).
- [x] Tests usan `tempfile.TemporaryDirectory()` vía `setUp`/`tearDown`
  (`tests/test_cli.py:16-24`).
- [x] Nombres de test descriptivos
  (`test_recent_default_limit_orders_by_created_at_desc`,
  `test_recent_invalid_limit_negative`, etc.).
- [x] Sin comentarios superfluos.

## Checkpoints

- C1 — Arnés completo: [x] (`./init.sh` exit 0, 4 archivos base presentes,
  3 docs presentes).
- C2 — Estado coherente: [x] (sola feature `in_progress` es #7
  `cli_recent`; `progress/current.md` describe la sesión activa).
- C3 — Código respeta arquitectura: [x] (`src/` con los 3 módulos previstos,
  sin `requirements.txt`, sin `print()` de debug ni TODOs).
- C4 — Verificación real: [x] (`tests/test_cli.py`, `test_notes.py`,
  `test_storage.py`; 27 tests verdes; usa `TemporaryDirectory`, no mocks).
- C5 — Sesión: [x] (no hay archivos sospechosos sin trackear; `progress/`
  refleja la sesión actual; el estado `in_progress` se mantiene a la
  espera del leader que cierre la feature).
- C6 — SDD: [x] (feature #7 tiene su carpeta `specs/cli_recent/` con
  `requirements.md`, `design.md`, `tasks.md`; requirements en EARS
  estricto; todas las tasks `[x]`; cada `R<n>` cubierto por al menos un
  test concreto).

## Ejecución

```
./init.sh
Ran 27 tests in 0.040s
OK
```

## Cambios requeridos

Ninguno. La feature está lista para que el leader la marque `done` en
`feature_list.json`.
