# Contribuir a Maestro

## Ramas

- `main` — siempre releaseable. Solo recibe merges de features completas.
- `feat/<nombre>` — desarrollo de features. Se mergean a `main` via PR.
- `fix/<nombre>` — correcciones. Se mergean a `main` via PR.

Nadie trabaja directamente en `main`.

## Proceso de release

Cuando hay suficientes cambios para una nueva versión:

1. Asegúrate de que todos los cambios están en `main` y el CI pasa.

2. Decide el nivel de versión según las reglas de semver de Maestro
   (ver `CHANGELOG.md` para la definición de PATCH/MINOR/MAJOR).

3. Actualiza `MAESTRO_VERSION` en el script `maestro`:
   ```bash
   # Edita la línea:
   MAESTRO_VERSION="X.Y.Z"
   ```

4. Añade la entrada de la nueva versión en `CHANGELOG.md`:
   ```markdown
   ## [X.Y.Z] — YYYY-MM-DD

   ### Added
   - ...

   ### Changed
   - ...

   ### Fixed
   - ...
   ```
   Para versiones MAJOR, añade también una sección `### Breaking Changes`
   con la guía de migración paso a paso.

5. Haz commit:
   ```bash
   git add maestro CHANGELOG.md
   git commit -m "chore: release vX.Y.Z"
   git push origin main
   ```

6. Crea y empuja el tag:
   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

7. El GitHub Action se encarga del resto:
   - Verifica que `MAESTRO_VERSION` en el script coincide con el tag.
   - Extrae las notas de `CHANGELOG.md`.
   - Actualiza `MAESTRO_REF` en `install.sh` para apuntar al nuevo tag.
   - Re-crea el tag sobre el commit actualizado.
   - Crea el GitHub Release con las notas.

## Qué verifica el CI en cada PR

- Sintaxis bash válida en `maestro`, `install.sh`, `init.sh` y hooks.
- JSON válido en `feature_list.json`, `harness.example.json` y `.claude/settings.json`.
- `CHANGELOG.md` tiene entrada para la versión actual del script.
- Todos los ficheros del harness están presentes.
- Los marcadores `HARNESS:REQUIRED` y `HARNESS:FILL` están correctamente cerrados.

## Semver en Maestro

| Nivel | Cuándo usarlo | `maestro upgrade` seguro |
|-------|--------------|--------------------------|
| PATCH | Fixes, correcciones, sin cambios estructurales | Sí, sin leer changelog |
| MINOR | Nueva funcionalidad compatible, nuevos agentes o comandos | Sí, conviene leer changelog |
| MAJOR | Cambios que rompen compatibilidad | No — requiere migración manual |

Un MINOR nunca elimina ni renombra bloques `HARNESS:FILL` existentes.
Un MAJOR siempre documenta la guía de migración en `CHANGELOG.md`.
