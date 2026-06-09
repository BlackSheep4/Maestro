# Implementación — cli_recent

> Feature #7 del `feature_list.json`. Resumen de la implementación y
> trazabilidad `R<n> → test` exigida por `docs/specs.md`.

## Resumen de cambios

- `src/cli.py`
  - Nueva función `cmd_recent(args)`: valida `args.limit > 0` (levanta
    `NoteError` si no), carga las notas con `storage.load()`, las ordena
    por `created_at` descendente, aplica el slice `[: args.limit]` e
    imprime cada una con el formato `<id>\t<created_at>\t<title>`.
  - Nuevo subparser `recent` en `build_parser()` con
    `--limit` (`type=int`, `default=5`) y `set_defaults(func=cmd_recent)`.
- `tests/test_cli.py`
  - Nuevo helper `_add_with_created_at` que escribe una nota directamente
    en el archivo de notas con un `created_at` controlado (necesario
    porque `Note.new` usa `timespec="seconds"` y las notas creadas en el
    mismo segundo compartirían marca de tiempo).
  - 5 tests nuevos (ver tabla más abajo).

No se han tocado `src/notes.py` ni `src/storage.py`, conforme al
`design.md`.

## Trazabilidad

| Requirement | Test                                                        |
|-------------|-------------------------------------------------------------|
| R1          | `test_recent_default_limit_orders_by_created_at_desc`       |
| R2          | `test_recent_custom_limit`                                  |
| R3          | `test_recent_default_limit_orders_by_created_at_desc`       |
| R4          | `test_recent_custom_limit`                                  |
| R5          | `test_recent_empty_outputs_nothing`                         |
| R6          | `test_recent_invalid_limit_zero`, `test_recent_invalid_limit_negative` |
| R7          | `test_recent_invalid_limit_zero`, `test_recent_invalid_limit_negative` |

Detalle:

- **R1** (default <= 5): `test_recent_default_limit_orders_by_created_at_desc`
  crea 7 notas y comprueba que `recent` (sin flags) imprime exactamente 5
  líneas.
- **R2** (custom `--limit`): `test_recent_custom_limit` crea 6 notas y
  comprueba que `recent --limit 3` imprime exactamente 3 líneas.
- **R3** (orden por `created_at` desc):
  `test_recent_default_limit_orders_by_created_at_desc` verifica que los
  timestamps están en orden descendente y que los títulos son los 5 más
  recientes.
- **R4** (formato `<id>\t<created_at>\t<title>`): `test_recent_custom_limit`
  comprueba que cada línea tiene exactamente 3 campos separados por
  tabulador y que el segundo es un timestamp ISO 8601.
- **R5** (sin notas: exit 0, stdout vacío): `test_recent_empty_outputs_nothing`
  ejecuta `recent` sobre un archivo sin notas y verifica `code == 0`,
  `out == ""` y `err == ""`.
- **R6** (`--limit <= 0`: exit != 0 y mensaje en stderr):
  `test_recent_invalid_limit_zero` (con `--limit 0`) y
  `test_recent_invalid_limit_negative` (con `--limit -3`).
- **R7** (`--limit <= 0`: no modifica notas): los mismos dos tests
  comparan el contenido del archivo de notas antes y después (a nivel de
  bytes y de objeto cargado) y verifican que no cambia.

## Verificación

- `./init.sh` ejecutado al final: **27 tests OK** (5 nuevos + 22
  preexistentes).

## Tasks

Todas las tasks T1..T8 de `specs/cli_recent/tasks.md` quedan marcadas
`[x]` excepto que el reviewer puede pedir cambios.

## Estado

Listo para review. **No** se marca `done` en `feature_list.json` —
queda a cargo del reviewer/leader según el protocolo.
