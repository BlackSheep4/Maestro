# Roadmap: Flujo PR→CI→release como capacidad entregada por Maestro

> Estado: **definido, sin implementar.** Fruto de una sesión de brainstorming.
> Cuando se decida implementar, este documento es el punto de partida para el
> `spec_author`.

## Resumen en una línea

Un conjunto de plantillas que Maestro instala en cada proyecto para que su ciclo
sea: rama tipada → PR → gate de tests (local y CI espejo) → merge a `main` →
release automático con la versión calculada desde el nombre de rama.

## Decisiones tomadas (sesión de brainstorming)

| Decisión | Resolución |
|----------|------------|
| **Alcance** | **Solo proyectos generados.** No toca el release manual del propio Maestro; son artefactos de plantilla nuevos que `maestro init`/`upgrade` entregan. |
| **Notas de release** | **Auto desde el título/cuerpo del PR.** Sin gate de CHANGELOG escrito a mano en el proyecto generado. |
| **Cadencia** | **1 PR = 1 release.** Cada merge a `main` dispara su propio release. |
| **Multi-entorno (dev/int/main)** | **Aparcado a fase 2.** Fase 1 es single-branch (`main` → release estable). |

> Nota: estas decisiones disuelven los "choques" que parecían existir con el
> release actual de Maestro. Maestro conserva su `feat/` y su release manual; el
> flujo nuevo es algo que Maestro **entrega**, no que **adopta**.

## Mecánica (regla dura)

La **fuente de verdad del nivel de versión es el nombre de rama**:

| Rama | Bump | Reset |
|------|------|-------|
| `feature/<x>-major` | mayor +1 | minor=0, patch=0 |
| `feature/<x>-minor` | minor +1 | patch=0 |
| `fix/<x>` | patch +1 | — |

Ejemplos: `v1.4.2` + `feature/x-major` → `v2.0.0`; `v1.4.2` + `feature/x-minor`
→ `v1.5.0`; `v1.4.2` + `fix/x` → `v1.4.3`.

- **Disparo:** evento `pull_request` `closed` con `merged == true` hacia `main`.
  El workflow lee `head.ref`, hace match con la regla y calcula el bump.
- **Espejo de tests:** el `ci.yml` de plantilla corre `./init.sh` en cada PR —
  espejo exacto del gate SDD local, stack-agnóstico porque `init.sh` ya lee
  `harness.json`.
- Pueden coexistir N ramas `feature/*` y `fix/*` a la vez.

## Artefactos a construir

Todos como template en `~/.maestro/templates/` y copiados por `init`/`upgrade`:

1. `.github/workflows/ci.yml` (proyecto) — lint de nombre de rama + `./init.sh`.
2. `.github/workflows/release.yml` (proyecto) — bump desde `head.ref`, leer
   último tag, crear el tag siguiente, publicar release con notas del PR.
3. `.github/PULL_REQUEST_TEMPLATE.md` (proyecto) — **sin** el checkbox de nivel
   (el nivel ya vive en la rama); queda descripción + checklist.
4. `docs/branching.md` o `CONTRIBUTING.md` (proyecto) — la convención + la tabla
   de regla dura.
5. Registrar los 4 ficheros en `HARNESS_FILES` de `install.sh` y en la lógica de
   copia de `maestro` para que `init`/`upgrade` los entreguen.

## Decisiones abiertas (resolver en la fase de spec)

- **A — Fuente de verdad de la versión en el proyecto generado.** Recomendado:
  **git tags** (`vX.Y.Z`), cero supuestos sobre dónde guarda su versión un
  proyecto. Alternativas: fichero `VERSION` o un campo en `harness.json`.
- **B — Cómo el `ci.yml` genérico provisiona el toolchain** para correr
  `init.sh` (Python/Node/Go/…). ¿Derivado de `harness.json`? ¿Un bloque `setup`
  nuevo en `harness.json`? Es lo más espinoso del stack-agnosticismo; probable
  sub-tarea propia.
- **C — Bootstrap sin tags previos:** primer release arranca de `v0.0.0` o de
  `v0.1.0`.
- **D — Contrato del lint de rama:** `feature/*` sin sufijo `-major|-minor` =
  CI falla con mensaje claro.

## Frontera de fases

- **Fase 1 (esta tanda):** una sola rama destino, `main` → release estable.
- **Fase 2 (aparcada):** `int` → `-rc`, `dev` → `-beta`. El diseño de fase 1 no
  debe cerrar esa puerta: el bump y el tagging deben quedar parametrizables por
  rama destino.
