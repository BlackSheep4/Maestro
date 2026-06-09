# Tasks — cli_recent

> Pasos discretos en orden. El `implementer` marca `[x]` al completar cada
> uno. Cada task referencia los `R<n>` que cubre.

## Implementación

- [x] T1 — Añadir la función `cmd_recent(args)` en `src/cli.py` que:
  valida `args.limit > 0` (lanzando `NoteError` si no), carga las notas con
  `storage.load()`, las ordena por `created_at` descendente, aplica el
  slice `[: args.limit]` e imprime cada una con el formato
  `f"{n['id']}\t{n['created_at']}\t{n['title']}"`. Cubre: R1, R2, R3, R4, R5, R6, R7.

- [x] T2 — Registrar el subparser `recent` en `build_parser()` de
  `src/cli.py` con `--limit` (type=int, default=5) y
  `set_defaults(func=cmd_recent)`. Cubre: R1, R2.

## Tests

- [x] T3 — Añadir `test_recent_default_limit_orders_by_created_at_desc` en
  `tests/test_cli.py`: crea > 5 notas (parcheando `Note.new` o el reloj
  para producir `created_at` distintos), ejecuta `recent` sin flags y
  verifica que se imprimen exactamente 5 líneas en orden descendente por
  `created_at`. Cubre: R1, R3.

- [x] T4 — Añadir `test_recent_custom_limit` en `tests/test_cli.py`:
  crea N notas, ejecuta `recent --limit K` con `K < N`, verifica que se
  imprimen exactamente `K` líneas y que cada línea respeta el formato
  `<id>\t<created_at>\t<title>`. Cubre: R2, R4.

- [x] T5 — Añadir `test_recent_empty_outputs_nothing` en
  `tests/test_cli.py`: sin notas previas, ejecuta `recent`, verifica
  exit code `0` y stdout vacío. Cubre: R5.

- [x] T6 — Añadir `test_recent_invalid_limit_zero` y
  `test_recent_invalid_limit_negative` en `tests/test_cli.py`: con notas
  presentes, ejecuta `recent --limit 0` y `recent --limit -3`
  respectivamente; verifica que exit code es `!= 0`, stdout vacío, stderr
  no vacío, y que el archivo de notas en disco no ha cambiado. Cubre: R6, R7.

## Cierre

- [x] T7 — Documentar trazabilidad `R<n>` ↔ test en
  `progress/impl_cli_recent.md` siguiendo el ejemplo de `docs/specs.md`.

- [x] T8 — Ejecutar `./init.sh` y comprobar que todos los tests pasan
  (incluyendo los nuevos). Cubre: verificación final antes del review.
