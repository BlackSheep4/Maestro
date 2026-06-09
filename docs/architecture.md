# Arquitectura — Qué significa "hacer un buen trabajo"

> Este documento define el estándar de calidad. Los agentes revisores
> evalúan código contra este archivo. Si no está aquí, no es un requisito.

<!-- HARNESS:REQUIRED — no modificar: los agentes dependen de esta sección -->

## Cómo se usa este archivo (regla del harness)

- Los agentes revisores evalúan el código **contra este archivo**. Es la vara
  de medir objetiva de la calidad.
- **Si algo no está aquí, no es un requisito.** No se rechaza código por una
  regla que no esté escrita en este documento.
- Los principios de calidad universales (abajo) aplican a cualquier proyecto.
  La arquitectura concreta del proyecto vive en la sección `HARNESS:FILL`.

## Principios de calidad (aplican a cualquier proyecto)

1. **Capas claras.** El proyecto tiene un conjunto pequeño y explícito de
   capas/módulos con responsabilidades separadas. No se introducen capas
   adicionales (servicios, repositorios, ORMs, etc.) hasta que haya una razón
   concreta documentada en `feature_list.json`.

2. **Sin dependencias no justificadas.** Cada dependencia externa debe estar
   justificada. Si una feature requiere una dependencia nueva, primero se
   discute (estado `blocked`).

3. **Errores explícitos.** Las funciones que pueden fallar (entrada inválida,
   recurso inexistente, datos corruptos) lanzan excepciones nombradas, no
   devuelven `None` ni valores centinela silenciosos.

4. **Inmutabilidad por defecto.** Los modelos de dominio son inmutables salvo
   razón concreta. Modificar = crear una nueva instancia.

5. **Atomicidad en disco.** Toda escritura persistente se hace de forma atómica
   (escribir a temporal + reemplazar). Nunca dejar un archivo a medio escribir.

<!-- /HARNESS:REQUIRED -->

<!-- HARNESS:FILL — rellena esto con el contexto de tu proyecto. Borra las instrucciones entre corchetes y sustitúyelas por la realidad de tu proyecto. Si un agente encuentra esta sección con los placeholders sin rellenar, debe preguntar al humano lo necesario y completarla antes de implementar. -->

## El proyecto

[Nombre y descripción del proyecto en 1-2 frases. Qué hace y para quién.
 P. ej.: "notes-cli — gestor de notas en línea de comandos que persiste notas
 en un único archivo JSON local."]

## Capas / módulos principales

[Lista las capas o módulos principales con su responsabilidad. Una línea por
 módulo. Ejemplos de cómo se ve esto en distintos stacks:

 - CLI en Python:   `storage.py` (persistencia JSON), `notes.py` (modelo de
   dominio `Note`), `cli.py` (interfaz argparse).
 - API web:         `api.py` (FastAPI routes), `models.py` (Pydantic schemas),
   `db.py` (SQLAlchemy session), `services.py` (lógica de negocio).
 - Servicio Go:     `handler/` (HTTP handlers), `domain/` (entidades),
   `store/` (acceso a Postgres).

 Sustituye por las capas reales de TU proyecto.]

## Flujo de datos

[Describe cómo fluyen los datos entre esas capas. Un diagrama ASCII simple basta.
 Ejemplo:

 usuario  ─→  cli.py (argparse)
               │
               ├─ construye el modelo de dominio
               │
               └─→  storage.load() / storage.save()
                        │
                        └─→  archivo de persistencia

 Dibuja el flujo real de TU proyecto: quién llama a quién y dónde acaban los datos.]

## Qué NO hacer (restricciones de dominio)

[Lista las restricciones específicas de TU proyecto: las cosas que rompen la
 arquitectura aunque "funcionen". Sé concreto y ejemplifica. Ejemplos:

 - No mezclar IO con lógica de dominio dentro del módulo de modelo.
 - No leer/escribir el archivo de persistencia dentro de un bucle: carga al
   inicio, modifica en memoria, guarda al final.
 - No usar `print()` para errores; usa el canal de error (stderr / logger) y
   un exit code / status != 0.
 - No añadir un sistema de configuración: la ruta/credenciales se pasan
   explícitamente o usan la constante por defecto.

 Sustituye por las restricciones reales de TU dominio y stack.]

<!-- /HARNESS:FILL -->
