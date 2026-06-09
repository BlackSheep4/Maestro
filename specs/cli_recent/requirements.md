# Requirements — cli_recent

> Feature #7 del `feature_list.json`. Comando `recent` que lista las N notas
> más recientes ordenadas por `created_at` descendente.
>
> Cada requirement está redactado en EARS estricto y es verificable por al
> menos un test concreto en `tests/test_cli.py`.

## R1
CUANDO el usuario ejecuta `python -m src.cli recent` sin pasar `--limit`,
el sistema DEBE imprimir como máximo 5 notas en stdout.

## R2
CUANDO el usuario ejecuta `python -m src.cli recent --limit <N>` con un
entero `N > 0`, el sistema DEBE imprimir como máximo `N` notas en stdout.

## R3
CUANDO el comando `recent` imprime notas, el sistema DEBE ordenarlas por
el campo `created_at` de más reciente a más antigua.

## R4
CUANDO el comando `recent` imprime una nota, el sistema DEBE emitir una
única línea con el formato `<id>\t<created_at>\t<title>` (los mismos tres
campos y el mismo separador de tabulador que el comando `list`).

## R5
CUANDO el usuario ejecuta `python -m src.cli recent` y no existe ninguna
nota almacenada, el sistema DEBE salir con exit code `0` sin escribir nada
en stdout.

## R6
SI el usuario ejecuta `python -m src.cli recent --limit <N>` con `N <= 0`
ENTONCES el sistema DEBE salir con un exit code distinto de `0` y escribir
un mensaje de error en stderr.

## R7
SI el usuario ejecuta `python -m src.cli recent --limit <N>` con `N <= 0`
ENTONCES el sistema NO DEBE modificar el archivo de notas.

## Trazabilidad con `acceptance` del feature_list.json

| Acceptance criterion (feature #7)                                                       | Cubierto por |
|-----------------------------------------------------------------------------------------|--------------|
| `python -m src.cli recent` lista las 5 notas más recientes por defecto                  | R1, R3       |
| `python -m src.cli recent --limit 10` permite cambiar el número                         | R2           |
| El orden es por `created_at` de más reciente a más antigua                              | R3           |
| Cada línea sigue el formato `<id>\t<created_at>\t<title>` (mismo que `list`)            | R4           |
| Si no hay notas, exit code 0 y no imprime nada (consistente con `list`)                 | R5           |
| Si `--limit` es <= 0, exit code != 0 y mensaje claro en stderr                          | R6, R7       |
| Tests cubren orden por defecto, límite custom, archivo vacío, límite inválido           | R1–R7 (vía tests) |
