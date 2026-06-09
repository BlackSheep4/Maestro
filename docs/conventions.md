# Convenciones de código

> Homogeneidad extrema. La IA predice mejor cuando el repositorio se parece
> a sí mismo en todas partes.

<!-- HARNESS:REQUIRED — no modificar: los agentes dependen de esta sección -->

## Por qué importa la homogeneidad

Un repositorio homogéneo es **predecible**. Cuando todos los archivos siguen
el mismo estilo, nombran igual y se estructuran igual, el agente puede
anticipar dónde va cada cosa y generar código que encaja sin fricción. La
inconsistencia obliga al agente a adivinar, y adivinar produce errores.

## Cómo se usan estas convenciones (regla del harness)

- Los agentes **aplican** estas convenciones al escribir código.
- El `reviewer` **rechaza** código que viole una convención escrita aquí.
- El esqueleto de secciones de abajo es fijo: todo proyecto define su estilo,
  nombres, estructura de archivos, tests, manejo de errores y política de
  comentarios. Lo que cambia entre proyectos es el **contenido** de cada
  sección, que vive en `HARNESS:FILL`.

## Esqueleto de convenciones (categorías obligatorias)

Todo proyecto que use este harness debe definir, en la sección `HARNESS:FILL`:

1. **Estilo** — lenguaje, versión, formato/linting, longitud de línea, comillas, etc.
2. **Nombres** — convención para módulos, clases, funciones, constantes, privadas.
3. **Estructura de archivo** — cómo empieza cada archivo de código (cabecera, orden de imports).
4. **Tests** — framework, organización (un archivo por módulo, etc.), nombres de test.
5. **Manejo de errores** — jerarquía de excepciones del dominio y cómo se propagan/capturan.
6. **Comentarios** — política de comentarios.

## Comentarios (política del harness)

Por defecto **no** se escriben comentarios. Solo se permiten cuando explican un
*por qué* no obvio (p. ej. workaround documentado, invariante sutil). Los
nombres deben hacer el resto. Cada proyecto puede endurecer esta regla en
`HARNESS:FILL`, pero no relajarla por debajo de este mínimo.

<!-- /HARNESS:REQUIRED -->

<!-- HARNESS:FILL — rellena esto con el contexto de tu proyecto. Borra las instrucciones entre corchetes y sustitúyelas por la realidad de tu proyecto. Si un agente encuentra esta sección con los placeholders sin rellenar, debe preguntar al humano lo necesario y completarla antes de escribir código. -->

## Estilo

[Define el estilo de TU stack. Cubre como mínimo: lenguaje y versión mínima,
 herramienta de formateo/linting, longitud máxima de línea, convención de
 comillas e interpolación de strings. Ejemplos por stack:

 - Python:     Python 3.9+; formato PEP 8 (black/ruff); líneas ≤ 100; comillas
   dobles; f-strings, nada de `.format()` ni `%`.
 - TypeScript: TS 5.x; formato Prettier; líneas ≤ 100; comillas simples;
   template literals para interpolación.
 - Go:         Go 1.22+; `gofmt` obligatorio; sin límite de línea estricto;
   errores envueltos con `fmt.Errorf("...: %w", err)`.

 Sustituye por el estilo real de TU proyecto.]

## Nombres

[Define la convención de nombrado de TU stack en forma de tabla. Ejemplo:

 | Tipo                  | Convención    | Ejemplo              |
 |-----------------------|---------------|----------------------|
 | Módulos               | `snake_case`  | `notes.py`           |
 | Clases                | `PascalCase`  | `Note`               |
 | Funciones / variables | `snake_case`  | `load_notes`         |
 | Constantes            | `UPPER_SNAKE` | `DEFAULT_NOTES_PATH` |
 | Privadas              | prefijo `_`   | `_atomic_write`      |

 Adapta las filas a las convenciones idiomáticas de TU lenguaje.]

## Estructura de archivo

[Muestra cómo empieza un archivo de código típico en TU proyecto: cabecera/docstring,
 orden de imports, separación stdlib vs. terceros vs. local. Ejemplo (Python):

 ```python
 """Una línea describiendo el propósito del módulo."""
 from __future__ import annotations

 # imports stdlib
 import json
 import os

 # imports locales
 from src.notes import Note
 ```

 Sustituye por la plantilla real de TU stack.]

## Tests

[Define el framework de tests y el patrón de organización de TU proyecto. Cubre:
 herramienta (pytest, unittest, jest, vitest, go test, ...), organización
 (¿un archivo de test por módulo?, ¿dónde viven?), patrón de aislamiento
 (tempdirs, fixtures, mocks), y convención de nombres de test. Ejemplo:

 - Framework: `unittest` de stdlib.
 - Un archivo de test por módulo: `tests/test_<módulo>.py`.
 - Una clase `Test<Cosa>(unittest.TestCase)` por unidad lógica.
 - Cada test usa un `tempfile.TemporaryDirectory()` real y limpia tras de sí.
 - Nombres descriptivos: `test_load_returns_empty_when_file_missing`.

 Sustituye por el framework y patrones reales de TU proyecto.]

## Manejo de errores

[Define la jerarquía de excepciones/errores del dominio de TU proyecto y cómo
 se propagan y capturan en la frontera. Ejemplo (Python):

 ```python
 class NoteError(Exception):
     """Base para errores del dominio."""

 class NoteNotFound(NoteError):
     """Se lanza cuando se busca una nota inexistente."""
 ```

 El CLI/handler captura excepciones del dominio en la frontera, emite el mensaje
 por el canal de error y termina con status != 0. Nunca propaga stack traces
 crudos al usuario final.

 Sustituye por las excepciones reales de TU dominio y la política de propagación
 de TU stack.]

<!-- /HARNESS:FILL -->
