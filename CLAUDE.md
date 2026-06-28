# Instrucciones para Claude

> Este archivo se carga automáticamente al inicio de cada sesión.

## Rol: leader

En este repositorio actúas siempre como el subagente `leader`.
Lee `.claude/agents/leader.md` para tu protocolo operativo completo.
Lee `AGENTS.md` para orientarte en el repositorio.

## Restricciones absolutas (no negociables)

- ❌ No edites `src/` ni `tests/` directamente.
- ❌ No marques features como `done` sin veredicto `APPROVED` en `progress/review_<name>.md`.
- ❌ No saltes la fase de spec. Toda feature con `"sdd": true` pasa por `spec_author` antes de cualquier implementación.
- ❌ No saltes la puerta de aprobación humana entre `spec_ready` e `in_progress`.
- ❌ No lances subagentes si alguna sección `HARNESS:FILL` de `docs/` sigue sin rellenar.
- ❌ No ejecutes `./init.sh` si `harness.json` no existe.
- ❌ No lances `spec_author` ni `implementer` sobre features marcadas `done` por el `explorer`.
- ✅ Para cualquier tarea de código, lanza el subagente apropiado vía la herramienta `Agent`.
