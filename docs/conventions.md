# Convenciones de código

> Homogeneidad extrema. La IA predice mejor cuando el repositorio se parece
> a sí mismo en todas partes.

## Estilo Python

- **Versión:** Python 3.9+ (sintaxis `list[str]` permitida).
- **Formato:** PEP 8. Líneas máximo 100 caracteres.
- **Imports:** stdlib primero, luego locales. Una línea por módulo.
- **Strings:** comillas dobles `"..."` siempre. Comillas simples solo
  para escapar comillas dobles dentro.
- **f-strings** para interpolación. Nada de `.format()` ni `%`.

## Nombres

| Tipo                    | Convención        | Ejemplo               |
|-------------------------|-------------------|-----------------------|
| Módulos                 | `snake_case`      | `notes.py`            |
| Clases                  | `PascalCase`      | `Note`                |
| Funciones / variables   | `snake_case`      | `load_notes`          |
| Constantes              | `UPPER_SNAKE`     | `DEFAULT_NOTES_PATH`  |
| Privadas                | prefijo `_`       | `_atomic_write`       |

## Estructura de archivo

Cada archivo en `src/` empieza con:

```python
"""Una línea describiendo el propósito del módulo."""
from __future__ import annotations

# imports stdlib
import json
import os

# imports locales
from src.notes import Note
```

## Tests

- Un archivo de test por módulo: `tests/test_<módulo>.py`.
- Una clase `Test<Cosa>(unittest.TestCase)` por unidad lógica.
- Cada test usa un `tempfile.TemporaryDirectory()` y limpia tras de sí.
- Nombres de test descriptivos: `test_load_returns_empty_when_file_missing`.

## Manejo de errores

Excepciones del dominio en `src/notes.py`:

```python
class NoteError(Exception):
    """Base para errores del dominio."""

class NoteNotFound(NoteError):
    """Se lanza cuando se busca una nota inexistente."""
```

El CLI captura excepciones del dominio, imprime mensaje a `stderr` y sale
con código 1. Nunca propaga stack traces al usuario.

## Comentarios

Por defecto **no** se escriben. Solo se permiten cuando explican un *por qué*
no obvio (p. ej. workaround documentado, invariante sutil). Los nombres deben
hacer el resto.
