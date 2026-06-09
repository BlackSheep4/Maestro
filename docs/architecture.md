# Arquitectura — Qué significa "hacer un buen trabajo"

> Este documento define el estándar de calidad. Los agentes revisores
> evalúan código contra este archivo. Si no está aquí, no es un requisito.

## Principios

1. **Capas claras.** El proyecto tiene tres capas y solo tres:
   - `storage.py` — persistencia (JSON en disco).
   - `notes.py` — modelo de dominio (`Note`).
   - `cli.py` — interfaz de usuario (argparse).
   No introducir capas adicionales (servicios, repositorios, ORMs) hasta que
   haya una razón concreta documentada en `feature_list.json`.

2. **Sin dependencias externas.** Solo stdlib de Python. Si una feature
   requiere una dependencia, primero se discute (estado `blocked`).

3. **Errores explícitos.** Las funciones que pueden fallar (id no existe,
   archivo corrupto) lanzan excepciones nombradas, no devuelven `None`.

4. **Inmutabilidad por defecto.** `Note` es un `@dataclass(frozen=True)`.
   Modificar = crear una nueva instancia.

5. **Atomicidad en disco.** Toda escritura a `notes.json` se hace primero
   en un archivo temporal y luego `os.replace()`. Nunca dejar el archivo
   a medio escribir.

## Flujo de datos

```
usuario  ─→  cli.py (argparse)
              │
              ├─ construye Note con notes.Note.new(...)
              │
              └─→  storage.load() / storage.save()
                       │
                       └─→  .notes.json (en CWD)
```

## Qué NO hacer

- No usar `print()` para errores. Usa `sys.stderr` y exit code != 0.
- No mezclar IO con lógica de dominio dentro de `notes.py`.
- No leer/escribir el archivo en cada operación dentro de un bucle.
  Carga al inicio, modifica en memoria, guarda al final.
- No añadir un sistema de configuración. La ruta del archivo se pasa
  explícitamente o usa la constante por defecto.
