# Changelog

Todos los cambios notables de Maestro se documentan aquí.
Formato: [Keep a Changelog](https://keepachangelog.com/es/1.1.0/).
Versioning: [Semantic Versioning](https://semver.org/).

## Qué significa cada nivel de versión en Maestro

- **PATCH** (1.0.x): fixes en el CLI, correcciones en docs del harness, sin cambios
  estructurales. `maestro upgrade` es seguro sin leer el changelog.
- **MINOR** (1.x.0): nueva funcionalidad compatible (nuevos comandos, nuevos agentes,
  nuevas secciones HARNESS:FILL). `maestro upgrade` es seguro; conviene leer el changelog
  para conocer las novedades. Un MINOR nunca elimina ni renombra bloques HARNESS:FILL
  existentes.
- **MAJOR** (x.0.0): cambios que rompen la compatibilidad (renombrar ficheros base,
  cambiar formato de `feature_list.json`, eliminar bloques HARNESS:FILL existentes,
  cambiar sintaxis de marcadores). `maestro upgrade` **no es suficiente** — requiere
  migración manual documentada en el changelog.

## [1.0.0] — 2026-06-09

### Added
- Harness inicial con cuatro agentes: `leader`, `spec_author`, `implementer`, `reviewer`
- Agente `explorer` para onboarding brownfield
- CLI `maestro` con comandos `init`, `status`, `check`, `upgrade`, `version`, `help`
- Instalador `install.sh` via `curl | bash`
- Sistema de marcadores `HARNESS:REQUIRED` / `HARNESS:FILL` en `docs/`
- `harness.json` generado por el agente durante el onboarding (stack agnóstico)
- `harness.example.json` con ejemplos para Python, Node, Go y Rust
- Flujo SDD completo: `pending → spec_ready → in_progress → done`
- Verificación ejecutable via `init.sh` con hooks post-edición
